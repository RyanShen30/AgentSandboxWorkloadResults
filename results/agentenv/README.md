# AgentENV 文件缓存测试

已归档 10 个主记录；单次运行，不代表多次统计或共享收益。

| 任务 | 调用数 | 工具合计(s) | guest 缓存 初始→峰值→结束(MiB) | 净变化(MiB) | 文件驻留 初始→边界峰值→结束(MiB) | 冻结边界 | PARTIAL | 退出码一致 | 验证 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [build-cython-ext](build-cython-ext/README.md) | 83 | 175.91 | 23.7 → 208.2 → 120.0 | 96.3 | 5.3 → 186.9 → 115.7 | 84 | 1 | True | PASS |
| [reshard-c4-data](reshard-c4-data/README.md) | 36 | 39.58 | 23.4 → 2820.8 → 175.8 | 152.4 | 5.3 → 1740.6 → 169.2 | 37 | 0 | True | PASS |
| [hf-model-inference](hf-model-inference/README.md) | 11 | 89.61 | 23.0 → 832.5 → 262.4 | 239.4 | 5.3 → 764.3 → 254.6 | 12 | 0 | True | PASS |
| [mozilla__pdf.js-20957](mozilla__pdf.js-20957/README.md) | 5 | 244.47 | 23.1 → 891.7 → 67.6 | 44.5 | 5.3 → 544.9 → 59.0 | 6 | 0 | True | PASS |
| [apache__logging-log4j2](apache__logging-log4j2/README.md) | 10 | 249.89 | 35.0 → 563.7 → 98.6 | 63.6 | 27.7 → 534.0 → 91.3 | 11 | 0 | True | FAIL |
| [large-scale-text-editing](large-scale-text-editing/README.md) | 50 | 338.45 | 23.3 → 180.4 → 117.5 | 94.2 | 5.3 → 134.9 → 112.6 | 51 | 0 | True | PASS |
| [count-dataset-tokens](count-dataset-tokens/README.md) | 16 | 112.61 | 23.0 → 604.4 → 123.7 | 100.6 | 5.3 → 500.5 → 115.9 | 17 | 0 | True | PASS |
| [matplotlib__matplotlib-24177](matplotlib__matplotlib-24177/README.md) | 95 | 61.11 | 70.8 → 229.7 → 29.2 | -41.6 | 52.2 → 146.8 → 12.9 | 96 | 0 | True | PASS |
| [django__django-16819](django__django-16819/README.md) | 28 | 11.06 | 40.7 → 56.4 → 9.7 | -31.0 | 22.9 → 36.4 → 3.6 | 29 | 0 | True | PASS |
| [compile-compcert](compile-compcert/README.md) | 318 | 2010.08 | 29.1 → 1961.3 → 124.3 | 95.2 | 5.3 → 1950.1 → 115.6 | 319 | 4 | True | PASS |

连续指标来自 guest `/proc/meminfo`，文件边界来自 guest 内 mincore。宿主镜像驻留、服务 cgroup 及 PFN 共享属于不同口径。

每任务初始点加每工具返回后的点均冻结业务组；探针与内核继续运行。扫描根文件系统普通文件，明确排除虚拟路径、其他挂载和控制文件。目录曲线、边界 CSV 和阶段摘要在各任务页面。PARTIAL 表示两遍之间观察到变化，不自动当作无误差。

[完整测量口径](../../docs/agentenv-measurement.md) · [校准回执](../../provenance/agentenv-protocol-calibration.json) · [v1 历史报告](../../AGENTENV-LIGHTWEIGHT-20261024.md)
