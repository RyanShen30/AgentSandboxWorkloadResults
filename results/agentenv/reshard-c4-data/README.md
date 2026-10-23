# reshard-c4-data：AgentENV

单实例固定轨迹完整重放，2 vCPU，8192 MiB guest RAM。

| 调用数 | 工具合计 (s) | guest 文件缓存 初始→观测峰值→结束 (MiB) | 严格退出码一致 | 独立验证 |
| --- | --- | --- | --- | --- |
| 36 | 38.755 | 23.23 → 3110.42 → 590.84 | True | PASS |

![工具时延、guest 内存与指定文件驻留](runs/reshard-c4-data-20261023T154157Z-593615/curves.png)

[完整数值与校验](runs/reshard-c4-data-20261023T154157Z-593615/summary.json) · [连续内存 CSV](runs/reshard-c4-data-20261023T154157Z-593615/memory.csv) · [逐工具 CSV](runs/reshard-c4-data-20261023T154157Z-593615/steps.csv) · [文件边界](runs/reshard-c4-data-20261023T154157Z-593615/boundaries.json)

`Cached-Shmem` 为 guest 磁盘文件缓存近似量，Buffers 单列。菱形仅覆盖声明路径的普通文件驻留，两种范围不同。灰带为边界扫描；红色时延柱表示非零退出，并不自动表示平台失败。完整日志留在 cpu-15。
