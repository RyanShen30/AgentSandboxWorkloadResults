# 十任务 AgentENV v2 重放与公开字段

本轮在 cpu-15 使用真正的 AgentENV microVM。10 个任务各开新 VM，在该 VM 内顺序重放原先记录的固定可执行输入，不重新运行模型。共 652 次工具调用，测量点为每任务初始点及每次工具返回后，共 662 个文件边界。

[结果索引](../../results/agentenv/README.md) · [指标定义与限制](../../docs/agentenv-measurement.md) · [部署/诊断](../../docs/agentenv-deployment.md) · [v1 历史报告](../../AGENTENV-LIGHTWEIGHT-20261024.md)

## 执行与暂停时机

| 任务 | 工具数 | RAM MiB | 文件边界 after_step |
| --- | ---: | ---: | --- |
| build-cython-ext | 83 | 8192 | 0–83 |
| reshard-c4-data | 36 | 8192 | 0–36 |
| hf-model-inference | 11 | 8192 | 0–11 |
| mozilla__pdf.js-20957 | 5 | 8192 | 0–5 |
| apache__logging-log4j2 | 10 | 8192 | 0–10 |
| large-scale-text-editing | 50 | 8192 | 0–50 |
| count-dataset-tokens | 16 | 8192 | 0–16 |
| matplotlib__matplotlib-24177 | 95 | 8192 | 0–95 |
| django__django-16819 | 28 | 8192 | 0–28 |
| compile-compcert | 318 | 32768 | 0–318 |

全部为 2 vCPU。工具计时结束后，控制器冻结 guest 内本任务业务 cgroup，核验冻结与 CPU 不推进，扫描后解冻。控制器、探针、采样器、平台系统进程和内核不冻结。原后台任务也被冻结；其原异步返回和后续依赖等待保持原顺序。持续 Shell 的 cwd、变量、函数由同一 worker 保持。完整 VM 暂停无法同时在该 guest 内运行 mincore，本实验不声称做了整机暂停。

扫描入口 `/`，只遍历根文件系统可达普通文件；虚拟路径、其他挂载、符号链接、特殊文件、`/probe` 和观察器输入包排除。扫描不读取业务文件内容来预热缓存，仍会加载目录/文件系统元数据。两遍 mincore 出现变化时保留 PARTIAL 和变化数；业务冻结不等于内核停止回收。

## 每任务公开文件

`strict_exit_match` 比对固定 Podman 参考重放的实际退出序列；`replay-inputs.json` 的 `source_exit_code` 来自原轨迹元数据，可为空或与参考重放不同，不作为这一布尔值的比较目标。参考运行由 `run.json.reference_run` 和原 `provenance/runs.json` 定位。

任务页面指向 `results/agentenv/<task>/runs/<run_id>/`。同一任务的 v1 运行目录保留，当前主记录仅由 `provenance/agentenv-runs.json` 指定。

| 文件 | 内容 |
| --- | --- |
| curves.png / svg | 工具时延、guest 内存、总体文件缓存与文件驻留；灰带为扫描 |
| boundaries.png / svg | 按工具序号排列的冻结边界曲线，以及顶层目录驻留堆叠 |
| memory.csv | 周期样本；含 guest 实时/单调时钟、当前工具和采集阶段、原 meminfo 与派生字段 |
| steps.csv | 逐工具时间、退出码、可用时的 CPU/maxrss、工具前后内存、phase_label / phase_basis |
| boundaries.csv | 每边界驻留字节/页数、实际页大小、稳定驻留、文件数、扫描/冻结成本、变化数、扫描前后缓存/Buffers/Slab/非空闲计数和目录分解 |
| boundaries.json | 完整扫描范围、排除项、两遍变化、冻结和解冻证明、扫描前后 meminfo |
| baseline.json / final.json | 首尾快照；在首/末文件扫描之前读取；独立验证在窗口外 |
| phase-summary.csv / json | 按命令规则归类的工具时间窗口；缓存为该窗口整个 guest 的观测峰值 |
| summary.json | 数值汇总、覆盖/冻结/路径检查、原验证语义、限制 |
| replay-inputs.json | 固定原工具顺序、命令和脚本文本及 SHA-256，不含原对话和输出 |
| guest-runner.sh / guest-worker.sh | 实际控制与业务执行脚本 |
| async-barriers.json | 原异步完成屏障；仅 CompCert 非空 |
| run.json / oci-origin.json | 资源设置、来源、实际镜像身份、源码哈希和清理状态 |
| validation.json / calibration.json | 原范围独立验证和本次文件驻留 fixture 校准 |
| artifact-sha256.json | 此运行公开文件的哈希，图片可因字体环境不同而变化 |

直接计时工具提供 CPU/maxrss；持续 Shell 工具只有时延、退出码和前后内存，不伪造 CPU/maxrss。完整业务指标为本轮要求的时延、guest 内存和 page cache。

`memory.csv` 的 `phase=cache_scan` 表示采集观察阶段，不是 `steps.csv` 的业务阶段标签。净变化只由首尾快照相减；观测峰值排除扫描区间及阶段不明的周期样本，同时计入工具前后及首尾计数。阶段不明数量见 `unclassified_periodic_samples`；排除不能消除扫描对后续的影响。顶层目录分类采用首次遇到路径，硬链接只算一次。v2 中兼容字段 `initial_declared_file_resident_bytes` / `final_declared_file_resident_bytes` 对应根文件系统驻留首尾值；不是 v1 的有限目录范围。`observed_boundary_file_resident_peak_bytes` 仅取实际扫描边界中的最大值，不能当作边界之间连续驻留的真实峰值。

`phase_label` 的 setup_download、mixed_setup_task、wait_or_inspect、task_or_inspect 仅描述原命令时间窗口。并不保证一次下载真的联网，不保证其余窗口没有后台下载，也不能把峰值按标签相加或解释为页来源。

## 采集代码和核查

| 入口 | 职责 |
| --- | --- |
| scripts/agentenv_workload_preflight.py | KVM、固定服务镜像和依赖预检 |
| scripts/agentenv_workload_service.py | 专用定容卷、服务、OCI transport、窄代理与定向清理 |
| scripts/prepare_agentenv_workload.py | OCI layer 哈希、原镜像 diffID/runtime 配置核验 |
| scripts/agentenv_workload_client.py | REST/Connect 传输，区分原业务非零退出和传输失败 |
| scripts/run_agentenv_workloads.py | 固定输入校验、guest worker/控制、原验证、归档、VM 删除 |
| scripts/workload_probe.c / workload_memory.h | guest 采样、业务 cgroup 冻结/证明、根文件 mincore |
| scripts/workload_timer.c | guest 单调时钟工具计时、退出码与内存边界 |
| scripts/queue_agentenv_workloads.py | 串行准备与执行、容量门槛、失败即停 |
| scripts/refresh_agentenv_upstream.py | 仅刷新本次 relay 的会话代理上游 |
| tests/agentenv_frozen_integration.py | 显式真实 VM 回归：前后台、非零退出、持续 Shell、规范根路径 |
| scripts/report_agentenv_workloads.py | 私有原始记录导出公开数据和图表 |
| scripts/rebuild_agentenv_public.py | 只用公开 CSV/JSON 验证数值和重画 |
| scripts/archive_agentenv_workloads.py | 逐文件哈希验证私有原始资料，再允许释放工作卷 |

静态采集程序编译及传输单测：

```bash
mkdir -p .artifacts/agentenv-workload-build
gcc -O2 -Wall -Wextra -Werror -static scripts/workload_probe.c -o .artifacts/agentenv-workload-build/workload_probe
gcc -O2 -Wall -Wextra -Werror -static scripts/workload_timer.c -o .artifacts/agentenv-workload-build/workload_timer
gcc -O2 -Wall -Wextra -Werror -static experiments/container-screening/harness/clock_ns.c -o .artifacts/agentenv-workload-build/clock_ns
python3 -m unittest discover -s tests -p test_agentenv_workload_transport.py
```

仅复算公开记录，无需 VM、sudo 或完整原始日志：

```bash
python3 -m pip install -r experiments/agentenv-memory/requirements-analysis.txt
python3 scripts/rebuild_agentenv_public.py --root . --verify-only
python3 scripts/rebuild_agentenv_public.py --root . --manifest provenance/agentenv-runs-lightweight-v1.json --verify-only
python3 scripts/rebuild_agentenv_public.py --root .  # 重画当前 v2 图表和首页
python3 scripts/verify_archive.py
```

业务重放依赖 cpu-15 的私有完整原始输入、CompCert 异步屏障和部署 seed；控制脚本保留实际本机路径、UID 与部署标识。迁移需要显式重新配置和校准，不是任意机器的一键安装器。实际 collector 版本由每运行 `source_hashes` 及 `source-snapshots/<sha256>/` 确定；当前仓库脚本还包含后来修正，不能混为当时版本。

[实际采集程序的重新编译核验](../../provenance/agentenv-collector-builds.json) · [真实 VM 协议回归](../../provenance/agentenv-protocol-calibration.json)
