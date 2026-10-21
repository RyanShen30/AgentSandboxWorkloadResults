# 环境搭建与部署

> 公开范围：本次只提交文档、图表、汇总/CSV、配置与脚本。完整原始日志、轨迹和重放输入包保留在 cpu-15；重算/重放须提供 ASWR_ARCHIVE_ROOT，见[数据说明](../data-and-sources.md)。
本轮使用 cpu-15 上普通用户的 rootless Podman。复算已归档数据只需要 Python/Matplotlib，不需要 Docker、KVM 或任何任务镜像；重放任务才需要下面的容器环境。本文给出从新 checkout 准备独立运行目录的步骤，原采集器源码保留在仓库中。

## 实际宿主与权限

| 项目 | 本轮记录 |
| --- | --- |
| 主机 / 用户 | cpu-15 / rashen，uid 1012 |
| CPU | Intel Xeon Platinum 8562Y+，2 sockets × 32 cores × 2 threads，共 128 逻辑 CPU |
| 宿主 RAM | 约 503.4 GiB；与磁盘剩余空间是不同资源 |
| 系统 / 内核 | Ubuntu 24.04.2 LTS / 6.19.9+，x86_64 |
| Python / 报告库 | Python 3.12.3；Matplotlib 3.6.3；NumPy 1.26.4 |
| 容器 | Podman 4.9.3，rootless，overlay，slirp4netns，用户 cgroup v2 |
| 单任务限额 | 2 CPU 配额，不是固定绑核；8 GiB memory，CompCert 复测 32 GiB；memory+swap 同 memory，复测有效 swap.max=0；pids 1024；/dev/shm 256 MiB |
| 采样 / 执行 | 约 200 ms 连续内存；每个工具后冻结、两遍 mincore 扫描；顺序任务 |
| 虚拟机权限 | 当时账号不可访问 KVM、sudo 需密码；平台不可用，确认采用容器初筛 |
| 磁盘 | 共享宿主可用空间随时间变化，CompCert 复测开始约 57.8 GiB；不是数百 GiB 可用磁盘 |

CPU、内存、Podman 快照见 [host-info.json](../../provenance/collection-checks/host-info.json) 与 [podman-info.json](../../provenance/collection-checks/podman-info.json)。OS/Python 版本在报告整理时复核；历史宿主快照中磁盘与 RAM available 是该采集时刻的值，不代表整个实验期间固定值。

8 GiB 是当时初筛主动设置的每容器限额，不是服务器的 RAM 上限。32 GiB 复测需要宿主留出对应内存余量。每任务准备前至少 30 GiB 可用磁盘；运行中低于 20 GiB，采集器停止该任务并清理容器。第一批监控采样本身不记录磁盘曲线；第二批有辅助 free-disk 字段。本轮没有完整磁盘高水位测量。

## 宿主依赖

需要已配置的普通用户 rootless Podman、用户 cgroup memory/cpu/freezer 委派、可访问容器 `/proc/<pid>/root`、静态 C 编译工具及网络。常见 Ubuntu 管理员安装项：

```bash
sudo apt-get update
sudo apt-get install podman uidmap slirp4netns fuse-overlayfs gcc libc6-dev git python3 python3-venv
```

绘图还需要 `python3-matplotlib` 与 `python3-numpy`（cpu-15 已安装，当前 Python 可直接使用）。`requirements-report.txt` 记录本轮生成图表的版本；系统发行版可能带有 Python 兼容补丁，不把 PyPI 旧版本在任意 Python 下的重新安装当作已验证步骤。

这些是新机器部署参考，不是本轮执行的系统修改。若当前账号没有 sudo，由管理员准备宿主依赖与 subordinate uid/gid 映射即可；采集器不需要日常以 root 运行。`subuid/subgid` 范围因主机不同，不应直接照抄别人的数值。

先做只读检查：

```bash
id
podman --version
podman info --format '{{.Host.CgroupVersion}} {{.Host.CgroupManager}}'
cat /proc/self/cgroup
cat /sys/fs/cgroup/cgroup.controllers
command -v gcc
```

实验使用的用户 cgroup 管理器为 systemd。实际容器启动后采集器检查 memory.current、memory.stat 和 cgroup.events；没有这些指标、无法冻结或无法扫描根文件系统就报错，不以宿主全局内存代替。

## 克隆与创建独立运行目录

```bash
git clone https://github.com/RyanShen30/AgentSandboxWorkloadResults.git
cd AgentSandboxWorkloadResults
python3 scripts/materialize_replay.py \
  --workspace /home/rashen/work/AgentWorkloadReplay-new \
  --compile
```

部署脚本只创建文件并编译三个静态探针，不运行任务或拉镜像。运行目录必须为空；脚本展开已归档的固定 `tool-steps.json`、约束和环境输入，复制原采集器，并将唯一固定的 Podman runroot 改为按 uid/目录区分的 `/tmp/aswr-...`。源/部署副本哈希和这处路径调整记录在 `runtime-layout.json`。根目录由原采集器的 `__file__` 决定，不依赖原服务器绝对路径。

目录中包括独立的 `state/storage`、`sources`、`results`、`preparation`。原 2026-10-20 存储仍为 `/home/rashen/work/AgentWorkloadProbe-20261020/state/storage`，runroot 为 `/tmp/asbp-1012-20261020`；新目录使用自己的存储，两者不会自动混用。

## 镜像准备

全部任务的 registry digest、实际 image ID 与运行限额在 [images.json](../../provenance/images.json)。除两个本地构建镜像外，均按 digest 拉取。每次只准备并运行一项，避免十份镜像同时占用磁盘：

```bash
python3 scripts/prepare_image.py \
  --workspace /home/rashen/work/AgentWorkloadReplay-new \
  --task reshard-c4-data --dry-run

# 确认部署条件后准备该项镜像
python3 scripts/prepare_image.py \
  --workspace /home/rashen/work/AgentWorkloadReplay-new \
  --task reshard-c4-data
```

`--dry-run` 只输出命令。本轮整理时验证了十项 dry-run 与脚本语法；没有为写文档重新运行任务或重新构建镜像。真正执行过的镜像构建和轨迹见历史 run/image ID。

- PDF.js：固定 Node digest 与源码 base commit `484518614d75c1ac1f1a8db41c943774b5231de6`，本地镜像名 `localhost/asbp-pdfjs:484518614d75`，定义见 [pdfjs.Containerfile](../../experiments/container-screening/environments/pdfjs.Containerfile)。依赖安装在测量轨迹中执行。
- Log4j2：固定 EnvBench JVM digest 与项目提交 `204d8251295dfa816b9b28d8d9cfaebab500f415`，本地镜像名 `localhost/asbp-log4j2:204d8251295d`；镜像只复制源码。[Containerfile](../../experiments/container-screening/environments/log4j.Containerfile) 使用 `--format docker` 构建，以保留基镜像的 SHELL 配置。SDKMAN/JDK 初始化属于公开调用。
- Matplotlib：镜像存在无法映射到当前 rootless 范围的 UID/GID 197609/197121，导入时仅在专用存储使用 `--storage-opt overlay.ignore_chown_errors=true`。内容 digest 固定，所有权可能归并为默认 UID；不能用于文件权限隔离结论。[兼容性记录](../../provenance/collection-checks/matplotlib-ownership-compatibility.json)。

本地镜像的构建时间与新 image ID 可能变化，不能只依赖 localhost 标签判断内容。要记录新的 ID、基础 digest、源码提交和 Containerfile 哈希。上游 apt/npm/pip、tokenizer 和部分数据 URL 没有全部冻结为离线快照，因此这套重放不是封闭、逐字节可重复的依赖构建。

## 网络与代理

拉镜像使用宿主网络配置；新部署入口中的 PDF.js 构建使用 `--network host`，以便使用宿主已有的 loopback 代理。任务运行仍使用独立的 slirp4netns 网络。任务内部有 pip、npm、wget、模型和源码下载。rootless slirp4netns 启用 allow_host_loopback，采集器把已有代理环境中的 `127.0.0.1/localhost` 地址映射为容器可用的 `10.0.2.2`，不在仓库内保存认证信息。

第二批不向容器传 ALL_PROXY，以避免 HF 客户端因 SOCKS 组件缺失初始化失败。若更换服务器，先保证 HTTP/HTTPS 代理（如确实需要）在该机可用；不要原样抄服务器的端口。CompCert wget 仅对网络/TLS 退出 4/5 做有界重试，不修改 URL 或吞掉 HTTP 错误；网络重试仍计入该工具时延。

## 重放、断线与清理

单任务命令及 runner 对照见[实验规程](../../experiments/container-screening/README.md)。运行期间连续采样、冻结和扫描由同一脚本控制，不需要人工逐轮暂停。

长任务可从服务器的持续会话启动，或使用用户 systemd 服务。例如部署到上述运行目录后：

```bash
systemd-run --user --unit=aswr-compcert32 \
  --property=RuntimeMaxSec=21600 \
  --working-directory=/home/rashen/work/AgentWorkloadReplay-new \
  /usr/bin/python3 -u runner_compcert32.py compile-compcert --ack-container-metrics
journalctl --user -u aswr-compcert32 -f
```

服务脱离终端，但用户服务能否在最后一个登录会话退出后保留还取决于 linger 设置。需要长期断线运行时由管理员确认这一点；不要把 Codex 对话是否在线当作实验进程的生命周期。本轮长任务临时启用过 linger，结束后恢复为 no，归档时无活动实验服务。

runner 的 finally 删除实验容器，保留数值、日志和命令；单独执行 runner 不自动删除镜像。原第二批队列与复测入口还删除当轮新镜像。新机器清理时按 `runtime-layout.json` 的专用 root/runroot 和本轮确切 image ID 执行 `podman rmi`，不要对其他实验的共享存储做全局 prune。
