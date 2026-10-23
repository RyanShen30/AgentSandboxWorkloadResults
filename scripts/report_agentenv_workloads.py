"""Export inspectable numerical evidence and figures for explicitly selected VM runs."""
import argparse
import csv
from datetime import datetime, timezone, timedelta
import hashlib
import json
from pathlib import Path
import re
import shutil

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
import numpy as np

MIB = 2**20
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10,
                     'axes.spines.top': False, 'axes.spines.right': False,
                     'svg.hashsalt': 'aswr-agentenv-20261023', 'savefig.facecolor': 'white'})


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n')


def csv_write(path, rows, fields=None):
    fields = fields or list(dict.fromkeys(k for row in rows for k in row))
    with path.open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        writer.writerows({k: row.get(k) for k in fields} for row in rows)


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def table(headers, rows):
    return ('| '+' | '.join(headers)+' |\n| '+' | '.join('---' for _ in headers)+' |\n'+
            ''.join('| '+' | '.join(str(x).replace('|', '\\|') for x in row)+' |\n' for row in rows))


def numeric_summary(samples, steps, boundaries, baseline, final):
    """Same calculation for private raw export and public CSV-only reproduction."""
    periodic = [r for r in samples if r['phase'] not in ('cache_scan', 'complete')]
    observed = [r for r in periodic] + [baseline['memory'], final['memory']]
    for row in steps:
        for label in ('before', 'after'):
            observed.append({key: row['memory_'+label+'_'+key]
                             for key in ('disk_file_cache_bytes', 'nonfree_bytes')})
    latency = [r['tool_seconds'] for r in steps]
    initial = baseline['memory']['disk_file_cache_bytes']
    end = final['memory']['disk_file_cache_bytes']
    gaps = [(b['monotonic_ns']-a['monotonic_ns'])/1e9 for a,b in zip(samples,samples[1:])]
    return dict(tool_seconds=sum(latency), tool_p50_seconds=float(np.median(latency)),
        tool_p95_seconds=float(np.percentile(latency,95)),
        guest_initial_file_cache_bytes=initial,
        guest_peak_observed_file_cache_bytes=max(r['disk_file_cache_bytes'] for r in observed),
        guest_final_file_cache_bytes=end, guest_net_file_cache_change_bytes=end-initial,
        guest_peak_observed_nonfree_bytes=max(r['nonfree_bytes'] for r in observed),
        sampled_file_cache_peak_bytes=max(r['disk_file_cache_bytes'] for r in periodic),
        initial_declared_file_resident_bytes=boundaries[0]['resident_bytes'],
        final_declared_file_resident_bytes=boundaries[-1]['resident_bytes'],
        boundary_scan_seconds=sum(b['scan_seconds'] for b in boundaries), file_boundaries=len(boundaries),
        samples=len(samples), max_sample_gap_seconds=max(gaps),
        sample_gaps_over_600ms=sum(g>.6 for g in gaps),
        guest_measurement_span_seconds=(final['monotonic_ns']-baseline['monotonic_ns'])/1e9)


def numerical_evidence(source):
    run = read(source/'run.json')
    assert run['status'] == 'COMPLETED'
    guest = source/'guest'
    normalized = read(source/'normalized-steps.json')
    steps = read(source/'steps.json')
    samples = [json.loads(line) for line in (guest/'samples.jsonl').read_text().splitlines()]
    assert len(steps) == run['expected_actions'] == len(normalized)
    assert [s['step'] for s in steps] == list(range(1, len(steps)+1))
    assert all(a['monotonic_ns'] < b['monotonic_ns'] for a, b in zip(samples, samples[1:]))
    assert all(sha(source/'input'/f"{s['step']:03}.sh") == s['script_sha256'] for s in normalized)
    monitor = read(guest/'monitor-status.json')
    assert monitor['status'] == 'PASS' and monitor['samples'] == len(samples)
    assert read(source/'calibration.json')['status'] == 'PASS'
    baseline, final = read(guest/'baseline.json'), read(guest/'final.json')
    boundaries = []
    for p in sorted(guest.glob('boundary-*.json')):
        boundaries.append(dict(read(p), after_step=int(p.stem.split('-')[-1])))
    assert boundaries[0]['after_step'] == 0 and boundaries[-1]['after_step'] == len(steps)
    flat_samples = [dict((k,v) for k,v in row.items() if k != 'memory') | row['memory'] for row in samples]
    flat_steps = []
    for row in steps:
        flat = {k: v for k,v in row.items() if not isinstance(v, (dict,list))}
        for label in ('before','after'):
            memory = row.get('memory_'+label)
            if memory is None:
                memory = read(guest/f"{row['step']:03}.{label}.json")['memory']
            for key, value in memory.items():
                flat['memory_'+label+'_'+key] = value
        flat_steps.append(flat)
    validation = read(source/'validation.json')
    texts = '\n'.join(p.read_text(errors='replace') for p in sorted(guest.glob('*.stdout')))
    semantics = {}
    if run['task_id'] == 'reshard-c4-data':
        semantics['full_roundtrip_9898_files'] = (
            'CONSTRAINT VIOLATIONS: NONE' in (guest/'033.stdout').read_text() and
            '9898 files, structure + content' in (guest/'034.stdout').read_text())
    if run['task_id'] == 'build-cython-ext':
        passed = [int(n) for n in re.findall(r'\b(\d+) passed\b', texts)]
        semantics['final_two_test_summaries_18_passed'] = passed[-2:] == [18,18]
    if run['task_id'] == 'mozilla__pdf.js-20957':
        semantics['cli_test_evidence'] = [line.strip() for line in texts.splitlines()
            if ('specs' in line and ('failure' in line or 'pending' in line))][-8:]
    if run['task_id'] == 'apache__logging-log4j2':
        semantics['maven_build_success'] = 'BUILD SUCCESS' in texts
        semantics['tests_skipped_by_source_command'] = True
    if run['task_id'].startswith('matplotlib'):
        semantics['test_summaries'] = [line.strip() for line in texts.splitlines()
            if 'passed' in line and ('deselected' in line or 'skipped' in line)][-8:]
        semantics['final_two_hist_tests_60_passed'] = all(
            '60 passed, 10 skipped, 762 deselected' in (guest/f'{n:03}.stdout').read_text()
            for n in (88,93))
    async_path=guest/'async-barriers.jsonl'
    async_rows=[json.loads(line) for line in async_path.read_text().splitlines()] if async_path.exists() else []
    expected_async=[(86,88),(102,107),(132,134),(174,176),(241,245),
                    (258,260),(273,276),(276,278),(299,304)] if run['task_id']=='compile-compcert' else []
    assert [(r['source_async_step'],r['before_tool_step']) for r in async_rows]==expected_async
    assert all(r['started_ns']<=r['finished_ns']<=steps[r['before_tool_step']-1]['started_ns'] for r in async_rows)
    checks = dict(complete_actions=True, frozen_script_hashes=True, sample_order=True,
                  sample_count=True, monitor_complete=True, file_fixture_calibrated=True,
                  async_completion_schedule=True,
                  no_tool_timeout=not any(x.get('timed_out') for x in steps),
                  sandbox_deleted=run.get('cleanup',{}).get('sandbox_deleted') is True)
    assert all(checks.values()), checks
    if 'full_roundtrip_9898_files' in semantics:
        assert semantics['full_roundtrip_9898_files']
    if 'final_two_test_summaries_18_passed' in semantics:
        assert semantics['final_two_test_summaries_18_passed']
    if 'maven_build_success' in semantics:
        assert semantics['maven_build_success']
    if 'final_two_hist_tests_60_passed' in semantics:
        assert semantics['final_two_hist_tests_60_passed']
    summary = dict(task_id=run['task_id'], run_id=run['run_id'], backend='agentenv',
        actions=len(steps), memory_mib=run['memory_mib'], cpus=run['cpus'],
        **numeric_summary(flat_samples,flat_steps,boundaries,baseline,final),
        strict_exit_match=run['strict_exit_match'], validation_status=validation['status'],
        validation_exit_code=validation['exit_code'], checks=checks, semantics=semantics,
        exit_differences=run['exit_differences'],
        async_barrier_count=len(async_rows),
        async_wait_seconds=sum((r['finished_ns']-r['started_ns'])/1e9 for r in async_rows),
        async_job_exit_codes=[r['job_exit_code'] for r in async_rows],
        boundary_coverage=[dict(after_step=b['after_step'],status=b['status'],files=b['files'],
            errors=b['errors'],changed_pages_or_files=b['changed_pages_or_files'],
            excluded_entries=b['excluded_entries'],
            missing_roots=[r['path'] for r in b['roots'] if r['status']=='MISSING']) for b in boundaries],
        scope='guest logical memory and declared regular-file residency; host PFN sharing not measured')
    return summary, run, flat_samples, flat_steps, boundaries, baseline, final


def figure(directory, summary, samples, steps, boundaries, baseline):
    fig, axes = plt.subplots(3,1,figsize=(12.2,10.0),gridspec_kw={'height_ratios':[1,1.25,1.05]},constrained_layout=True)
    colors = ['#b64b40' if int(s['exit_code']) else '#3a6ea5' for s in steps]
    axes[0].bar([s['step'] for s in steps], [s['tool_seconds'] for s in steps],color=colors,width=.85)
    axes[0].set(xlabel='Tool call number',ylabel='Tool time (s)', title=summary['task_id']+' | AgentENV, single replay')
    axes[0].xaxis.set_major_locator(MaxNLocator(integer=True,nbins=16))
    t0=baseline['monotonic_ns']
    times=np.array([(r['monotonic_ns']-t0)/1e9 for r in samples])
    def curve(field):
        x,y=[],[]
        for i,r in enumerate(samples):
            if i and times[i]-times[i-1]>.6:
                x.append(float('nan'));y.append(float('nan'))
            x.append(times[i]);y.append(r[field]/MIB)
        return x,y
    axes[1].plot(*curve('nonfree_bytes'),color='#273d50',label='Guest nonfree (MemTotal - MemFree)',lw=1.3)
    axes[1].plot(*curve('AnonPages'),color='#8d729e',label='Guest AnonPages',lw=1.0)
    axes[1].plot(*curve('disk_file_cache_bytes'),color='#2b8c78',label='Guest Cached - Shmem',lw=1.2)
    axes[1].set(xlabel='Guest measurement wall time (s)',ylabel='MiB')
    axes[1].legend(loc='best',frameon=False,fontsize=9)
    axes[2].plot(*curve('disk_file_cache_bytes'),color='#2b8c78',lw=1.1,label='Guest Cached - Shmem (approx.)')
    for i,b in enumerate(boundaries):
        point=(b['finished_ns']-t0)/1e9
        axes[2].scatter([point],[b['resident_bytes']/MIB],marker='D',s=43,color='#c38d25',zorder=4,
                        label='Declared-file mincore residency' if i==0 else None)
        axes[2].annotate('B'+str(b['after_step']), (point,b['resident_bytes']/MIB),xytext=(4,6),textcoords='offset points',fontsize=8)
        a,z=(b['started_ns']-t0)/1e9,point
        for axis in axes[1:]:axis.axvspan(a,z,color='#aab1b8',alpha=.25,lw=0)
    axes[2].set(xlabel='Guest measurement wall time (s)',ylabel='MiB')
    axes[2].legend(loc='best',frameon=False,fontsize=9)
    for axis in axes:
        axis.grid(axis='y',alpha=.17)
        axis.set_ylim(bottom=0)
    fig.savefig(directory/'curves.png',dpi=160)
    fig.savefig(directory/'curves.svg',metadata={'Date':None})
    plt.close(fig)


def export(source, destination):
    pack=numerical_evidence(source)
    summary,run,samples,steps,boundaries,baseline,final=pack
    destination.mkdir(parents=True,exist_ok=True)
    for name in ('run.json','validation.json','calibration.json','oci-origin.json','creation.json',
                 'guest-runner.sh','final-source.patch','source-preflight.stdout',
                 'source-preflight.stderr','source-ancestry.stdout','source-ancestry.stderr',
                 'network-preflight.json'):
        if (source/name).exists():shutil.copyfile(source/name,destination/name)
    if run['task_id']=='matplotlib__matplotlib-24177' and (source/'final-source.patch').stat().st_size==0:
        # Source final tool stages its change. The initial collector captured only
        # unstaged changes; its exact staged diff remains in original tool stdout.
        content=(source/'guest/095.stdout').read_bytes()
        start=content.index(b'diff --git ')
        patch=content[start:]
        assert b'COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT' in content[:start]
        (destination/'final-source.patch').write_bytes(patch)
        reference_patch_sha256='6c4d4dd9337bde6d806220e51740b238840dadad3dd3806365c30b2e4945f4d8'
        assert sha(destination/'final-source.patch')==reference_patch_sha256
        write(destination/'source-patch-provenance.json',dict(
            scope='exact git diff --cached from final original tool step 95',
            source_stdout_sha256=sha(source/'guest/095.stdout'),
            patch_sha256=sha(destination/'final-source.patch'),
            reference_run=run['reference_run'],reference_patch_sha256=reference_patch_sha256,
            reference_patch_exact_match=True,
            collector_unstaged_patch_bytes=0,
            note='derived without rerunning business commands; original empty unstaged capture retained in private raw archive'))
    csv_write(destination/'memory.csv',samples)
    csv_write(destination/'steps.csv',steps)
    write(destination/'boundaries.json',boundaries)
    write(destination/'baseline.json',baseline)
    write(destination/'final.json',final)
    async_path=source/'guest/async-barriers.jsonl'
    write(destination/'async-barriers.json',
          [json.loads(line) for line in async_path.read_text().splitlines()] if async_path.exists() else [])
    write(destination/'summary.json',summary)
    # Only replay inputs are published; original conversations and tool logs stay private.
    normalized=read(source/'normalized-steps.json')
    public_steps=[{k:s.get(k) for k in ('step','tool','command','changes','script_sha256','source_exit_code')} for s in normalized]
    inputs={p.name:p.read_text() for p in sorted((source/'input').iterdir()) if p.is_file()}
    write(destination/'replay-inputs.json',dict(steps=public_steps,files=inputs,
        source_reference_run=run['reference_run'],scope='normalized executable inputs; no original conversation or tool outputs'))
    figure(destination,summary,samples,steps,boundaries,baseline)
    manifest={p.name:sha(p) for p in sorted(destination.iterdir()) if p.is_file() and p.name!='artifact-sha256.json'}
    write(destination/'artifact-sha256.json',manifest)
    return summary


def overview(destination, summaries):
    fig,ax=plt.subplots(figsize=(11,7.5),constrained_layout=True)
    y=np.arange(len(summaries));width=.24
    for offset,key,label,color in [(-width,'guest_initial_file_cache_bytes','Initial','#8ea8be'),
                                   (0,'guest_peak_observed_file_cache_bytes','Observed peak','#2b8c78'),
                                   (width,'guest_final_file_cache_bytes','Final','#c38d25')]:
        ax.barh(y+offset,[s[key]/MIB for s in summaries],width,label=label,color=color)
    ax.set_yticks(y,[s['task_id'].replace('__',' / ') for s in summaries],fontsize=9)
    ax.invert_yaxis()
    ax.set(xlabel='Guest Cached - Shmem (MiB)',title='AgentENV guest file cache | one replay per task')
    ax.legend(frameon=False);ax.grid(axis='x',alpha=.15)
    fig.savefig(destination/'overview.png',dpi=160)
    fig.savefig(destination/'overview.svg',metadata={'Date':None});plt.close(fig)


def export_host(raw_root, destination):
    statuses=sorted(raw_root.glob('host-service-*.status.json'))
    if not statuses:
        return
    assert len(statuses)==1
    status=read(statuses[0])
    source=statuses[0].with_name(statuses[0].name.replace('.status.json','.jsonl'))
    rows=[json.loads(line) for line in source.read_text().splitlines()]
    assert len(rows)==status['samples']
    assert all(a['monotonic_ns']<b['monotonic_ns'] for a,b in zip(rows,rows[1:]))
    csv_write(destination/'host-service.csv',rows)
    write(destination/'host-service.json',dict(samples=len(rows),source_file=source.name,
        first_timestamp_ns=rows[0]['timestamp_ns'],last_timestamp_ns=rows[-1]['timestamp_ns'],
        nominal_interval_seconds=status['interval_seconds'],
        max_sample_gap_seconds=max((b['monotonic_ns']-a['monotonic_ns'])/1e9 for a,b in zip(rows,rows[1:])),
        sampling_errors=len(status['errors']),cgroup=status['cgroup'],
        observed_peak_memory_current_bytes=max(r['memory_current_bytes'] for r in rows),
        scope=status['scope'],
        caveats=['starts after initial Cython diagnostic; includes sequential tasks and idle/setup intervals',
                 'service restarts reset kernel memory.peak and leave gaps',
                 'not per-guest file-cache memory; not host PFN unique physical memory']))


def main(args):
    manifest=read(args.manifest)
    destination=args.output.resolve()
    destination.mkdir(parents=True,exist_ok=True)
    summaries=[]
    for record in manifest['primary']:
        source=args.raw_root/record['run_id']
        run=read(source/'run.json')
        assert run['task_id']==record['task_id']
        relative=Path('results/agentenv')/record['task_id']/'runs'/record['run_id']
        summary=export(source,destination/relative)
        summaries.append(summary)
        doc=destination/'results/agentenv'/record['task_id']/'README.md'
        doc.write_text('# '+record['task_id']+'：AgentENV\n\n'
            '单实例固定轨迹完整重放，2 vCPU，'+str(summary['memory_mib'])+' MiB guest RAM。\n\n'+
            table(['调用数','工具合计 (s)','guest 文件缓存 初始→观测峰值→结束 (MiB)','严格退出码一致','独立验证'],[[
                summary['actions'],f"{summary['tool_seconds']:.3f}",
                ' → '.join(f"{summary[k]/MIB:.2f}" for k in ('guest_initial_file_cache_bytes','guest_peak_observed_file_cache_bytes','guest_final_file_cache_bytes')),
                summary['strict_exit_match'],summary['validation_status']]])+
            '\n![工具时延、guest 内存与指定文件驻留](runs/'+record['run_id']+'/curves.png)\n\n'+
            '[完整数值与校验](runs/'+record['run_id']+'/summary.json) · [连续内存 CSV](runs/'+record['run_id']+'/memory.csv) · [逐工具 CSV](runs/'+record['run_id']+'/steps.csv) · [文件边界](runs/'+record['run_id']+'/boundaries.json)\n\n'+
            ('Log4j 原检查器 `find | head` 配合 pipefail 返回 141；Maven BUILD SUCCESS 已单独核验，源轨迹跳过测试。\n\n' if record['task_id']=='apache__logging-log4j2' else '')+
            '`Cached-Shmem` 为 guest 磁盘文件缓存近似量，Buffers 单列。菱形仅覆盖声明路径的普通文件驻留，两种范围不同。灰带为边界扫描；红色时延柱表示非零退出，并不自动表示平台失败。完整日志留在 cpu-15。\n')
    write(destination/'provenance/agentenv-runs.json',manifest)
    diagnostic_rows=[]
    for record in manifest.get('diagnostics',[]):
        source=args.raw_root/record['run_id']
        target=destination/'results/agentenv/diagnostics'/record['run_id']
        if read(source/'run.json')['status']=='COMPLETED':
            detail=export(source,target)
            diagnostic_rows.append([f"[{record['run_id']}]({record['run_id']}/summary.json)",record['reason'],detail['strict_exit_match'],detail['validation_status']])
        else:
            target.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(source/'run.json',target/'run.json')
            diagnostic_rows.append([f"[{record['run_id']}]({record['run_id']}/run.json)",record['reason'],'incomplete','not counted'])
    for record in manifest['primary']+manifest.get('diagnostics',[]):
        source=args.raw_root/record['run_id']
        for name,digest in read(source/'run.json').get('source_hashes',{}).items():
            original=source/name
            assert sha(original)==digest, 'archived collector source changed: '+str(original)
            target=destination/'experiments/agentenv-memory/source-snapshots'/digest/name
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(original,target)
    diagnostic_doc=destination/'results/agentenv/diagnostics/README.md'
    diagnostic_doc.parent.mkdir(parents=True,exist_ok=True)
    diagnostic_doc.write_text('# 诊断与失败尝试\n\n所有业务执行尝试均保留，不按时延或缓存大小挑选主记录。准备阶段失败另见部署记录。\n\n'+
        table(['运行','原因','退出码一致','独立验证'],diagnostic_rows))
    write(destination/'results/agentenv/summary.json',summaries)
    flat=[{k:v for k,v in s.items() if not isinstance(v,(dict,list))} for s in summaries]
    if flat:csv_write(destination/'results/agentenv/summary.csv',flat)
    rows=[]
    for s in summaries:
        rows.append([f"[{s['task_id']}]({s['task_id']}/README.md)",s['actions'],f"{s['tool_seconds']:.2f}",
            ' → '.join(f"{s[k]/MIB:.1f}" for k in ('guest_initial_file_cache_bytes','guest_peak_observed_file_cache_bytes','guest_final_file_cache_bytes')),
            f"{s['guest_net_file_cache_change_bytes']/MIB:.1f}",s['strict_exit_match'],s['validation_status']])
    (destination/'results/agentenv/README.md').write_text('# AgentENV 文件缓存测试\n\n'+
        f"已归档 {len(summaries)} 个主记录；单次运行，不代表多次统计或共享收益。\n\n"+
        table(['任务','调用数','工具合计(s)','guest 缓存 初始→峰值→结束(MiB)','净变化(MiB)','退出码一致','验证'],rows)+
        '\n连续指标来自 guest `/proc/meminfo`，文件边界来自 guest 内 mincore。宿主镜像驻留、服务 cgroup 及 PFN 共享属于不同口径。\n')
    if summaries:overview(destination/'results/agentenv',summaries)
    export_host(args.raw_root,destination/'results/agentenv')
    print(json.dumps(dict(status='EXPORTED',primary_runs=len(summaries),actions=sum(s['actions'] for s in summaries))))


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--raw-root',required=True,type=Path)
    ap.add_argument('--manifest',required=True,type=Path)
    ap.add_argument('--output',required=True,type=Path)
    main(ap.parse_args())
