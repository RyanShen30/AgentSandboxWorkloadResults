# AgentENV：guest 文件缓存测量口径

本轮将 2026-10-20 的十条主轨迹迁移到 AgentENV，各保留一次完整主记录。目标是测量**独立 guest 内的文件缓存**，补上旧 Podman 结果的记账范围缺口。固定工具输入，不调用模型 API；输入内容与原归档逐文件 SHA-256 核对。所有实际执行过的失败尝试也保留，主记录选择见 [运行清单](../provenance/agentenv-runs.json)。

## 三种范围

| 范围 | 本轮字段 | 解释 |
| --- | --- | --- |
| guest 连续文件缓存 | `max(0, Cached-Shmem)` | 来自 guest `/proc/meminfo`，近似磁盘文件缓存；原始 Cached、Shmem、Buffers 均保留，Buffers 不并入该近似量 |
| guest 指定文件驻留 | 边界 `resident_bytes` | guest 内对声明路径的普通文件做 `PROT_NONE mmap + mincore`，按 inode/offset 去重；仅覆盖列出的根路径 |
| 私有服务 cgroup | host-service CSV | 整个私有 AgentENV 服务的主机记账，包括服务、VMM 和 backing 等；不等于 guest 文件缓存，也不是主机物理页去重结果 |

guest 总量用 `MemTotal-MemFree`，另列 MemAvailable、AnonPages、Slab、页表等。它与 Podman 的 `memory.current` 定义不同。原始字段单位为 bytes，时间为 ns/s；图表采用 MiB=2²⁰ bytes。

旧 Podman 的 `memory.stat file-shmem` 表示该 cgroup 被记账的磁盘文件页。共享页由其他 cgroup 先分配时，不一定转归后来使用它的容器；“启动前分配”并非自动排除规则，真正区别是页的记账归属。[Linux cgroup v2：Memory Ownership](https://docs.kernel.org/admin-guide/cgroup-v2.html#memory-ownership)。旧宿主 mincore 的全文件驻留也不等于容器记账。**不能将旧驻留量减去旧 cgroup 峰值，或把本轮与旧轮的差值称为节省内存。**

## 基线与时间窗口

每任务新建 cold-start VM，2 vCPU、8192 MiB RAM；CompCert 为 32768 MiB。cold start 仅表示新 VM，host backing 的冷暖未控制。保持官方 guest 内核 6.1.175 与 DAMON reclaim 默认配置，未进行全局 drop_caches。

业务开始前已经完成开机、工具辅助文件上传、专用 16 MiB fixture 校准及必要的源码身份检查。fixture 已删除。此时读取 F0，随后做 B0 文件边界扫描。原轨迹包含的 pip/npm/模型下载仍在原命令位置执行，没有提前安装业务依赖或下载模型权重。

CompCert 最终主记录还在 F0 前完成控制端 Dune 发布 URL 的 HEAD，以及 guest Bash 的代理 CONNECT 检查；没有预下载该发布包或在最小镜像里预装 Python。这一预检及上游配置变更单独记录。

轨迹中只做一次中间文件扫描，完整结束后先读取 Fend、再做最终文件扫描。连续监控覆盖这些扫描，并在图中以灰带标出。轨迹结束后的独立验证不进入内存测量窗口。结束值不包含独立验证造成的缓存。

| 汇总字段 | 定义 |
| --- | --- |
| initial | 第一次扫描前 F0 的 Cached-Shmem |
| observed peak | 非 `cache_scan/complete` 阶段的周期样本、每工具前后快照、F0 和 Fend 中的最大值 |
| final | 最终文件扫描前 Fend 的 Cached-Shmem |
| net change | Fend−F0，允许负数；不是新增分配总量或读取字节量 |
| tool_seconds | guest 单调时钟包围原工具调用；不含文件扫描和独立验证；原 sleep/poll 保留 |
| measurement span | F0 到 Fend 的跨度，包含中途扫描和异步依赖等待；与工具合计存在包含关系 |

扫描发生后的元数据缓存与后续回收会影响后面的工具；排除扫描区间的样本不能消除这种影响。本轮没有采样开关配对试验，不能声称测量零扰动，也不将旧 Podman 时延作为平台性能比较基线。极短工具的峰值仍可能漏采，因此始终称“观测峰值”。

## 采样与文件扫描

静态 C 采样器约每 200 ms 读取 16 个 meminfo 字段，日志写入已有 guest tmpfs `/dev/shm/aswr-work`。tmpfs 消耗反映在 Shmem 和总内存中；文件缓存近似量将其扣除。每工具前后还读一次 meminfo；持续 shell 的工具采用相同边界计数。监控的实际间隔、最大缺口、CPU 时间和 maxrss 保留在 run/summary 中。超过 600 ms 的缺口在折线中断开，不插值补齐。

文件探针遍历声明路径，以 dev/inode 去重硬链接并避免重叠根重复计数；跳过符号链接、特殊文件和其他文件系统。每 64 MiB 分块，连续两次 mincore，记录 resident、stable resident 与变化。上限为 50 万文件或 90 秒，超限/错误标为 PARTIAL；不存在的路径记为 MISSING，不当成测得零。目录归属是按声明根的先后顺序增量分配，不能把后列的 `/app` 当作其全部子树的独立总量。

mincore 的两遍检查不是对整棵目录的原子快照，扫描时回收/后台进程仍可能改变驻留。`resident_bytes` 按页向上取整，可能略大于文件逻辑长度。此处不读取文件数据，不返回 PFN；不同 inode 的相同内容不做物理去重。

CompCert 的声明根包括 `/tmp/CompCert` 和 `/usr/local/lib`，没有列出实际的 `/tmp/rocq-*`、`/tmp/ocaml-*`、`/tmp/dune-*` 构建树。因此该任务的 mincore 点不代表全部工具链文件；声明的 `/tmp/coq-8.16.1` 若不存在会明确标为 MISSING。连续 Cached-Shmem 仍覆盖整个 guest，不受声明目录列表限制。

每个主/诊断运行均先校准本次创建的 16 MiB 普通文件：fsync + 对该 fixture 的 FADV_DONTNEED 后冷扫描应为零；重复冷扫描仍为零；实际读取后应为 16 MiB。校准回执保留在各运行目录。没有对业务文件执行 DONTNEED。

## 轨迹、验证与适配

完整保留原命令、工作目录、原预期非零退出、read/write 文件桥接、Log4j/Django 持续 shell、CompCert 后台构建与原依赖屏障。所有新运行的 workload umask 为 0077，与旧容器可能不同；本轮不评估权限隔离。网络采用已有主机 HTTP 代理的临时窄端口 relay，Git 仅在业务进程中设 HTTP/1.1；SWE 镜像仅对 `/testbed` 设置进程级 safe.directory。源命令内容未改写为预期答案。

任务验证沿用原范围：C4 全量 9,898 文件内容/结构往返，CSV 字节比对，HF 正负样例，Cython 扩展导入与两轮各 18 测试，token 的 79,586 答案，CompCert 编译运行，Matplotlib 原局部测试，Django 仅语法检查。源 benchmark 的模型修复正确性未重新判分。

Log4j 的原编译命令跳过测试；其检查器使用 `find | head` 配合 pipefail，退出 141 原样保留。编译 BUILD SUCCESS、工具退出码与检查器状态分开报告，不将检查器改成 0。诊断记录中的额外网络错误也不改写为平台成功。

## 可复算内容与未测项

每运行公开 `memory.csv`、`steps.csv`、F0/Fend、文件边界、固定输入、源/镜像身份、实际 guest 控制脚本、校准/验证摘要、PNG/SVG 和哈希。SWE 任务另存最终补丁及初始源码身份。完整 stdout/stderr、二进制辅助程序和私有服务归档保留在 cpu-15；凭据及原对话不公开。

公开 CSV 可直接校验并重画，无需私有日志：

```bash
python3 scripts/rebuild_agentenv_public.py --root . --verify-only
python3 scripts/rebuild_agentenv_public.py --root .
```

本轮每任务一次，无实验重复或置信区间；轨迹内工具时延分位数不代表独立重复。没有系统调用级实际读写量、完整工作集、host PFN 集合、跨 VM 共享、DAX 对照或节省比例。不同内核、guest 启动状态、DAMON、镜像转换和缓存范围均会影响与旧轮的差异。
