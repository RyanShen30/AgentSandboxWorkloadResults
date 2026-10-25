# v2 实验回答了什么，还有哪些限制

本批 10 个新 VM 重放 652 次固定工具调用，取得 **662 个业务冻结文件扫描边界**。全部主记录与固定 Podman 参考重放的工具退出序列一致，输入 SHA-256、冻结与 CPU 稳定证明、根路径规范、控制排除和目录分区总量核对通过，直接扫描错误为零。独立检查 9 项通过；Log4j 保留原检查器 141，Maven 编译成功且原命令跳过测试。

## 文件驻留与缓存变化

[首页结果表](../README.md)同时列出整个 guest 的文件缓存近似量，以及根文件系统普通文件驻留的初始、峰值和结束值。后一项峰值只取实际扫描边界，不能视为连续真实峰值。每任务还公开按目录拆分和驻留页数。

C4 展示了两种采集为何都需要保留：周期及工具快照的总文件缓存观测峰值为 **2820.85 MiB**，工具返回后普通文件驻留的边界最大值为 **1740.62 MiB**，结束缓存为 **175.80 MiB**。只看结束值会漏掉中途占用；只看工具返回后的点也会漏掉工具内的峰值。两种统计范围和时刻不同，数值差不能解释为扫描漏测量或可共享比例。

CompCert 最终根扫描覆盖 **97,315 个普通文件**，其中 `/tmp` 为 **80,638 个**；普通文件驻留边界峰值 **1950.10 MiB**。这补齐了 v1 有限目录列表遗漏实际工具链源码/构建树的问题；目录标签仍是顶层分组，不是每个工具链的独立归因。

初始基线已经包含开机、平台进程、辅助工具与 fixture 校准。它帮助区分任务前状态和后续净变化，但不提供每页的分配时间。新 guest 的内部缓存统计解决了旧宿主总驻留与 sandbox 记账混用的问题；并不把全部 `Fend-F0` 或 `max(F)-F0` 解释为累计新分配，也不能与旧 Podman 总驻留相减计算节省率。

## 扫描期间仍会变化

业务组冻结，平台进程、探针和内核继续运行；不是整机暂停。每块两遍 mincore 中发生变化的边界共 **5 个**，按 PARTIAL 保留。即便两遍没有发现变化，也不能证明整个扫描区间各文件在同一时刻驻留。

下表的扫描前后最大绝对差来自同一边界两次 meminfo，包含回收和其他并发活动，不是探针对缓存影响的因果估计。Buffers 与文件内容驻留也不能相加当作无重叠总量。

| 任务 | 边界数 | PARTIAL | 扫描合计(s) | 扫描前后文件缓存最大绝对差(MiB) | Buffers 最大绝对差(MiB) |
| --- | ---: | ---: | ---: | ---: | ---: |
| [build-cython-ext](../results/agentenv/build-cython-ext/README.md) | 84 | 1 | 17.50 | 49.52 | 12.41 |
| [reshard-c4-data](../results/agentenv/reshard-c4-data/README.md) | 37 | 0 | 8.61 | 81.96 | 12.91 |
| [hf-model-inference](../results/agentenv/hf-model-inference/README.md) | 12 | 0 | 4.69 | 36.67 | 20.29 |
| [mozilla__pdf.js-20957](../results/agentenv/mozilla__pdf.js-20957/README.md) | 6 | 0 | 5.97 | 2.37 | 48.68 |
| [apache__logging-log4j2](../results/agentenv/apache__logging-log4j2/README.md) | 11 | 0 | 7.36 | 13.33 | 40.28 |
| [large-scale-text-editing](../results/agentenv/large-scale-text-editing/README.md) | 51 | 0 | 4.94 | 7.20 | 4.46 |
| [count-dataset-tokens](../results/agentenv/count-dataset-tokens/README.md) | 17 | 0 | 4.62 | 0.89 | 12.98 |
| [matplotlib__matplotlib-24177](../results/agentenv/matplotlib__matplotlib-24177/README.md) | 96 | 0 | 226.42 | 147.46 | 133.57 |
| [django__django-16819](../results/agentenv/django__django-16819/README.md) | 29 | 0 | 14.21 | 5.91 | 57.23 |
| [compile-compcert](../results/agentenv/compile-compcert/README.md) | 319 | 4 | 158.28 | 231.52 | 34.95 |

扫描合计 **452.60 s**，冻结控制区间合计 **462.41 s**，后者包含前者。工具时延在扫描前结束；采集会改变后续运行机会、加载元数据并影响回收，不能据此做无监控性能比较。

## 初始扫描期间的元数据扰动

Matplotlib 在首条业务工具执行前，初始根扫描区间的非空闲内存变化 **+428.55 MiB**、Slab **+303.96 MiB**、Buffers **+133.57 MiB**。同期文件缓存近似量变化为 **+1.40 MiB**，不能将这些 Slab/块元数据变化当作普通文件内容驻留增长。这说明全根遍历带来的元数据影响不能忽略。下面是每任务初始扫描的前后变化，包含平台活动和回收，并非无观察器对照的因果估计。

| 任务 | 非空闲变化(MiB) | Slab 变化(MiB) | Buffers 变化(MiB) |
| --- | ---: | ---: | ---: |
| build-cython-ext | +29.33 | +23.91 | +9.06 |
| reshard-c4-data | +48.99 | +37.56 | +12.91 |
| hf-model-inference | +62.65 | +53.35 | +20.29 |
| mozilla__pdf.js-20957 | +67.71 | +55.10 | +23.41 |
| apache__logging-log4j2 | +91.39 | +65.62 | +35.29 |
| large-scale-text-editing | +14.74 | +13.66 | +4.46 |
| count-dataset-tokens | +9.95 | +10.34 | +3.41 |
| matplotlib__matplotlib-24177 | +428.55 | +303.96 | +133.57 |
| django__django-16819 | +154.58 | +107.69 | +57.23 |
| compile-compcert | +5.70 | +5.81 | +2.79 |

本批 guest 总内存曲线含观察器与其元数据影响，**不能当作无观测时的纯业务内存需求**。Slab/Buffers 曲线与边界原始值均公开，不能简单相减就声称已去除扰动；元数据占用也可能间接影响文件页回收，F/R 同样只代表本扫描协议下的轨迹。Slab 中有可回收部分，原始 MemAvailable 与 SReclaimable 也已公开；非空闲量不能直接当作不可回收需求。未做无扫描对照，无法精确扣除这些影响。

## 仍未回答的事项

| 限制 | 对结论的影响 |
| --- | --- |
| guest 命令计时，未采集逐工具 AgentENV RPC 往返 | 不能作为完整 agent 工具 API 延迟；异步启动耗时也不等于后台任务寿命 |
| 每任务一次主记录，host backing 冷暖未控制 | 可描述本次轨迹，不能作统计性能或平台节省比较 |
| mincore 扫描非原子，未冻结内核和平台进程 | 只能给出扫描区间内的驻留观测，不能声称同一瞬间的精确物理快照 |
| 观察器与全根元数据遍历有开销 | 已单列成本和前后变化，但没有无观测对照，不能精确扣除影响 |
| 根文件系统可达普通文件范围 | 不含已删除仍映射文件、其他挂载、符号链接和控制路径；整体缓存无法完全逐文件归因 |
| 阶段标签按原命令窗口生成 | 安装后缓存可延续到其他窗口，混合调用保持原样，不能识别每页来源 |
| 没有 host PFN 去重、多 VM 共享、DAX 对照 | 文件驻留不等于可共享物理页，不能推出共享率或 DAX 收益 |
| 原 benchmark 局部验证范围保持 | Django 仅语法检查，token 仅实际 26 行，Log4j 跳过测试；未重新评定模型解题正确性 |

前三次存在根路径缺陷的完整尝试另列诊断；最终主记录采用修正采集器的新 VM 重放，不混入旧数值。历史 v1 也保留，不能把其每任务三个扫描点改称逐工具扫描。

[论文任务初筛与后续计划](paper-workload-screening.md) · [完整口径](agentenv-measurement.md) · [部署与失败恢复](agentenv-deployment.md) · [可复算字段](../experiments/agentenv-memory/README.md) · [选择清单](../provenance/agentenv-runs.json)
