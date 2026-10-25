# 阅读入口与本轮补齐内容

最新结果采用 **AgentENV v2：逐工具冻结扫描**。建议先看[首页表格](../README.md)，再选一个[任务页面](../results/agentenv/README.md)对照两张图及 CSV。

| 想了解什么 | 阅读位置 |
| --- | --- |
| 本次数据说明了什么，还有哪些严重限制 | [结果解释与限制](agentenv-results.md) |
| page cache、文件驻留、guest 内存有什么关系；何时采集 | [测量口径与限制](agentenv-measurement.md) |
| 为什么还用 cgroup；具体暂停什么 | [每个边界的执行顺序](agentenv-measurement.md#每个边界实际发生什么) |
| 每个字段和阶段标签如何解释；怎样复算 | [重放规程与字段索引](../experiments/agentenv-memory/README.md) |
| 环境、镜像、代理、失败重试、清理 | [部署记录](agentenv-deployment.md) |
| 哪次运行计入主结果、哪些被排除 | [显式选择清单](../provenance/agentenv-runs.json)、[诊断记录](../results/agentenv/diagnostics/README.md) |
| 冻结、输入、数值、原始资料是否核验 | [验证回执](../provenance/agentenv-validation.json)、[采集程序构建核验](../provenance/agentenv-collector-builds.json)、[环境和归档回执](../provenance/agentenv-environment.json) |

本轮补齐：每工具之后的驻留点、后台业务冻结、根文件系统普通文件覆盖、顶层目录分解、冻结/扫描成本，以及安装下载与其余工具窗口的分组。保持原轨迹和原验证范围，不引入新的模型执行。

仍有限制：每任务一次主记录；内核回收继续，扫描不原子；观察器会加载元数据；基线之前无完整启动曲线；阶段窗口不能识别页的来源；没有测量物理共享或 DAX 收益。具体哪些点发生变化、变化多少，见每任务 `summary.json` 和 `boundaries.json`，不能将 PARTIAL 自动解读为零误差。

## 历史资料

- [v1 轻量实验报告](../AGENTENV-LIGHTWEIGHT-20261024.md)：200 ms guest 计数，每任务仅三次文件扫描，无业务冻结。
- [v1 测量文档](lightweight-v1-agentenv-measurement.md)、[v1 部署记录](lightweight-v1-agentenv-deployment.md)、[v1 选择清单](../provenance/agentenv-runs-lightweight-v1.json)。
- [2026-10-20 Podman 报告](../PODMAN-20261020.md)、[旧结果](../results/README.md)、[旧测量口径](measurement.md)、[旧部署](deployment/README.md)、[数据来源](data-and-sources.md)、[旧验证说明](validation.md)。

旧 Podman 的宿主文件驻留与容器记账、AgentENV 的 guest 计数，属于不同边界，不能直接相减得出共享率或节省量。
