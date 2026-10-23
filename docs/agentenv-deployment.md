# 本轮 AgentENV 部署与恢复记录

日期：2026-10-23 至 24（Asia/Shanghai）。本轮已取得 sudo，实际 `/dev/kvm` open/ioctl 返回 API version 12；由此恢复 microVM 测试。旧 Podman 初筛的权限描述仅指 2026-10-20 当时条件。

## 实际环境

- cpu-15，Ubuntu，host 内核 6.19.9+，约 503 GiB RAM；guest 内核 6.1.175，二者分别记录。
- 固定服务镜像：`ghcr.io/kvcache-ai/aenv-server@sha256:c5cd67759d365669b558d3754a18bdf52fa8b7614fe23bcb34250e723cf2ee03`；本机 image ID：`sha256:db9eb044ae3d85f9b276b9d2e5dea28cb0be95263d217ea4989f095e1d828681`。
- guest kernel SHA-256：`cd7c5a06a2026a2d8a0cddf60b41a5d76a6ac025e54439eb3ee5c9e57a60c67b`。
- 独立 Docker 服务、随机 loopback API 端口、独立 CIDR、固定实分配 40 GiB ext4 卷。关闭预热池和镜像自动 GC，保留官方 DAMON。主机至少保留 26 GiB，工作卷至少保留 2 GiB。
- 复用旧停止服务中的固定依赖和配置骨架；不复用旧数据库或凭据，新凭据仅留本机。服务 Docker root 只读，数据目录均在本次卷内。

guest 内核启动参数保留：`damon_reclaim.enabled=Y`、`min_age=100000`、`quota_ms=20`、`quota_sz=1073741824`、`quota_reset_interval_ms=500`、`wmarks_high=990`、`wmarks_mid=990`、`wmarks_low=200`、`skip_anon=Y`、`wmarks_interval=1000000`。本轮未修改回收策略；回收会影响结束缓存与峰值，不能将与 Podman 的差异只归因于记账。

## OCI 输入与来源

原结果仓库的 [镜像清单](../provenance/images.json) 固定任务输入。仍存在的本机 Podman 镜像导出为 OCI；导出会重新压缩 layer，压缩 blob/config digest 可能变化。逐 blob 核验 SHA-256，核对导出 RootFS.diff_ids 及 Env/Cmd/Entrypoint/WorkingDir/User 与原 inspect 一致。此核验依赖 Podman 的 diffID 元数据，没有另做完整解压后文件系统比对。

已删除的远程输入按固定 registry digest 拉取 linux/amd64。Log4j 本机镜像已删除，因此从原 Containerfile、固定基础镜像和提交 `204d8251295dfa816b9b28d8d9cfaebab500f415` 重建；实际新 image ID 与旧值分别保留，不声称镜像逐字节相同。Matplotlib/Django 在轨迹前核对原关键文件 blob；Django 还核对原提交 ancestry 与 django 源树一致。最终修改另存 `final-source.patch`。

AgentENV 的 regctl transport 将原 image 引用和实验 alias 的 manifest/blob/copy 一并映射到同一 OCI layout，继续使用原 OverlayBD 转换。这样避免原远程 compressed digest 与本机重压缩 blob 混用。各运行 `oci-origin.json` 记录真实 manifest、config、diffID 与准备方式。

业务测量时不并行进行其他任务的镜像准备。较大的转换前，在没有 live guest 的边界停止本次服务，只删除本次 image-cache 后重启；保留 OCI、原始数据、凭据和固定依赖。服务重启造成 host-service cgroup 曲线缺口，不能按缺口插值，也不能把整个服务峰值归给单个 guest。

## 网络恢复和失败保留

主机原有 HTTP 代理可访问 registry/Hugging Face/GitHub。guest 直连曾失败，因此本轮新增临时 TCP relay：临时 loopback alias、随机端口、仅本次 guest 网段可连接；INPUT 中仅放行该地址和端口。规则后端按实际 AgentENV iptables-legacy/nft 规则识别，重启服务后重新将这一精确例外放在其 reject 之前。没有修改业务 HTTP/TLS 校验。

| 尝试 | 原因与处理 |
| --- | --- |
| 首个 Cython 完整适配 | 第 47 步 Git promisor blob 连接 reset；工具/测试证据保留，使用代理和 HTTP/1.1 后另开新 VM 补跑 |
| HF 首次完整执行 | Hugging Face 直连 TLS reset，模型权重未下载、服务验证失败；代理通路 metadata 检查通过后新 VM 重放 |
| token 镜像准备 | sudo 环境未继承 host proxy，registry 直连 EOF；在准备器中显式设置已有代理后继续，没有执行过业务调用 |
| token 首次完整执行 | 多个 Hugging Face URL TLS EOF，缺最终 answer；专用 VM 逐地址 HEAD 确认恢复后新 VM 重试，同一原输入通过 |
| CompCert 首次完整执行 | 318 步与最终编译运行检查完成，但主机旧会话代理端口失效，Dune 2.8.5 下载及五个依赖步骤额外失败；保留全曲线，修正 relay 后完整补跑 |
| CompCert 补跑预检 | 新预检误用基础镜像尚未安装的 Python，在任何原工具调用前停止；改为控制端 HEAD 与 guest Bash CONNECT 后重新开始，原失败记录保留 |

所有业务执行尝试进入 [诊断清单](../results/agentenv/diagnostics/README.md)，不与主记录混算。准备日志和网络诊断全文留在 cpu-15；公开保留运行/错误摘要与校验结果。任何后续适配失败也应追加，不能覆盖已失败尝试。

主机上游代理属于会话配置，端口可能变化。最终 relay 在每次新连接时读取本次 `host-proxy-upstream.json`；执行进度检查时用 `scripts/refresh_agentenv_upstream.py` 核对当前环境代理并更新此文件，guest 连接地址与精确 INPUT 规则不变。它不修改共享代理，不解密 TLS，不改写下载响应。原 Dune 发布地址先在控制端做 HEAD，guest 以 Bash `/dev/tcp` 验证代理 CONNECT，业务下载仍在原步骤执行。

## 复用与清理

源码入口见 [规程](../experiments/agentenv-memory/README.md)。当前服务启动器包含本机历史 seed 容器标识和 UID；`run_agentenv_workloads.py` 需要 `provenance/runs.json` 指向的完整原始输入归档，以及 CompCert 原异步屏障。迁移主机需准备对应来源。公开数值复算不依赖这些私有文件。

每个 guest 均先归档再删除。服务停止前应先结束 host sampler，把卷内原始资料复制到卷外并核验哈希，生成 VERIFIED 归档回执，最后才允许 `stop --release` 释放本次卷。清理只针对本次 label、容器、relay 进程/规则/alias 和 loop 卷；不运行全局 prune。实际清理状态见 [执行环境与收尾回执](../provenance/agentenv-environment.json)。
