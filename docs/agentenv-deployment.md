# AgentENV v2 部署、失败保留与收尾

批次于 2026-10-24 启动，10 月 25 日继续完成采集。主机 cpu-15 已取得 sudo 和 KVM 权限，使用真正 microVM。旧 Podman 当时无 KVM 的说明仅适用于旧批次。[v1 原部署记录](lightweight-v1-agentenv-deployment.md)保留。

## 固定环境与资源

- 固定服务镜像 `ghcr.io/kvcache-ai/aenv-server@sha256:c5cd67759d365669b558d3754a18bdf52fa8b7614fe23bcb34250e723cf2ee03`，本地 image ID `sha256:db9eb044ae3d85f9b276b9d2e5dea28cb0be95263d217ea4989f095e1d828681`。
- guest 内核 6.1.175，SHA-256 `cd7c5a06a2026a2d8a0cddf60b41a5d76a6ac025e54439eb3ee5c9e57a60c67b`；沿用官方 DAMON 策略，不清全局 page cache。
- 本轮独立服务、随机 loopback API 端口、独立网段、**实分配 32 GiB ext4 工作卷**。v1 使用 40 GiB，本轮启动时按可用空间预算改为 32 GiB；不是 guest RAM 容量。每 guest 2 vCPU，8 GiB RAM，CompCert 32 GiB。
- 关闭预热池和镜像自动 GC，service root 只读；数据、临时转换和 backing 均位于本卷。host 可用空间不得低于 26 GiB，工作卷不得低于 2 GiB。
- 数据按任务串行采集，不在业务测量时准备其他任务镜像。每任务成功且没有 live guest 后，只回收该任务 OCI 以及本服务私有转换缓存；其身份已经复制至该次 raw 记录。所有 raw、失败证据、固定依赖和凭据保留。没有全局 prune。

原内核参数包括 `damon_reclaim.enabled=Y`、`min_age=100000`、`quota_ms=20`、`quota_sz=1073741824`、`quota_reset_interval_ms=500`、`wmarks_high=990`、`wmarks_mid=990`、`wmarks_low=200`、`skip_anon=Y`、`wmarks_interval=1000000`。内核回收可能在业务冻结时继续，影响页驻留和 PARTIAL 状态。

## 镜像、输入与网络

任务输入由[原镜像清单](../provenance/images.json)固定。已有的本机 Podman 镜像导出 OCI，核对 RootFS.diff_ids 与 Env/Cmd/Entrypoint/WorkingDir/User；已删除的远程镜像按固定 digest 拉取 linux/amd64，逐 layer 校验 SHA-256。Log4j 按原 Containerfile、固定基础镜像和源码提交重建，实际新 image ID 单列，不声称重建镜像逐字节相同。实际每次来源见 `oci-origin.json`。

AgentENV regctl transport 将镜像引用与本次 alias 都映射到同一 OCI layout，保持官方 OverlayBD 转换。这里的 OCI layer/blob 是镜像存储格式；仓库更新使用普通 Git commit/push。

guest 通过仅允许本次网段连接的临时 TCP relay 访问已有 host HTTP 代理；不解密 TLS、不改写响应。relay 每次新连接读取本次 `host-proxy-upstream.json`，上游失效时检查当前工具环境并仅刷新本次文件。服务重启后重新添加精确的 INPUT 放行。相关端口和身份在本机私有回执记录。

原命令和生成的输入脚本逐 SHA-256 核验，实际控制/worker 脚本与源码快照公开。Matplotlib 最终补丁与旧参考 SHA-256 一致。持续 Shell、原预期非零退出和 CompCert 异步屏障有专门回归，独立验证在测量结束之后执行。

## 本轮问题与恢复

| 尝试 | 问题及处理 |
| --- | --- |
| 初次 worker 回归 | 归档误包含控制 FIFO，安全解包器正确拒绝；执行记录保留，归档显式排除 FIFO 后重新验证 |
| 前三次完整执行：Matplotlib、PDF.js、Cython | 根递归产生 `//`，顶层分类全落入 other，控制路径排除失效；它们保留为诊断，文件驻留结果不计入主汇总。修正为规范绝对路径，加入真实 VM 根路径/排除断言，再各开新 VM 重采 |
| C4 第一次镜像准备 | 宿主会话代理连接拒绝，业务尚未启动；保留日志和部分 layout，连接恢复后按同一固定 digest 重试 |
| 长间隔后的继续采集 | host 辅助 sampler 达 4 小时上限自动结束；继续时新增采样段，保留真实缺口，不插值。guest 主指标只在各自运行窗口内解释 |

后续尝试及最终状态由[运行选择清单](../provenance/agentenv-runs.json)、[诊断索引](../results/agentenv/diagnostics/README.md)和[验证回执](../provenance/agentenv-validation.json)记录。仅满足固定输入、原退出序列、冻结证明、规范路径和控制排除的运行进入主结果；不按时延或驻留大小选择。

业务 cgroup 冻结/解冻、前后台恢复、16 MiB 冷/热文件、持续 Shell 和非零退出在独立 VM 校准；每个正式 VM 另有自身文件 fixture 校准。没有把整机暂停、物理 PFN 去重或 DAX 测试算作已完成。

## 原始资料和定向清理

每任务先下载完整 raw 资料，再删除该 guest。服务停止前，先结束 host sampler，将卷内所有普通 raw 文件和服务日志快照复制到卷外，逐文件哈希验证，生成 VERIFIED 回执，再允许 `stop --release`。本轮原始归档位于 cpu-15 的 `.artifacts/agentenv-workload-archive/20261024T153452Z-876603/`，不公开完整输出、原对话、凭据或二进制。

清理限定本次 label 的容器、relay、精确规则/alias、转换缓存和 loop 卷。实际最终清理、归档文件数量/字节数/manifest SHA-256 见[环境与收尾回执](../provenance/agentenv-environment.json)。v1 数据保持原目录并有独立[历史清单](../provenance/agentenv-runs-lightweight-v1.json)，不会被新曲线覆盖。

运行入口有本机 UID、历史 seed 和路径依赖，迁移需重新配置；公开数值复算只需 Python 分析依赖，见[规程](../experiments/agentenv-memory/README.md)。
