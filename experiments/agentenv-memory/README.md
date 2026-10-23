# 十任务 AgentENV 重放规程

执行日期：2026-10-23 至 24（Asia/Shanghai），主机 cpu-15。新结果与旧 Podman 初筛分别归档。入口：[结果](../../results/agentenv/README.md)、[指标口径](../../docs/agentenv-measurement.md)、[部署与失败处理](../../docs/agentenv-deployment.md)。

本轮执行顺序为 Cython 适配、C4、HF、PDF.js、Log4j、CSV、token、Matplotlib、Django、CompCert，再补跑 Cython 的网络失败与 CompCert 的上游代理失效。已有成功任务不重复。发生网络失败时保存原尝试，修复或确认端点恢复后从新 VM 重放；不按时延/驻留大小选择主记录。

## 固定工具边界

| 任务 | 原工具调用数 | RAM MiB | 文件扫描 after step |
| --- | ---: | ---: | --- |
| build-cython-ext | 83 | 8192 | 0, 69, 83 |
| reshard-c4-data | 36 | 8192 | 0, 25, 36 |
| hf-model-inference | 11 | 8192 | 0, 3, 11 |
| mozilla__pdf.js-20957 | 5 | 8192 | 0, 1, 5 |
| apache__logging-log4j2 | 10 | 8192 | 0, 9, 10 |
| large-scale-text-editing | 50 | 8192 | 0, 25, 50 |
| count-dataset-tokens | 16 | 8192 | 0, 1, 16 |
| matplotlib__matplotlib-24177 | 95 | 8192 | 0, 60, 95 |
| django__django-16819 | 28 | 8192 | 0, 14, 28 |
| compile-compcert | 318 | 32768 | 0, 185, 318 |

合计 652 次原工具调用，主记录预定 30 个文件边界。首个 Cython 适配尝试只有首尾两边界，作为诊断保留，不冒充最终协议主记录。文件根路径保存在每个 `run.json`，缺失/跳过/错误见 `boundaries.json`。

## 代码入口

| 文件 | 职责 |
| --- | --- |
| `scripts/agentenv_workload_preflight.py` | 主机/KVM/固定服务镜像与依赖预检；私有配置留本机 |
| `scripts/agentenv_workload_service.py` | 专用定容卷、服务、OCI transport、窄端口代理、容量缓存回收与清理 |
| `scripts/prepare_agentenv_workload.py` | 固定 OCI 准备、blob 哈希与文件系统 diffID/runtime 配置核对 |
| `scripts/agentenv_workload_client.py` | REST + Connect JSON 流，保留业务非零退出与真实传输错误的区别 |
| `scripts/run_agentenv_workloads.py` | 原输入校验、guest 控制、原验证、输出归档、guest 删除 |
| `scripts/workload_probe.c` | meminfo 连续采样、文件扫描与 fixture 校准 |
| `scripts/workload_timer.c` | guest 单调时钟、工具退出码、CPU/maxrss 与边界内存 |
| `scripts/queue_agentenv_workloads.py` | 串行执行、容量阈值、异常时停止队列 |
| `scripts/refresh_agentenv_upstream.py` | 从当前会话环境刷新仅本次 relay 的上游端口 |
| `scripts/report_agentenv_workloads.py` | 从私有原始归档导出公开数据/图表 |
| `scripts/rebuild_agentenv_public.py` | 仅使用公开 CSV 校验摘要并重画 |

静态辅助程序：

```bash
mkdir -p .artifacts/agentenv-workload-build
gcc -O2 -Wall -Wextra -Werror -static scripts/workload_probe.c -o .artifacts/agentenv-workload-build/workload_probe
gcc -O2 -Wall -Wextra -Werror -static scripts/workload_timer.c -o .artifacts/agentenv-workload-build/workload_timer
gcc -O2 -Wall -Wextra -Werror -static experiments/container-screening/harness/file_reader.c -o .artifacts/agentenv-workload-build/file_reader
gcc -O2 -Wall -Wextra -Werror -static experiments/container-screening/harness/clock_ns.c -o .artifacts/agentenv-workload-build/clock_ns
python3 -m unittest discover -s tests -p test_agentenv_workload_transport.py
```

主机部署和原始轨迹重放依赖 cpu-15 的私有完整归档，公开 checkout 可独立完成数值复算与重画。控制脚本保留本机路径/UID 和旧部署容器标识，属于实际运行规程，不是任意新机器的一键安装器。迁移主机时应显式重新配置并校准，不能直接套用旧清理标识。
