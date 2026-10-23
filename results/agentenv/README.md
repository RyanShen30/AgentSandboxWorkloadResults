# AgentENV 文件缓存测试

已归档 10 个主记录；单次运行，不代表多次统计或共享收益。

| 任务 | 调用数 | 工具合计(s) | guest 缓存 初始→峰值→结束(MiB) | 净变化(MiB) | 退出码一致 | 验证 |
| --- | --- | --- | --- | --- | --- | --- |
| [build-cython-ext](build-cython-ext/README.md) | 83 | 143.67 | 23.6 → 283.5 → 107.4 | 83.8 | True | PASS |
| [reshard-c4-data](reshard-c4-data/README.md) | 36 | 38.76 | 23.2 → 3110.4 → 590.8 | 567.6 | True | PASS |
| [hf-model-inference](hf-model-inference/README.md) | 11 | 83.34 | 21.3 → 651.3 → 324.5 | 303.2 | True | PASS |
| [mozilla__pdf.js-20957](mozilla__pdf.js-20957/README.md) | 5 | 171.90 | 23.0 → 950.5 → 60.6 | 37.6 | True | PASS |
| [apache__logging-log4j2](apache__logging-log4j2/README.md) | 10 | 313.54 | 34.5 → 670.1 → 77.5 | 43.0 | True | FAIL |
| [large-scale-text-editing](large-scale-text-editing/README.md) | 50 | 337.95 | 23.1 → 203.3 → 121.2 | 98.0 | True | PASS |
| [count-dataset-tokens](count-dataset-tokens/README.md) | 16 | 196.25 | 22.8 → 578.6 → 109.2 | 86.4 | True | PASS |
| [matplotlib__matplotlib-24177](matplotlib__matplotlib-24177/README.md) | 95 | 55.93 | 70.7 → 248.0 → 138.7 | 68.0 | True | PASS |
| [django__django-16819](django__django-16819/README.md) | 28 | 11.01 | 44.3 → 68.5 → 68.4 | 24.1 | True | PASS |
| [compile-compcert](compile-compcert/README.md) | 318 | 1939.82 | 28.8 → 1937.0 → 226.0 | 197.2 | True | PASS |

连续指标来自 guest `/proc/meminfo`，文件边界来自 guest 内 mincore。宿主镜像驻留、服务 cgroup 及 PFN 共享属于不同口径。
