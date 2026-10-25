# Agent Sandbox Workload Results

最新批次为 **2026-10-24 至 25 的 AgentENV v2 逐工具冻结扫描补测**：10 个任务、652 次固定工具调用、**662 个文件驻留边界**（每任务初始点加每次工具返回后的点）。同一任务在一台新 VM 内顺序重放，保留原命令、预期非零退出、持续 Shell 与后台任务；不调用模型重新规划。

交付三类数据：逐工具时延、约 200 ms 的 guest 内存曲线、guest page cache 与逐工具文件驻留曲线。业务 worker 及其后台进程进入本次 guest cgroup，边界验证 `frozen=1` 与 CPU 不推进后扫描，再解冻。**暂停的是业务进程，不是整台 VM**；guest 探针与内核仍可运行。cgroup 用作冻结控制；宿主服务 cgroup 只作辅助监控。

[结果解释与限制](docs/agentenv-results.md) · [阅读与指标说明](docs/README.md) · [完整测量协议](docs/agentenv-measurement.md) · [部署与补测记录](docs/agentenv-deployment.md) · [运行与复算](experiments/agentenv-memory/README.md)

## 最新结果

2 vCPU；除 CompCert 为 32 GiB 外均为 8 GiB guest RAM。下表分别给出 **整个 guest 的 `max(0,Cached-Shmem)`** 和 **根文件系统普通文件的 mincore 驻留量**，Buffers 另列。前者峰值合并非扫描阶段周期样本与工具前后快照，后者仅为冻结边界中的最大值；两者范围与时刻不同，不能相加。单位 MiB=2²⁰ bytes。

| 任务 | 调用数 | 工具合计 (s) | guest 文件缓存 初始→观测峰值→结束 (MiB) | 文件驻留 初始→边界峰值→结束 (MiB) | 实际验证范围 |
| --- | ---: | ---: | --- | --- | --- |
| [build-cython-ext](results/agentenv/build-cython-ext/README.md) | 83 | 175.91 | 23.7 → 208.2 → 120.0 | 5.3 → 186.9 → 115.7 | 扩展导入、两轮各 18 测试通过 |
| [reshard-c4-data](results/agentenv/reshard-c4-data/README.md) | 36 | 39.58 | 23.4 → 2820.8 → 175.8 | 5.3 → 1740.6 → 169.2 | 9,898 文件全量内容/结构往返通过 |
| [hf-model-inference](results/agentenv/hf-model-inference/README.md) | 11 | 89.61 | 23.0 → 832.5 → 262.4 | 5.3 → 764.3 → 254.6 | HTTP 服务正负样例通过 |
| [mozilla__pdf.js-20957](results/agentenv/mozilla__pdf.js-20957/README.md) | 5 | 244.47 | 23.1 → 891.7 → 67.6 | 5.3 → 544.9 → 59.0 | 两轮 CLI 测试通过 |
| [apache__logging-log4j2](results/agentenv/apache__logging-log4j2/README.md) | 10 | 249.89 | 35.0 → 563.7 → 98.6 | 27.7 → 534.0 → 91.3 | Maven 编译成功；跳过测试；检查器 141 |
| [large-scale-text-editing](results/agentenv/large-scale-text-editing/README.md) | 50 | 338.45 | 23.3 → 180.4 → 117.5 | 5.3 → 134.9 → 112.6 | 输出字节比对通过；不改原判题结论 |
| [count-dataset-tokens](results/agentenv/count-dataset-tokens/README.md) | 16 | 112.61 | 23.0 → 604.4 → 123.7 | 5.3 → 500.5 → 115.9 | 79,586 答案检查通过；实际计数 26 行 |
| [matplotlib__matplotlib-24177](results/agentenv/matplotlib__matplotlib-24177/README.md) | 95 | 61.11 | 70.8 → 229.7 → 29.2 | 52.2 → 146.8 → 12.9 | 最终两轮 60 passed；补丁与旧记录一致 |
| [django__django-16819](results/agentenv/django__django-16819/README.md) | 28 | 11.06 | 40.7 → 56.4 → 9.7 | 22.9 → 36.4 → 3.6 | 仅原范围语法检查通过 |
| [compile-compcert](results/agentenv/compile-compcert/README.md) | 318 | 2010.08 | 29.1 → 1961.3 → 124.3 | 5.3 → 1950.1 → 115.6 | 最终编译器编译运行检查通过 |

![guest 文件缓存概览](results/agentenv/overview.png)

全部 652 次工具退出码与固定 Podman 参考重放一致；`replay-inputs.json.source_exit_code` 是原轨迹元数据，二者来源不同。严格重放一致不等于原 benchmark 的全面正确性。

[任务索引与曲线](results/agentenv/README.md) · [汇总 CSV](results/agentenv/summary.csv) · [汇总 JSON](results/agentenv/summary.json) · [诊断与失败尝试](results/agentenv/diagnostics/README.md)

每个任务另有 **逐工具冻结边界图**：guest 总占用、总文件缓存、根文件系统普通文件驻留，以及按顶层目录分组的驻留。`boundaries.csv/json` 保留冻结证明、扫描前后计数、覆盖和排除项；`steps.csv` 保留时延、退出码和阶段标签；`phase-summary.csv/json` 区分明确的安装下载、混合动作和其余任务/检查窗口。

## 采集影响与结果边界

本批扫描合计 452.60 s，冻结控制区间合计 462.41 s；二者存在包含关系，不能相加。工具计时在扫描前结束，扫描成本单列；时延只含 guest 命令执行，模型耗时和 AgentENV RPC 往返另属其他口径。全根遍历可能加载目录/文件系统元数据并影响后续回收，排除扫描阶段样本不能消除这些影响；本批不用于平台速度比较。

**总内存曲线存在显著采集扰动。** Matplotlib 在首条业务工具执行前的根扫描期间，非空闲内存变化 +428.55 MiB，Slab +303.96 MiB，Buffers +133.57 MiB。这些是扫描前后观测，不能当作无扫描对照的因果差值；总内存曲线包含观察器与元数据，不能用作纯业务内存需求。文件缓存也可能受后续回收间接影响，均应按本协议下的观测解释。各任务变化见[结果解释与限制](docs/agentenv-results.md)。

扫描覆盖根文件系统中可通过路径访问的普通文件，包括 CompCert 实际 `/tmp/rocq-*`、OCaml、Dune 构建树；虚拟文件系统、其他挂载、符号链接与观察器控制路径明确排除。根文件扫描与 Cached-Shmem 的范围不同，未链接但仍映射的文件及目录/块缓存等不能据此精确逐文件归因。内核回收没有冻结；本批 5 个边界因两遍扫描间变化标为 PARTIAL，变化计数和稳定驻留量均保留，不能称为原子物理快照。

阶段标签描述**工具执行时间窗口**，不是内存页的来源；某业务窗口仍可能保留之前安装/下载的缓存。混合调用不强行拆开，缓存峰值不能跨阶段相加。初始值取业务开始前、开机/辅助工具/校准之后；结束值取最终扫描与独立验证之前。净变化不是累计读取量或新增分配总量。

原验证范围保持：Log4j Maven 编译成功但原检查器 141、源命令跳过测试；Django 仅语法检查；token 实际计数 26 行。重放完成不等于原 benchmark 全面正确。每任务一次主记录、未控制宿主 backing 冷暖，保持原 guest 内核与 DAMON 策略；没有物理共享、DAX 收益或统计性能结论。

## 历史与复算

本次补测保留 v1 的所有运行数据：[v1 轻量报告](AGENTENV-LIGHTWEIGHT-20261024.md)、[v1 选择清单](provenance/agentenv-runs-lightweight-v1.json)。v1 每任务仅三个文件扫描点，不应称作已完成逐工具冻结扫描。[旧 Podman 报告](PODMAN-20261020.md)也保留。

```bash
python3 -m pip install -r experiments/agentenv-memory/requirements-analysis.txt
python3 scripts/rebuild_agentenv_public.py --root . --verify-only
python3 scripts/rebuild_agentenv_public.py --root . --manifest provenance/agentenv-runs-lightweight-v1.json --verify-only
python3 scripts/verify_archive.py
```

无需完整日志即可核对公开 CSV、冻结边界与阶段摘要并重画：`python3 scripts/rebuild_agentenv_public.py --root .`。原始完整日志、二进制、校准和失败证据保留在 cpu-15 私有归档，公开仅含数值、固定可执行输入、版本和安全的元数据。
