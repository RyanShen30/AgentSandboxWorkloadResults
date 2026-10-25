"""Write the repository landing page from explicit published AgentENV summaries."""
import argparse
import json
from pathlib import Path


def build(root):
    records=json.loads((root/'results/agentenv/summary.json').read_text())
    assert len(records)==10 and sum(r['actions'] for r in records)==652
    assert all(r['strict_exit_match'] for r in records)
    labels={
        'build-cython-ext':'扩展导入、两轮各 18 测试通过',
        'reshard-c4-data':'9,898 文件全量内容/结构往返通过',
        'hf-model-inference':'HTTP 服务正负样例通过',
        'mozilla__pdf.js-20957':'两轮 CLI 测试通过',
        'apache__logging-log4j2':'Maven 编译成功；跳过测试；检查器 141',
        'large-scale-text-editing':'输出字节比对通过；不改原判题结论',
        'count-dataset-tokens':'79,586 答案检查通过；实际计数 26 行',
        'matplotlib__matplotlib-24177':'最终两轮 60 passed；补丁与旧记录一致',
        'django__django-16819':'仅原范围语法检查通过',
        'compile-compcert':'最终编译器编译运行检查通过',
    }
    rows=[]
    for r in records:
        values=' → '.join(f"{r[k]/2**20:.1f}" for k in (
            'guest_initial_file_cache_bytes','guest_peak_observed_file_cache_bytes',
            'guest_final_file_cache_bytes'))
        residency=''
        if r.get('protocol')=='agentenv-frozen-tools-v2':
            residency=' → '.join(f"{r[k]/2**20:.1f}" for k in ('initial_declared_file_resident_bytes','observed_boundary_file_resident_peak_bytes','final_declared_file_resident_bytes'))+' | '
        rows.append(f"| [{r['task_id']}](results/agentenv/{r['task_id']}/README.md) | {r['actions']} | {r['tool_seconds']:.2f} | {values} | {residency}{labels[r['task_id']]} |\n")
    if all(r.get('protocol')=='agentenv-frozen-tools-v2' for r in records):
        build_frozen(root,records,rows)
        return
    text='''# Agent Sandbox Workload Results

最新实验于 **2026-10-23 至 24（Asia/Shanghai）** 在 cpu-15 的 AgentENV microVM 中完成：**10 个任务、652 次固定工具调用**，约每 200 ms 采集 guest 内存，每任务 3 个指定文件驻留边界。输入沿用原轨迹，不调用模型 API；失败尝试也单独归档。

这轮测量“**独立 guest 中有多少文件缓存**”。旧 Podman 初筛完整保留在 [2026-10-20 历史报告](PODMAN-20261020.md) 和 [旧结果索引](results/README.md)。宿主文件驻留、容器 cgroup 记账和 guest 文件缓存的范围不同，不能互相替代。

## 最新 AgentENV 结果

每项新建独立 VM，2 vCPU，除 CompCert 为 32 GiB 外均为 8 GiB RAM。下表缓存采用 guest `max(0,Cached-Shmem)`，Buffers 单列保存在 CSV；单位 MiB=2²⁰ bytes。峰值合并轨迹阶段周期样本、工具前后快照及 F0/Fend，排除扫描区间的周期样本。

| 任务 | 调用数 | 工具合计 (s) | guest 文件缓存 初始→观测峰值→结束 (MiB) | 实际验证范围 |
| --- | ---: | ---: | --- | --- |
'''+''.join(rows)+'''
全部主记录的工具退出码与原 Podman 重放记录一致；原预期非零调用仍保留。Log4j 的原检查器退出 **141**，没有改写成通过；其 Maven BUILD SUCCESS 与检查器状态分别报告。任务完成和局部验证不代表源 benchmark 的模型修复正确性。

![AgentENV guest 文件缓存](results/agentenv/overview.png)

[详细结果索引](results/agentenv/README.md) · [汇总 CSV](results/agentenv/summary.csv) · [汇总 JSON](results/agentenv/summary.json) · [矢量图](results/agentenv/overview.svg) · [失败与诊断尝试](results/agentenv/diagnostics/README.md)

每个任务页面含工具时延、guest 总内存/匿名内存/文件缓存三幅曲线，以及连续 CSV、工具 CSV、首尾快照、指定文件 mincore 边界、校准、验证、镜像和代码身份。固定可执行输入与实际 guest 控制脚本也公开。完整 stdout/stderr 和二进制归档保留在 cpu-15，不公开凭据或原对话。

## 结果边界

本轮采用新 guest，未控制 host backing 的冷暖，保持官方 guest 内核 6.1.175 与 DAMON 默认回收策略。初始值包含开机、辅助工具和校准后的状态；源轨迹中的业务安装/下载仍在原位置执行。结束值取自最终扫描和独立验证之前。

指定文件驻留只覆盖 `run.json` 声明路径的普通文件；它与整个 guest 的 Cached-Shmem 范围不同。CompCert 声明列表未覆盖 `/tmp/rocq-*` 等全部工具链源码目录，不能把其 mincore 点当作完整文件工作集。文件驻留扫描不提供实际读写字节量或 host PFN 去重。

每任务仅一次主记录，没有重复统计或置信区间。与旧 Podman 的差异同时受记账范围、guest 缓存状态、内核、DAMON 和测量协议影响，**不据此推导跨沙箱共享率、DAX 收益或内存节省比例，也不作为配对性能比较**。

## 核查与复算

[测量口径](docs/agentenv-measurement.md) · [部署与失败恢复](docs/agentenv-deployment.md) · [重放规程与采集代码](experiments/agentenv-memory/README.md) · [运行选择清单](provenance/agentenv-runs.json) · [校验回执](provenance/agentenv-validation.json) · [环境与清理回执](provenance/agentenv-environment.json)

仅用公开数据即可复算新摘要并重画；不重新执行业务任务：

```bash
python3 -m pip install -r experiments/agentenv-memory/requirements-analysis.txt
python3 scripts/rebuild_agentenv_public.py --root . --verify-only
python3 scripts/rebuild_agentenv_public.py --root .
python3 scripts/verify_archive.py
```

重画图片可能因字体/绘图库版本而改变图片哈希；数值哈希单独校验。若有意更新图片，再用 `python3 scripts/verify_archive.py --write-manifest` 刷新公开文件清单。旧 `build_results.py` 仍需 cpu-15 完整原始归档，重建的历史首页写入 `PODMAN-20261020.md`。
'''
    (root/'README.md').write_text(text)


def build_frozen(root,records,rows):
    boundaries=sum(r['file_boundaries'] for r in records)
    assert boundaries==662 and all(r['frozen_boundary_count']==r['actions']+1 for r in records)
    partial=sum(r['partial_scan_boundaries'] for r in records)
    scan=sum(r['boundary_scan_seconds'] for r in records)
    control=sum(r['boundary_control_seconds'] for r in records)
    mat=next(r for r in records if r['task_id']=='matplotlib__matplotlib-24177')
    text=f'''# Agent Sandbox Workload Results

最新批次为 **2026-10-24 至 25 的 AgentENV v2 逐工具冻结扫描补测**：10 个任务、652 次固定工具调用、**{boundaries} 个文件驻留边界**（每任务初始点加每次工具返回后的点）。同一任务在一台新 VM 内顺序重放，保留原命令、预期非零退出、持续 Shell 与后台任务；不调用模型重新规划。

交付三类数据：逐工具时延、约 200 ms 的 guest 内存曲线、guest page cache 与逐工具文件驻留曲线。业务 worker 及其后台进程进入本次 guest cgroup，边界验证 `frozen=1` 与 CPU 不推进后扫描，再解冻。**暂停的是业务进程，不是整台 VM**；guest 探针与内核仍可运行。cgroup 用作冻结控制；宿主服务 cgroup 只作辅助监控。

[结果解释与限制](docs/agentenv-results.md) · [论文任务初筛](docs/paper-workload-screening.md) · [阅读与指标说明](docs/README.md) · [完整测量协议](docs/agentenv-measurement.md) · [部署与补测记录](docs/agentenv-deployment.md) · [运行与复算](experiments/agentenv-memory/README.md)

## 最新结果

2 vCPU；除 CompCert 为 32 GiB 外均为 8 GiB guest RAM。下表分别给出 **整个 guest 的 `max(0,Cached-Shmem)`** 和 **根文件系统普通文件的 mincore 驻留量**，Buffers 另列。前者峰值合并非扫描阶段周期样本与工具前后快照，后者仅为冻结边界中的最大值；两者范围与时刻不同，不能相加。单位 MiB=2²⁰ bytes。

| 任务 | 调用数 | 工具合计 (s) | guest 文件缓存 初始→观测峰值→结束 (MiB) | 文件驻留 初始→边界峰值→结束 (MiB) | 实际验证范围 |
| --- | ---: | ---: | --- | --- | --- |
'''+''.join(rows)+f'''
![guest 文件缓存概览](results/agentenv/overview.png)

全部 652 次工具退出码与固定 Podman 参考重放一致；`replay-inputs.json.source_exit_code` 是原轨迹元数据，二者来源不同。严格重放一致不等于原 benchmark 的全面正确性。

[任务索引与曲线](results/agentenv/README.md) · [汇总 CSV](results/agentenv/summary.csv) · [汇总 JSON](results/agentenv/summary.json) · [诊断与失败尝试](results/agentenv/diagnostics/README.md)

每个任务另有 **逐工具冻结边界图**：guest 总占用、总文件缓存、根文件系统普通文件驻留，以及按顶层目录分组的驻留。`boundaries.csv/json` 保留冻结证明、扫描前后计数、覆盖和排除项；`steps.csv` 保留时延、退出码和阶段标签；`phase-summary.csv/json` 区分明确的安装下载、混合动作和其余任务/检查窗口。

## 采集影响与结果边界

本批扫描合计 {scan:.2f} s，冻结控制区间合计 {control:.2f} s；二者存在包含关系，不能相加。工具计时在扫描前结束，扫描成本单列；时延只含 guest 命令执行，模型耗时和 AgentENV RPC 往返另属其他口径。全根遍历可能加载目录/文件系统元数据并影响后续回收，排除扫描阶段样本不能消除这些影响；本批不用于平台速度比较。

**总内存曲线存在显著采集扰动。** Matplotlib 在首条业务工具执行前的根扫描期间，非空闲内存变化 {mat['initial_scan_nonfree_change_bytes']/2**20:+.2f} MiB，Slab {mat['initial_scan_slab_change_bytes']/2**20:+.2f} MiB，Buffers {mat['initial_scan_buffers_change_bytes']/2**20:+.2f} MiB。这些是扫描前后观测，不能当作无扫描对照的因果差值；总内存曲线包含观察器与元数据，不能用作纯业务内存需求。文件缓存也可能受后续回收间接影响，均应按本协议下的观测解释。各任务变化见[结果解释与限制](docs/agentenv-results.md)。

扫描覆盖根文件系统中可通过路径访问的普通文件，包括 CompCert 实际 `/tmp/rocq-*`、OCaml、Dune 构建树；虚拟文件系统、其他挂载、符号链接与观察器控制路径明确排除。根文件扫描与 Cached-Shmem 的范围不同，未链接但仍映射的文件及目录/块缓存等不能据此精确逐文件归因。内核回收没有冻结；本批 {partial} 个边界因两遍扫描间变化标为 PARTIAL，变化计数和稳定驻留量均保留，不能称为原子物理快照。

阶段标签描述**工具执行时间窗口**，不是内存页的来源；某业务窗口仍可能保留之前安装/下载的缓存。混合调用不强行拆开，缓存峰值不能跨阶段相加。初始值取业务开始前、开机/辅助工具/校准之后；结束值取最终扫描与独立验证之前。净变化不是累计读取量或新增分配总量。

原验证范围保持：Log4j Maven 编译成功但原检查器 141、源命令跳过测试；Django 仅语法检查；token 实际计数 26 行。重放完成不等于原 benchmark 全面正确。每任务一次主记录、未控制宿主 backing 冷暖，保持原 guest 内核与 DAMON 策略；没有物理共享、DAX 收益或统计性能结论。

## 论文任务初筛

面向 checkpoint 历史文件层共享 / 增量 DAX，优先验证 **C4、CompCert、PDF.js**；HF 为条件候选，Log4j 备用，Cython 或文本编辑可作小工作集对照。现有数据支持候选筛选，尚未证明共享收益；先完成低扰动对照，再用 C4、CompCert 做多 VM 物理共享验证。完整选择理由、实际验证范围与后续计划见[初筛建议](docs/paper-workload-screening.md)。这些后续实验尚未执行。

## 历史与复算

本次补测保留 v1 的所有运行数据：[v1 轻量报告](AGENTENV-LIGHTWEIGHT-20261024.md)、[v1 选择清单](provenance/agentenv-runs-lightweight-v1.json)。v1 每任务仅三个文件扫描点，不应称作已完成逐工具冻结扫描。[旧 Podman 报告](PODMAN-20261020.md)也保留。

```bash
python3 -m pip install -r experiments/agentenv-memory/requirements-analysis.txt
python3 scripts/rebuild_agentenv_public.py --root . --verify-only
python3 scripts/rebuild_agentenv_public.py --root . --manifest provenance/agentenv-runs-lightweight-v1.json --verify-only
python3 scripts/verify_archive.py
```

无需完整日志即可核对公开 CSV、冻结边界与阶段摘要并重画：`python3 scripts/rebuild_agentenv_public.py --root .`。原始完整日志、二进制、校准和失败证据保留在 cpu-15 私有归档，公开仅含数值、固定可执行输入、版本和安全的元数据。
'''
    (root/'README.md').write_text(text)
    build_result_notes(root,records)


def build_result_notes(root,records):
    mi=2**20
    bounds=sum(r['file_boundaries'] for r in records)
    partial=sum(r['partial_scan_boundaries'] for r in records)
    scan=sum(r['boundary_scan_seconds'] for r in records)
    control=sum(r['boundary_control_seconds'] for r in records)
    c4=next(r for r in records if r['task_id']=='reshard-c4-data')
    compcert=next(r for r in records if r['task_id']=='compile-compcert')
    cb=json.loads((root/'results/agentenv/compile-compcert/runs'/compcert['run_id']/'boundaries.json').read_text())[-1]
    ct=next(c for c in cb['by_top_level'] if c['path']=='/tmp')
    mat=next(r for r in records if r['task_id']=='matplotlib__matplotlib-24177')
    observer_rows=[f"| {r['task_id']} | {r['initial_scan_nonfree_change_bytes']/mi:+.2f} | {r['initial_scan_slab_change_bytes']/mi:+.2f} | {r['initial_scan_buffers_change_bytes']/mi:+.2f} |" for r in records]
    rows=[]
    for r in records:
     rows.append(f"| [{r['task_id']}](../results/agentenv/{r['task_id']}/README.md) | {r['file_boundaries']} | {r['partial_scan_boundaries']} | {r['boundary_scan_seconds']:.2f} | {r['max_scan_file_cache_change_bytes']/mi:.2f} | {r['max_scan_buffers_change_bytes']/mi:.2f} |")
    text=f'''# v2 实验回答了什么，还有哪些限制

    本批 10 个新 VM 重放 652 次固定工具调用，取得 **{bounds} 个业务冻结文件扫描边界**。全部主记录与固定 Podman 参考重放的工具退出序列一致，输入 SHA-256、冻结与 CPU 稳定证明、根路径规范、控制排除和目录分区总量核对通过，直接扫描错误为零。独立检查 9 项通过；Log4j 保留原检查器 141，Maven 编译成功且原命令跳过测试。

    ## 文件驻留与缓存变化

    [首页结果表](../README.md)同时列出整个 guest 的文件缓存近似量，以及根文件系统普通文件驻留的初始、峰值和结束值。后一项峰值只取实际扫描边界，不能视为连续真实峰值。每任务还公开按目录拆分和驻留页数。

    C4 展示了两种采集为何都需要保留：周期及工具快照的总文件缓存观测峰值为 **{c4['guest_peak_observed_file_cache_bytes']/mi:.2f} MiB**，工具返回后普通文件驻留的边界最大值为 **{c4['observed_boundary_file_resident_peak_bytes']/mi:.2f} MiB**，结束缓存为 **{c4['guest_final_file_cache_bytes']/mi:.2f} MiB**。只看结束值会漏掉中途占用；只看工具返回后的点也会漏掉工具内的峰值。两种统计范围和时刻不同，数值差不能解释为扫描漏测量或可共享比例。

    CompCert 最终根扫描覆盖 **{cb['files']:,} 个普通文件**，其中 `/tmp` 为 **{ct['files']:,} 个**；普通文件驻留边界峰值 **{compcert['observed_boundary_file_resident_peak_bytes']/mi:.2f} MiB**。这补齐了 v1 有限目录列表遗漏实际工具链源码/构建树的问题；目录标签仍是顶层分组，不是每个工具链的独立归因。

    初始基线已经包含开机、平台进程、辅助工具与 fixture 校准。它帮助区分任务前状态和后续净变化，但不提供每页的分配时间。新 guest 的内部缓存统计解决了旧宿主总驻留与 sandbox 记账混用的问题；并不把全部 `Fend-F0` 或 `max(F)-F0` 解释为累计新分配，也不能与旧 Podman 总驻留相减计算节省率。

    ## 扫描期间仍会变化

    业务组冻结，平台进程、探针和内核继续运行；不是整机暂停。每块两遍 mincore 中发生变化的边界共 **{partial} 个**，按 PARTIAL 保留。即便两遍没有发现变化，也不能证明整个扫描区间各文件在同一时刻驻留。

    下表的扫描前后最大绝对差来自同一边界两次 meminfo，包含回收和其他并发活动，不是探针对缓存影响的因果估计。Buffers 与文件内容驻留也不能相加当作无重叠总量。

    | 任务 | 边界数 | PARTIAL | 扫描合计(s) | 扫描前后文件缓存最大绝对差(MiB) | Buffers 最大绝对差(MiB) |
    | --- | ---: | ---: | ---: | ---: | ---: |
    '''+ '\n'.join(rows)+f'''

    扫描合计 **{scan:.2f} s**，冻结控制区间合计 **{control:.2f} s**，后者包含前者。工具时延在扫描前结束；采集会改变后续运行机会、加载元数据并影响回收，不能据此做无监控性能比较。

    ## 初始扫描期间的元数据扰动

    Matplotlib 在首条业务工具执行前，初始根扫描区间的非空闲内存变化 **{mat['initial_scan_nonfree_change_bytes']/mi:+.2f} MiB**、Slab **{mat['initial_scan_slab_change_bytes']/mi:+.2f} MiB**、Buffers **{mat['initial_scan_buffers_change_bytes']/mi:+.2f} MiB**。同期文件缓存近似量变化为 **{mat['initial_scan_file_cache_change_bytes']/mi:+.2f} MiB**，不能将这些 Slab/块元数据变化当作普通文件内容驻留增长。这说明全根遍历带来的元数据影响不能忽略。下面是每任务初始扫描的前后变化，包含平台活动和回收，并非无观察器对照的因果估计。

    | 任务 | 非空闲变化(MiB) | Slab 变化(MiB) | Buffers 变化(MiB) |
    | --- | ---: | ---: | ---: |
    {chr(10).join(observer_rows)}

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
    '''
    text='\n'.join(line.removeprefix('    ') for line in text.splitlines()).rstrip()+'\n'
    (root/'docs/agentenv-results.md').write_text(text)
    p=root/'docs/README.md';t=p.read_text()
    if '(agentenv-results.md)' not in t:
     t=t.replace('| page cache、','| 本次数据说明了什么，还有哪些严重限制 | [结果解释与限制](agentenv-results.md) |\n| page cache、')
     p.write_text(t)


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1])
    build(ap.parse_args().root.resolve())
