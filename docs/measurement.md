# 测量口径与解释边界

本轮目标是检查固定公开工具轨迹能否重放，并得到工具时延、容器内存和逐工具文件驻留曲线。各任务单实例顺序运行，各配置只运行一次。没有新生成 Agent 轨迹；未测模型推理延迟、多租户共享页或 DAX 收益。

## 工具时延

`steps.jsonl.gz` 的 `tool_seconds` 是容器内单调时钟围住实际工具命令的时间。普通命令由静态 C 计时器 fork/wait Bash；Log4j2 和 Django 使用持续 Bash 与 CLOCK_MONOTONIC 小程序计时，保留函数、cwd 和环境变量。`controller_exec_seconds` 另含 Podman 调度与传输开销，不混入工具执行统计。

原始 read/write 工具以文件读取/写入脚本桥接。read 会读取完整文件字节并输出记录的行范围（CompCert 使用静态 C 桥接），并未复现源工具的语义摘要算法。因此是适配后真实文件操作时延。所有变化和脚本 SHA-256 在各 run 的 `normalized-steps.json.gz`。

CompCert 的 `async=true` 采用真实后台启动；该工具时延为启动耗时，后续原始 sleep/poll 仍执行。按源异步完成通知，在九个依赖点额外等待对应任务完成，保存在 `async-barriers.jsonl`，不计入工具时延。后台内存一直在容器 cgroup 中采样；冻结会同时停止这些进程。

## 连续内存

约每 200 ms 从容器 cgroup v2 读取：

| 字段 | 含义 |
| --- | --- |
| memory_current_bytes | `memory.current`：该 cgroup 当前内存计费，包含匿名页、被计费文件页与内核等 |
| memory_peak_bytes | 内核 `memory.peak`：自该容器 cgroup 创建起的高水位，可能包含预检 |
| anon_bytes | `memory.stat anon`，匿名内存，不是应用堆的精确拆分 |
| file_bytes / shmem_bytes | cgroup 文件类页 / 共享内存与 tmpfs 类页计费 |
| disk_file_charge_bytes | `max(0, file - shmem)`，被此 cgroup 计费的磁盘文件页近似 |
| file_mapped_bytes / file_dirty_bytes | 已映射文件页 / 脏文件页计费 |
| pids_current / cpu_usage_usec | 容器进程数及 cgroup CPU 累计时间，作为辅助记录 |

内核峰值与采样曲线的最大值分别列出，200 ms 采样可能漏过短峰值。文件页的计费可能属于先前预热的其他 cgroup，因此大文件驻留与本次容器 file 计费不一致是允许的。各分量峰值可能不同步，不能将峰值相加。

`memory.events.max>0` 说明触及配置限额并触发回收路径等事件，不等同于 OOM；`oom` 与 `oom_kill` 分别表示内存分配进入 OOM、OOM 杀进程事件。CompCert 8 GiB 原记录 max=31，oom=oom_kill=0；32 GiB 复测三者为 0。

## 冻结边界文件驻留（本仓库的 Page Cache 曲线）

1. 工具结束后 `podman pause`，读取 `cgroup.events`，只有 `frozen=1` 才扫描；CompCert 最终采集器会等待确认，最多 30 秒。全部已发布边界均有确认记录。
2. 从宿主侧遍历 `/proc/<容器 init pid>/root` 下同设备的普通文件；跳过 proc/sys/dev/run/probe、符号链接及其他设备，排除非当前宿主 euid 拥有的文件。
3. 打开文件，`mmap(PROT_NONE, MAP_SHARED)` 后调用 `mincore`，只查询驻留位，不触碰映射中的文件数据。目录遍历、打开文件等元数据操作仍有开销；“不读文件数据”不表示探针对系统完全无扰动。
4. 两遍扫描，以 dev/inode/页偏移去重硬链接，记录第二遍驻留总量、两遍共同驻留、变化页数、目录分区和前 20 大驻留文件，再 `podman unpause`。
5. 工具开始前采一次基线，之后每步一次，共 N+1 个边界。全量序列保存在 `boundaries.jsonl.gz`。

驻留 bytes 为驻留页数 × 4096，最后不足一页也计整页，因此可能大于文件逻辑大小。两遍 changed_pages=0 仅说明两次探测结果稳定，不证明某页属于本任务独占或保证扫描时全机静止。共享宿主其他进程仍可能改变缓存。

扫描器主动排除非当前宿主用户拥有的文件，以避开 Linux 对缺少适当权限的 mincore 查询返回全驻留的情况。该过滤较保守：部分非拥有者文件可能具备足够权限，但本轮未进一步判断。排除量是已知缺口，不以 0 填补其真实驻留。普通文件去重也不等同于跨 inode 的物理 PFN 去重。

目录标签 `input_dataset`、`model_cache`、`dependencies`、`git_metadata` 是扫描器对特定路径前缀的分类，不是真实顶级目录。其他分类为路径第一段。具体映射见 [cache_scan.py](../experiments/container-screening/harness/cache_scan.py)。

## 采样校准与权限

`cache-calibration.json` 使用新建的私有 8 MiB 文件，对该文件执行 DONTNEED，验证反复扫描不使其变暖，随后真实读取应变为 8 MiB 驻留。`overlay-cache-calibration.json` 另验证容器 overlay 场景。这些校准不是对所有业务文件全局清缓存；业务轨迹的初始缓存均实测，镜像解压/准备可能预热缓存。

[校准证据](../provenance/collection-checks/cache-calibration.json) · [overlay 校准](../provenance/collection-checks/overlay-cache-calibration.json) · [冻结确认检查](../provenance/collection-checks/freezer-ack-check.json)

## 时间轴与未测项

参照 [AgentCgroup 图 5、6](https://arxiv.org/pdf/2602.09345v3#page=4)，每个 run 的内存与 Page Cache 面板共用时间轴，并同步标记工具执行区间；工具时延单独按调用序号画柱状图。本仓库按所需指标保留工具时延和 Page Cache 面板，没有增加 CPU 面板。

每份运行提供两种视图：

- `curves.png/svg` 为完整测量墙钟图。蓝色阴影是容器内 `started_ns` 到 `finished_ns` 的工具执行区间，浅灰色背景是从请求暂停到恢复容器的暂停/扫描区间，金色点纹是已有记录中的异步依赖等待区间。白色空隙包含调度等控制开销，不代表模型思考。
- `curves-active.png/svg` 为去除暂停的辅助图。横轴为原墙钟减去累计暂停时间，同一变换应用于内存和 Page Cache 两个面板，工具时延柱状图保持不变；调度、异步等待仍保留。暂停期间采集的内存样本映射到被压缩的边界，以灰点显示，避免丢掉暂停期间出现的峰值。这是显示变换，不是无探针干扰下的 Agent 性能。

第一幅横轴为工具调用序号，纵轴为该次调用的总时延，每次调用一根柱子，空心点表示非零退出。内存和缓存面板中的背景阴影另行标出工具实际起止区间。第二幅显示连续采集的 `memory.current` 和匿名内存。第三幅标题明确为 Page Cache：蓝色圆点是两遍扫描结束时的文件缓存驻留量，扫描点之间不插值，不把离散扫描画成连续测量。cgroup 的 `file - shmem` 计费仍保留于样本与结果表，不叠加在这幅扫描驻留图上。扫描仍只覆盖当前宿主用户拥有的根文件系统普通文件，不是完整 guest Page Cache。

内存、缓存与工具执行区间的时戳来自同一单调时钟，以 run 开始为零点；时延柱状图的横轴是调用序号。完整图保留基线、调度、暂停扫描与后台等待；验证在轨迹测量结束后进行，不进入连续曲线。部署/拉镜像、原模型思考间隔不在图中。时间轴与转换的逐运行校验见 [timeline-validation.json](../provenance/timeline-validation.json)。

扫描开销不能忽略：Matplotlib 每个边界两遍扫描的中位数合计约 22 秒，而全部工具合计不足一分钟；CompCert 暂停累计约 45 分钟。完整墙钟图保留这些开销，辅助图用于查看工具与资源变化的对应关系。

本轮未测实际 read/write 字节量、逐文件访问频率、缺页计数、唯一 PFN、跨租户共享率、guest 物理内存、DAX 或多并发性能。镜像大小、逻辑文件大小、文件驻留、cgroup file 计费和实际 I/O 是不同指标。

图形选择及 AgentCgroup 原图核对见[图表设计依据](figure-design.md)。单任务内存与缓存图根据量级使用 MiB 或 GiB，跨任务及 CompCert 配置对照保持相同单位。
