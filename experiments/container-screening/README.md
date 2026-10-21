# 容器初筛实验规程

> 公开范围：本次只提交文档、图表、汇总/CSV、配置与脚本。完整原始日志、轨迹和重放输入包保留在 cpu-15；重算/重放须提供 ASWR_ARCHIVE_ROOT，见[数据说明](../../docs/data-and-sources.md)。
目的：检查十项固定公开工具轨迹的可执行性，逐工具记录时延，连续记录 cgroup 内存，并在每个工具完成后冻结扫描文件驻留。结果用于筛选后续多租户/DAX 任务。平台不可用时采用用户确认的容器方案；不生成新 Agent，不依赖模型 API。

## 固定输入与实际入口

[workloads.json](workloads.json) 保存任务范围和解释；每任务目录保留 provenance、源文件 SHA-256、版本以及 `replay-inputs.tar.gz`。部署脚本展开后，输入路径与原 runner 一致。

| 任务 | runner | 工具数 | 内存限额 |
| --- | --- | ---: | ---: |
| reshard-c4-data | runner.py | 36 | 8 GiB |
| large-scale-text-editing | runner.py | 50 | 8 GiB |
| hf-model-inference | runner.py | 11 | 8 GiB |
| mozilla__pdf.js-20957 | runner.py | 5 | 8 GiB |
| build-cython-ext | runner.py | 83 | 8 GiB |
| count-dataset-tokens | runner_batch2.py | 16 | 8 GiB |
| apache__logging-log4j2 | runner_batch2.py | 10，含初始化 | 8 GiB |
| matplotlib__matplotlib-24177 | runner_batch2.py | 95 | 8 GiB |
| django__django-16819 | runner_batch2.py | 28 | 8 GiB |
| compile-compcert 原记录 | runner_batch2.py | 318 | 8 GiB |
| compile-compcert 主记录 | runner_compcert32.py | 318 | 32 GiB |

[harness](harness) 保留最终实际使用的原采集器和静态 C 桥接器源码。第二批各 run 的 harness-snapshot.py 为运行时原样快照；CompCert 两轮脚本哈希与限额调整的检查见[配对校验](../../provenance/collection-checks/compcert-memory-quality-check.json)。

## 单任务运行

先按[部署说明](../../docs/deployment/README.md)创建独立运行目录、编译探针、准备对应镜像，然后从该目录运行：

```bash
cd /home/rashen/work/AgentWorkloadReplay-new
python3 -u runner.py reshard-c4-data --ack-container-metrics
# 或第二批单项
python3 -u runner_batch2.py count-dataset-tokens --ack-container-metrics
# CompCert 使用 32 GiB 主设置
python3 -u runner_compcert32.py compile-compcert --ack-container-metrics
```

上述命令是不同任务的示例，不要求连续执行。每次先完成对应镜像准备并确认空闲内存/磁盘。`--ack-container-metrics` 用于显式接受容器指标口径；32 GiB runner 应只用于 CompCert 复测，其他任务按表选择原入口。`--steps` 仅供探针诊断，不能把部分轨迹标成完成。

第一批单任务最大测量时限为 3600 秒、工具 900 秒；第二批采集器总时限为 10800 秒，并按命令设置工具超时。CompCert 还设有异步完成等待与源码包完整性门槛。暂停与扫描也占测量墙钟，应纳入外部作业服务的超时预算。

runner 即使捕获错误并写入 FAIL，进程也可能正常退出；完成状态必须读取 `results/<task>-<timestamp>/run.json` 的 status，不能只看 shell 返回码。正确性检查单独读取 validation.json，必要时读取原实验的补充证据。

## 一次采集的生命周期

准备镜像 → 创建限额容器 → 预检源码/解释器/委派指标 → 启动内存采样 → 冻结基线扫描 → 按序调用工具 → 每步冻结扫描 → 停止连续采样 → 本地验证 → 保存事件/清理容器。

普通 native read/write 通过文件操作适配；持续 shell 保留状态；CompCert 真实后台任务和完成依赖单列；PDF.js 仅重放 setup.log 的五条命令。配置变化、源退出码、本次退出码、全部脚本哈希进入逐步归档，不把源错误尝试删掉后拼成新成功轨迹。

Matplotlib 按 mini-swe-agent 使用 login Bash 激活 Conda。Django 的环境 HEAD 与源 base 不同，但需要原 base 为祖先、整个 django 源码树无差异且关键 blob 一致；检查失败即中止。预检不提前导入业务库。

## 本次报告的生成与后续新 run

本仓库 `scripts/build_results.py` 只读取 provenance/runs.json 中固定的 11 次完成记录，重算表格和图，不自动挑选文件夹里“最新”的运行。失败、取消和诊断记录不会因时间较新被误合入。

后续新 run 先检查覆盖、N+1 边界、冻结、扫描错误、实际限额与验证；再建立新的归档路径并显式登记 run ID，不覆盖原始运行。`scripts/verify_archive.py` 用于仓库当前归档，不是自动接受未知新 run 的判题器。每份报告都需说明采用哪个 run、backend 与内存设置。
