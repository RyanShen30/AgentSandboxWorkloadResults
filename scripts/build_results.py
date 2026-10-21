#!/usr/bin/env python3
"""Recompute published reports from archived measurements; never runs workloads."""
from pathlib import Path
import csv,gzip,json,math,statistics,hashlib,os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
ARCHIVE_ROOT=Path(os.environ.get("ASWR_ARCHIVE_ROOT",str(ROOT)))
GIB=1024**3;MIB=1024**2
BLUE='#3366A3';GOLD='#BC8528';INK='#29333D';GRAY='#6B747D'
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':10,'axes.spines.top':False,'axes.spines.right':False,'axes.labelcolor':INK,'text.color':INK,'axes.titleweight':'medium','svg.hashsalt':'aswr-20261020','savefig.facecolor':'white'})
def read(p):return json.loads(p.read_text())
def rows(p):
 opener=gzip.open if p.suffix=='.gz' else open
 with opener(p,'rt') as f:return [json.loads(s) for s in f if s.strip()]
def writejson(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
def table(headers,data):
 def esc(x):return str(x).replace('|','\\|').replace('\n',' ')
 return '| '+' | '.join(map(esc,headers))+' |\n| '+' | '.join('---' for _ in headers)+' |\n'+''.join('| '+' | '.join(map(esc,row))+' |\n' for row in data)
def formatids(ids):return '、'.join(map(str,ids)) if ids else '无'
def metric_run(rec):
 p=ARCHIVE_ROOT/rec['path'];run=read(p/'run.json');s=rows(p/'steps.jsonl.gz');m=rows(p/'samples.jsonl.gz');b=rows(p/'boundaries.jsonl.gz');events=read(p/'memory-events.json');norm=json.loads(gzip.decompress((p/'normalized-steps.json.gz').read_bytes()))
 t0=run['started_ns'];end=run['measurement_finished_ns'];lat=[x['tool_seconds'] for x in s];disk=read(p/'disk-summary.json') if (p/'disk-summary.json').exists() else {}
 waits=rows(p/'async-barriers.jsonl') if (p/'async-barriers.jsonl').exists() else []
 errors=[x['step'] for x in s if x['exit_code']!=0]
 differing=[x['step'] for x in s if x.get('source_exit_code') is not None and x['exit_code']!=x['source_exit_code']]
 peak=max(b,key=lambda v:v['resident_bytes'])
 old=read(p/'summary.json')
 checks={'status_completed':run['status']=='COMPLETED','calls_match_normalized':len(s)==len(norm),'steps_sequential':[x['step'] for x in s]==list(range(1,len(s)+1)),'n_plus_one_boundaries':[x['step'] for x in b]==list(range(len(s)+1)),'all_frozen':all(x['frozen_verified'] for x in b),'no_scan_errors':not any(x['errors'] for x in b),'two_passes_stable':all(x['changed_pages']==0 for x in b),'no_monitor_errors':not run.get('metric_monitor_errors'),'no_oom':events.get('oom',0)==0 and events.get('oom_kill',0)==0,'container_removed':run.get('cleanup',{}).get('container_removed') is True,'timestamps_ordered':all(x['timestamp_ns']<=y['timestamp_ns'] for x,y in zip(m,m[1:])),'tool_sum_matches_original':math.isclose(sum(lat),old['tool_seconds'],rel_tol=1e-9,abs_tol=1e-6),'memory_peak_matches_original':math.isclose(max(v['memory_peak_bytes'] for v in m)/MIB,old['peak_cgroup_memory_mib'],abs_tol=.001)}
 out={'task_id':rec['task_id'],'run_id':rec['run_id'],'role':rec['role'],'data_path':rec['path'],'memory_limit_gib':run['memory_limit_bytes']/GIB,'cpus':run['cpus'],'tool_calls':len(s),'boundaries':len(b),'samples':len(m),'tool_seconds':sum(lat),'tool_p50_seconds':statistics.median(lat),'tool_p95_seconds':float(np.percentile(lat,95)),'tool_max_seconds':max(lat),'container_call_seconds':sum(x['controller_exec_seconds'] for x in s),'measurement_wall_seconds':(end-t0)/1e9,'pause_seconds':sum(x['pause_seconds'] for x in b),'scan_seconds':sum(x['scan_seconds'] for x in b),'median_scan_seconds':statistics.median(x['scan_seconds'] for x in b),'async_wait_seconds':sum((v['finished_ns']-v['started_ns'])/1e9 for v in waits),'async_barrier_count':len(waits),'peak_cgroup_memory_bytes':max(x['memory_peak_bytes'] for x in m),'peak_sampled_memory_bytes':max(x['memory_current_bytes'] for x in m),'peak_anon_bytes':max(x['anon_bytes'] for x in m),'peak_disk_file_charge_bytes':max(x['disk_file_charge_bytes'] for x in m),'initial_file_resident_bytes':b[0]['resident_bytes'],'peak_file_resident_bytes':peak['resident_bytes'],'final_file_resident_bytes':b[-1]['resident_bytes'],'net_file_residency_change_bytes':b[-1]['resident_bytes']-b[0]['resident_bytes'],'max_sample_gap_seconds':max((y['timestamp_ns']-x['timestamp_ns'])/1e9 for x,y in zip(m,m[1:])),'excluded_nonowner_files':max(x['excluded_nonowner_files'] for x in b),'excluded_nonowner_bytes':max(x['excluded_nonowner_bytes'] for x in b),'nonzero_exit_calls':errors,'source_exit_differences':differing,'memory_events':events,'writable_layer_end_bytes':disk.get('SizeRw'),'rootfs_end_bytes':disk.get('SizeRootFs'),'collection_checks':checks}
 assert all(checks.values()),(rec['run_id'],checks)
 return out,run,s,m,b,norm

def curves(rec,pack):
 a,run,s,m,b,norm=pack;p=ROOT/rec['path'];t0=run['started_ns']
 fig,axes=plt.subplots(3,1,figsize=(11,10.6),gridspec_kw={'height_ratios':[.85,1,1]})
 fig.suptitle(rec['task_id'],x=.09,ha='left',fontsize=15,y=.98)
 fig.text(.09,.947,f"{rec['run_id']} | {len(s)} calls | 2 CPU | {a['memory_limit_gib']:g} GiB limit | warm baseline",fontsize=9,color=GRAY)
 ax=axes[0];ax.plot([x['step'] for x in s],[x['tool_seconds'] for x in s],color=BLUE,lw=1,marker='.',ms=4,label='Tool execution')
 fail=[x for x in s if x['exit_code']!=0]
 if fail:ax.scatter([x['step'] for x in fail],[x['tool_seconds'] for x in fail],s=32,facecolors='none',edgecolors=INK,label='Nonzero exit',zorder=3)
 ax.set(xlabel='Tool call index',ylabel='Seconds',title='Tool execution latency');ax.legend(frameon=False,loc='upper right',fontsize=8)
 tx=[(x['timestamp_ns']-t0)/1e9 for x in m];ax=axes[1]
 ax.plot(tx,[x['memory_current_bytes']/GIB for x in m],color=BLUE,lw=1.2,label='Cgroup memory.current')
 ax.plot(tx,[x['anon_bytes']/GIB for x in m],color=GOLD,lw=1.05,ls='--',label='Cgroup anonymous')
 if a['memory_events'].get('max',0):ax.axhline(a['memory_limit_gib'],color=INK,ls=':',lw=1,label='Memory cap reached')
 ax.set(xlabel='Measurement wall time (s)',ylabel='GiB',title='Continuous container memory (200 ms target)');ax.legend(frameon=False,loc='upper left',fontsize=8)
 ax=axes[2];bt=[(x['finished_ns']-t0)/1e9 for x in b]
 ax.plot(bt,[x['resident_bytes']/GIB for x in b],color=BLUE,lw=1.3,marker='o',ms=2.2,label='Owned rootfs file residency (mincore)')
 ax.plot(tx,[x['disk_file_charge_bytes']/GIB for x in m],color=GOLD,lw=1.05,ls='--',label='Cgroup file - shmem charge')
 ax.set(xlabel='Measurement wall time (s)',ylabel='GiB',title='File residency at frozen tool boundaries');ax.legend(frameon=False,loc='upper left',fontsize=8)
 axes[0].xaxis.set_major_locator(MaxNLocator(integer=True))
 for ax in axes:
  title=ax.get_title();ax.set_title('');ax.set_title(title,loc='left',pad=30)
  ax.legend(loc='lower left',bbox_to_anchor=(0,1.01),ncol=3,frameon=False,fontsize=8,borderaxespad=0)
  ax.set_ylim(bottom=0);ax.grid(axis='y',color='#E4E7EA',lw=.6);ax.set_axisbelow(True);ax.margins(x=.01,y=.08)
 fig.text(.09,.018,'Wall time includes pause/scan and async waits; excludes model thinking. File residency is not bytes read or shared PFNs.',fontsize=8,color=GRAY)
 fig.tight_layout(rect=(.02,.04,.99,.93),h_pad=3.2)
 fig.savefig(p/'curves.png',dpi=150);fig.savefig(p/'curves.svg',metadata={'Date':None});plt.close(fig)

def task_doc(task,meta,recs,packs):
 primary=next(x for x in recs if x['role']=='primary');pack=packs[primary['run_id']];a,run,s,m,b,norm=pack;rel=f"runs/{primary['run_id']}";src=read(ROOT/'experiments/container-screening/workloads'/task/'provenance.json')
 def rowmetric(key,fmt):return fmt(a[key])
 data=[['完整工具调用 / 缓存边界 / 连续样本',f"{a['tool_calls']} / {a['boundaries']} / {a['samples']:,}"],['CPU 配额 / 内存上限',f"2 CPU / {a['memory_limit_gib']:g} GiB"],['工具执行合计 / 中位数 / P95 / 最大 (s)',f"{a['tool_seconds']:.3f} / {a['tool_p50_seconds']:.3f} / {a['tool_p95_seconds']:.3f} / {a['tool_max_seconds']:.3f}"],['容器调用合计 (s)',f"{a['container_call_seconds']:.3f}"],['测量墙钟 / 暂停总计 / 两遍扫描总计 (s)',f"{a['measurement_wall_seconds']:.3f} / {a['pause_seconds']:.3f} / {a['scan_seconds']:.3f}"],['后台依赖等待 (s)',f"{a['async_wait_seconds']:.3f}（{a['async_barrier_count']} 个边界）"],['cgroup 内存内核峰值 / 采样峰值 (MiB)',f"{a['peak_cgroup_memory_bytes']/MIB:.3f} / {a['peak_sampled_memory_bytes']/MIB:.3f}"],['匿名内存峰值 / 文件页计费峰值 (MiB)',f"{a['peak_anon_bytes']/MIB:.3f} / {a['peak_disk_file_charge_bytes']/MIB:.3f}"],['文件驻留：初始 / 最大 / 结束 (MiB)',f"{a['initial_file_resident_bytes']/MIB:.3f} / {a['peak_file_resident_bytes']/MIB:.3f} / {a['final_file_resident_bytes']/MIB:.3f}"],['文件驻留净变化 (MiB)',f"{a['net_file_residency_change_bytes']/MIB:+.3f}"],['扫描中位数 / 采样最大间隔 (s)',f"{a['median_scan_seconds']:.3f} / {a['max_sample_gap_seconds']:.3f}"],['非拥有者文件排除数 / 逻辑大小 (MiB)',f"{a['excluded_nonowner_files']} / {a['excluded_nonowner_bytes']/MIB:.3f}"],['memory.events max / oom / oom_kill',f"{a['memory_events'].get('max',0)} / {a['memory_events'].get('oom',0)} / {a['memory_events'].get('oom_kill',0)}"],['结束时 Podman SizeRw / SizeRootFs (GiB)', '未采集；不估算磁盘峰值' if a['writable_layer_end_bytes'] is None else f"{a['writable_layer_end_bytes']/GIB:.3f} / {a['rootfs_end_bytes']/GIB:.3f}（均非磁盘峰值）"],['非零退出的工具编号',formatids(a['nonzero_exit_calls'])],['与源数值退出码不同的工具编号',formatids(a['source_exit_differences'])]]
 text=f"# {meta['title']}\n\n{meta['scope']}\n\n**本轮已完成全部公开调用和三类数据采集。** {meta['validation']}\n\n主记录：`{primary['run_id']}`，实验日期 2026-10-20（Asia/Shanghai）。本地检查、轨迹重放完成与官方 benchmark 判题是不同结论。\n\n## 实际执行与输入范围\n\n{meta['data']}\n\n## 结果表\n\n下表的文件驻留以可扫描根文件系统的 inode/offset 为单位；cgroup 内存包含被计费缓存。它们口径不同，不能相加，也不是实际 read/write 字节量。峰值可能发生于不同时间。\n\n"+table(['指标','结果'],data)
 text+=f"\n## 三项曲线\n\n![工具时延、容器内存和边界文件驻留]({rel}/curves.png)\n\n[矢量图]({rel}/curves.svg)。第一幅按工具编号显示时延，空心标记为非零退出；后两幅横轴含人为暂停扫描和后台等待，不含模型思考。初始暖驻留按实测保留。内核 memory.peak 可能高于 200 ms 序列捕获的峰值，也可能包含预检。\n\n## 文件范围与驻留\n\n以下按结束时驻留量取前八个区域；逻辑大小是文件大小之和，驻留量按页取整。目录分区说明见[测量口径](../../docs/measurement.md)。这些数据描述文件驻留，不能证明本轮调用读取了每个文件。\n\n"
 regions=sorted(b[-1]['regions'].items(),key=lambda x:x[1]['resident_bytes'],reverse=True)[:8]
 text+=table(['区域','结束时文件数','逻辑大小 (MiB)','初始驻留 (MiB)','结束驻留 (MiB)'],[[f'`/{k}`',v['files'],f"{v['logical_bytes']/MIB:.2f}",f"{b[0]['regions'].get(k,{}).get('resident_bytes',0)/MIB:.2f}",f"{v['resident_bytes']/MIB:.2f}"] for k,v in regions])
 peak=max(b,key=lambda x:x['resident_bytes']);text+=f"\n总驻留峰值边界为工具 `{peak['step']}` 后。该边界的前五个驻留文件：\n\n"
 text+=table(['文件','驻留 (MiB)'],[[f"`/{v['path']}`",f"{v['resident_bytes']/MIB:.2f}"] for v in peak['largest_resident_files'][:5]])
 text+='\n## 时延较长的工具\n\n'+table(['工具编号','类型','命令摘要','时延 (s)','退出码'],[[x['step'],x['tool'],norm[x['step']-1]['command'].replace('\n',' ↵ ')[:110],f"{x['tool_seconds']:.3f}",x['exit_code']] for x in sorted(s,key=lambda x:x['tool_seconds'],reverse=True)[:8]])
 changes=list(dict.fromkeys(c for x in norm for c in x.get('changes',[])))
 text+=f"\n## 适配、权限与解释限制\n\n{meta['limits']}\n\n两遍扫描均无错误且 changed_pages=0；每个边界均记录 frozen_verified=true。非零工具退出可对应源轨迹故意保留的失败尝试，不自动说明采集失败。匿名内存、文件驻留与 cgroup 文件计费没有共同的独占物理页分母；尚未测跨租户 PFN 共享或 DAX 效果。\n\n{meta['suitability']}\n\n本记录的适配类别如下；逐步命令、改动说明和脚本哈希保存在 normalized-steps.json.gz。\n\n"+'\n'.join('- '+c for c in changes)+'\n'
 if task=='compile-compcert':
  old=next(v for v in recs if v['role']!='primary');o=packs[old['run_id']][0]
  text+='\n## 8 GiB 与 32 GiB 复测\n\n8 GiB 原结果触及上限（max=31）但没有 OOM；主记录 32 GiB 未触及配置上限。两轮全部 318 个工具脚本哈希相同，harness 只调整内存限额。各配置仅一次；同机负载、联网和缓存未隔离，时延差不能全部归因于限额。\n\n'
  text+=table(['指标','8 GiB 原记录','32 GiB 主记录'],[['run ID',old['run_id'],primary['run_id']],['cgroup 内存峰值 (GiB)',f"{o['peak_cgroup_memory_bytes']/GIB:.3f}",f"{a['peak_cgroup_memory_bytes']/GIB:.3f}"],['文件驻留最大 / 结束 (GiB)',f"{o['peak_file_resident_bytes']/GIB:.3f} / {o['final_file_resident_bytes']/GIB:.3f}",f"{a['peak_file_resident_bytes']/GIB:.3f} / {a['final_file_resident_bytes']/GIB:.3f}"],['memory.events max / oom_kill',f"{o['memory_events']['max']} / {o['memory_events']['oom_kill']}",f"{a['memory_events']['max']} / {a['memory_events']['oom_kill']}"],['工具执行合计 (min)',f"{o['tool_seconds']/60:.2f}",f"{a['tool_seconds']/60:.2f}"]])
  text+=f"\n![CompCert 两轮对照](comparison.png)\n\n[原 8 GiB 三项曲线](runs/{old['run_id']}/curves.png) · [两轮数据表](comparison.csv)。32 GiB 主记录峰值约 12.76 GiB，说明这一轮超过了原 8 GiB 配置；不代表所有并发或环境下的统一上界。\n"
 text+=f"\n## 数据、来源与复现\n\n- [逐工具 CSV]({rel}/steps.csv)、[边界 CSV]({rel}/boundaries.csv)、[重算汇总]({rel}/metrics.json)。\n- [完整连续序列]({rel}/samples.jsonl.gz)、[完整边界序列]({rel}/boundaries.jsonl.gz)、[完整工具记录]({rel}/steps.jsonl.gz)；gzip 解压后是原始 JSONL，数值未降采样。\n- [运行配置]({rel}/run.json)、[OOM/限额事件]({rel}/memory-events.json)、[原检查结果]({rel}/validation.json)"
 if (ROOT/primary['path']/'validation-evidence.json').exists():text+=f"、[补充检查证据]({rel}/validation-evidence.json)"
 text+=f"。\n- [适配后的逐步命令]({rel}/normalized-steps.json.gz)；`{rel}/tool-files.tar.gz` 保存全部普通文件形式的 stdout/stderr、命令、负载和异步标记，FIFO 不打包。\n- [上游来源、下载内容 SHA-256 与 revision](../../experiments/container-screening/workloads/{task}/provenance.json)。\n"
 for f in src.get('files',[]):
  if Path(f['path']).name in ['original.json','original.jsonl','setup.log']:text+=f"- [原公开轨迹]({f['url']})，下载 SHA-256：`{f['sha256']}`。\n"
 text+=f"- [环境搭建与部署](../../docs/deployment/README.md)、[重放规程](../../experiments/container-screening/README.md)。本轮容器已删除；文件缓存不能在删除后的容器中再读，重算使用已归档的序列。\n\n[返回十任务总览](../../README.md)\n"
 (ROOT/'results'/task/'README.md').write_text(text)

def overview(data):
 fig,ax=plt.subplots(1,2,figsize=(15,7.2),sharey=True);yy=np.arange(len(data));labels=[x['task_id'] for x in data]
 mem=[x['peak_cgroup_memory_bytes']/GIB for x in data];initial=np.array([x['initial_file_resident_bytes']/GIB for x in data]);peak=np.array([x['peak_file_resident_bytes']/GIB for x in data]);end=np.array([x['final_file_resident_bytes']/GIB for x in data])
 ax[0].barh(yy,mem,height=.55,color=BLUE)
 for y,v in zip(yy,mem):ax[0].text(v+.1,y,f'{v:.2f}',va='center',fontsize=9)
 ax[0].set(xlabel='GiB',title='Kernel cgroup memory peak',xlim=(0,max(mem)*1.15));ax[0].set_yticks(yy,labels,fontsize=9)
 ax[1].hlines(yy,initial,peak,color=GRAY,lw=1.4);ax[1].scatter(initial,yy,marker='o',facecolors='white',edgecolors=GRAY,s=40,label='Initial');ax[1].scatter(peak,yy,color=BLUE,marker='o',s=26,label='Peak');ax[1].scatter(end,yy,color=GOLD,marker='x',s=42,label='End')
 ax[1].set(xlabel='GiB',title='Owned rootfs file residency',xlim=(0,max(peak)*1.13));ax[1].legend(frameon=False,loc='lower right',fontsize=9)
 ax[0].invert_yaxis()
 for a in ax:a.grid(axis='x',color='#E4E7EA',lw=.6);a.set_axisbelow(True)
 fig.suptitle('Ten workload measurements on cpu-15',x=.025,ha='left',y=.99,fontsize=16)
 fig.text(.025,.935,'2026-10-20 | one primary run per task | CompCert: 32 GiB repeat; all others: 8 GiB | 2 CPU each',fontsize=10,color=GRAY)
 fig.text(.025,.018,'File residency includes warm baseline pages; it is not actual bytes read, cgroup charge, or cross-sandbox shared memory.',fontsize=9,color=GRAY)
 fig.tight_layout(rect=(0,.05,1,.92));fig.savefig(ROOT/'results/overview.png',dpi=150);fig.savefig(ROOT/'results/overview.svg',metadata={'Date':None});plt.close(fig)

def comparison(recs,packs):
 a=next(x for x in recs if x['role']!='primary');b=next(x for x in recs if x['role']=='primary');fig,axes=plt.subplots(3,1,figsize=(11,10))
 for rec,col,ls in [(a,GRAY,'--'),(b,BLUE,'-')]:
  mt,run,s,m,bd,norm=packs[rec['run_id']];t0=run['started_ns'];label=f"{mt['memory_limit_gib']:g} GiB limit"
  axes[0].plot([v['step'] for v in s],[v['tool_seconds'] for v in s],color=col,ls=ls,lw=1,label=label)
  axes[1].plot([(v['timestamp_ns']-t0)/1e9 for v in m],[v['memory_current_bytes']/GIB for v in m],color=col,ls=ls,lw=1,label=label)
  axes[2].plot([(v['finished_ns']-t0)/1e9 for v in bd],[v['resident_bytes']/GIB for v in bd],color=col,ls=ls,lw=1.2,label=label)
 axes[1].axhline(8,color=GOLD,ls=':',lw=1,label='Original 8 GiB cap')
 for ax,title,xlabel,ylabel in zip(axes,['Tool execution latency','Continuous cgroup memory','Frozen-boundary file residency'],['Tool call index','Measurement wall time (s)','Measurement wall time (s)'],['Seconds','GiB','GiB']):ax.set(title=title,xlabel=xlabel,ylabel=ylabel,ylim=(0,None));ax.grid(axis='y',color='#E4E7EA',lw=.6);ax.legend(frameon=False,fontsize=8)
 fig.suptitle('CompCert: memory limit comparison',x=.09,ha='left',y=.98,fontsize=15)
 fig.text(.09,.94,'2026-10-20 | 318 identical tool scripts per run | 2 CPU | single run per setting',color=GRAY,fontsize=9)
 fig.text(.09,.015,'Wall time includes scans and async barriers. Host activity, network, and cache warmness were not controlled.',color=GRAY,fontsize=8)
 fig.tight_layout(rect=(.02,.04,.99,.925),h_pad=2.3);d=ROOT/'results/compile-compcert';fig.savefig(d/'comparison.png',dpi=150);fig.savefig(d/'comparison.svg',metadata={'Date':None});plt.close(fig)
 with (d/'comparison.csv').open('w',newline='') as f:
  keys=['run_id','memory_limit_gib','tool_calls','boundaries','samples','tool_seconds','measurement_wall_seconds','peak_cgroup_memory_bytes','peak_anon_bytes','initial_file_resident_bytes','peak_file_resident_bytes','final_file_resident_bytes','pause_seconds','async_wait_seconds'];w=csv.DictWriter(f,fieldnames=keys);w.writeheader();w.writerows({k:packs[x['run_id']][0][k] for k in keys} for x in [a,b])

def main():
 recs=read(ROOT/'provenance/runs.json')
 if not all((ARCHIVE_ROOT/r['path']/'samples.jsonl.gz').exists() for r in recs):
  raise SystemExit('Full samples are retained on cpu-15; set ASWR_ARCHIVE_ROOT to the full local archive before regenerating figures.')
 meta=read(ROOT/'experiments/container-screening/workloads.json');packs={r['run_id']:metric_run(r) for r in recs}
 for r in recs:
  curves(r,packs[r['run_id']]);writejson(ROOT/r['path']/'metrics.json',packs[r['run_id']][0])
 data=[packs[r['run_id']][0] for r in recs if r['role']=='primary'];writejson(ROOT/'results/summary.json',data)
 with (ROOT/'results/summary.csv').open('w',newline='') as f:
  fields=[k for k,v in data[0].items() if not isinstance(v,(dict,list))];w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows({k:v[k] for k in fields} for v in data)
 overview(data);comparison([r for r in recs if r['task_id']=='compile-compcert'],packs)
 for task in meta:task_doc(task,meta[task],[r for r in recs if r['task_id']==task],packs)
 tabletext=table(['任务与结果文档','调用数','工具合计 (s)','cgroup 峰值 (MiB)','文件驻留 初始→最大→结束 (MiB)','本地验证范围'],[[f"[{x['task_id']}](results/{x['task_id']}/README.md)",x['tool_calls'],f"{x['tool_seconds']:.2f}",f"{x['peak_cgroup_memory_bytes']/MIB:.1f}",f"{x['initial_file_resident_bytes']/MIB:.1f} → {x['peak_file_resident_bytes']/MIB:.1f} → {x['final_file_resident_bytes']/MIB:.1f}",meta[x['task_id']]['validation_label']] for x in data])
 template=(ROOT/'docs/templates/root-readme.md').read_text();(ROOT/'README.md').write_text(template.replace('{{RESULTS_TABLE}}',tabletext).replace('{{PRIMARY_CALLS}}',str(sum(x['tool_calls'] for x in data))).replace('{{PRIMARY_BOUNDARIES}}',str(sum(x['boundaries'] for x in data))).replace('{{ALL_CALLS}}',str(sum(p[0]['tool_calls'] for p in packs.values()))).replace('{{ALL_BOUNDARIES}}',str(sum(p[0]['boundaries'] for p in packs.values()))))
 writejson(ROOT/'provenance/report-validation.json',{'assessment':'Share with caveats','run_count':len(recs),'primary_task_count':len(data),'primary_calls':sum(x['tool_calls'] for x in data),'primary_boundaries':sum(x['boundaries'] for x in data),'per_run':{r['run_id']:packs[r['run_id']][0]['collection_checks'] for r in recs},'caveats':['container metrics, not VM physical memory','warm cache and shared host','single run per setting','adapted native read/write tools','8 GiB CompCert is memory-limited','workload completion is distinct from benchmark correctness']})
 print(json.dumps({'tasks':len(data),'runs':len(recs),'calls':sum(x['tool_calls'] for x in data),'status':'PASS'},ensure_ascii=False))
if __name__=='__main__':
 main()
 from prepare_public_docs import sanitize
 sanitize(ROOT)
