"""Verify published numeric artifacts and reproduce figures without private logs."""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path

from report_agentenv_workloads import numeric_summary, phase_summary, figure, overview, csv_write


def read(path):
    return json.loads(path.read_text())


def scalar(value):
    if value == '':
        return None
    if value in ('True', 'False'):
        return value == 'True'
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value


def rows(path):
    with path.open(newline='') as stream:
        return [{k: scalar(v) for k,v in row.items()} for row in csv.DictReader(stream)]


def rebuild(root, verify_only=False, manifest_path=None):
    if manifest_path is not None:
        assert verify_only, 'Historical manifests support verification only; never overwrite current reports'
    manifest = read(root/(manifest_path or Path('provenance/agentenv-runs.json')))
    summaries = []
    files = 0
    for role in ('primary', 'diagnostics'):
        for record in manifest.get(role, []):
            relative = (Path('results/agentenv')/record['task_id']/'runs'/record['run_id']
                        if role == 'primary' else Path('results/agentenv/diagnostics')/record['run_id'])
            directory = root/relative
            run = read(directory/'run.json')
            if run['status'] != 'COMPLETED':
                assert role == 'diagnostics'
                continue
            for name,expected in run.get('source_hashes',{}).items():
                source=root/'experiments/agentenv-memory/source-snapshots'/expected/name
                assert hashlib.sha256(source.read_bytes()).hexdigest()==expected
            for name,expected in read(directory/'artifact-sha256.json').items():
                if name.endswith(('.png','.svg')):
                    continue  # Fonts/library versions can affect rendered bytes.
                with (directory/name).open('rb') as stream:
                    actual = hashlib.file_digest(stream,'sha256').hexdigest()
                assert actual == expected, f'artifact changed: {relative/name}'
                files += 1
            samples,steps = rows(directory/'memory.csv'),rows(directory/'steps.csv')
            boundaries = read(directory/'boundaries.json')
            baseline,final = read(directory/'baseline.json'),read(directory/'final.json')
            summary = read(directory/'summary.json')
            barriers=read(directory/'async-barriers.json')
            assert len(barriers)==summary['async_barrier_count']
            assert [r['job_exit_code'] for r in barriers]==summary['async_job_exit_codes']
            assert math.isclose(sum((r['finished_ns']-r['started_ns'])/1e9 for r in barriers),
                                summary['async_wait_seconds'],abs_tol=1e-9)
            assert len(steps) == run['expected_actions'] == summary['actions']
            assert [s['step'] for s in steps] == list(range(1,len(steps)+1))
            reference=rows(root/'results'/run['task_id']/'runs'/run['reference_run']/'steps.csv')
            assert len(reference)==len(steps)
            differences=[dict(step=s['step'],reference_exit=r['exit_code'],actual_exit=s['exit_code'])
                         for s,r in zip(steps,reference) if s['exit_code']!=r['exit_code']]
            assert differences==run['exit_differences']==summary['exit_differences']
            assert summary['strict_exit_match']==run['strict_exit_match']==(not differences)
            assert all(a['monotonic_ns'] < b['monotonic_ns'] for a,b in zip(samples,samples[1:]))
            for key,value in numeric_summary(samples,steps,boundaries,baseline,final).items():
                expected = summary[key]
                assert math.isclose(value,expected,rel_tol=1e-12,abs_tol=1e-9), (record['run_id'],key,value,expected)
            if run.get('protocol')=='agentenv-frozen-tools-v2':
                assert [b['after_step'] for b in boundaries]==list(range(len(steps)+1))
                assert all(b['business_frozen_verified'] and b['errors']==0 for b in boundaries)
                assert phase_summary(samples,steps)==summary['phase_summary']
                assert read(directory/'phase-summary.json')==summary['phase_summary']
                assert rows(directory/'phase-summary.csv')==summary['phase_summary']
                boundary_csv=rows(directory/'boundaries.csv')
                assert len(boundary_csv)==len(boundaries)
                for b,c in zip(boundaries,boundary_csv):
                    assert b['quiescence']['freeze']['frozen'] and b['quiescence']['freeze']['cpu_stable']
                    freeze=b['quiescence']['freeze']
                    assert freeze['cpu_usage_before_usec']==freeze['cpu_usage_after_usec']
                    assert b['business_cpu_before_usec']==b['business_cpu_after_usec']
                    assert not b['quiescence']['thaw']['frozen']
                    assert sum(c['resident_bytes'] for c in b['by_top_level'])==b['resident_bytes']
                    assert sum(c['logical_bytes'] for c in b['by_top_level'])==b['logical_bytes']
                    assert c['after_step']==b['after_step'] and c['resident_bytes']==b['resident_bytes']
                    assert c['resident_pages']*c['page_size_bytes']==b['resident_bytes']
                    assert c['scan_errors']==b['errors']
                    assert all(c[d['path'].strip('/')+'_resident_bytes']==d['resident_bytes'] for d in b['by_top_level'])
                if role=='primary':
                    assert summary['eligible_primary'] and all(summary['checks'].values())
                    assert all(b.get('scan_path_policy')=='canonical_absolute_v2' and
                               b['exclusions']['observer_and_virtual_paths']>=4 for b in boundaries)
            if not verify_only:
                figure(directory,summary,samples,steps,boundaries,baseline)
            if role == 'primary':
                summaries.append(summary)
    published = read(root/manifest.get('aggregate_summary','results/agentenv/summary.json'))
    assert summaries == published, 'aggregate differs from explicit primary run selection'
    if not verify_only:
        overview(root/'results/agentenv',summaries)
        csv_write(root/'results/agentenv/summary.csv',
                  [{k:v for k,v in s.items() if not isinstance(v,(dict,list))} for s in summaries])
        from build_agentenv_readme import build
        build(root)
    print(json.dumps(dict(status='PASS',primary_runs=len(summaries),
                          actions=sum(s['actions'] for s in summaries),verified_numeric_files=files,
                          figures_rebuilt=not verify_only)))


if __name__ == '__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--root',type=Path,required=True)
    ap.add_argument('--verify-only',action='store_true')
    ap.add_argument('--manifest',type=Path,help='historical run manifest; requires --verify-only')
    args=ap.parse_args()
    rebuild(args.root.resolve(),args.verify_only,args.manifest)
