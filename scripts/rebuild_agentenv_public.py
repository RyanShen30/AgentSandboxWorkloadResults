"""Verify published numeric artifacts and reproduce figures without private logs."""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path

from report_agentenv_workloads import numeric_summary, figure, overview, csv_write


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


def rebuild(root, verify_only=False):
    manifest = read(root/'provenance/agentenv-runs.json')
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
            for name,expected in read(directory/'artifact-sha256.json').items():
                if name in ('curves.png','curves.svg'):
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
            assert all(a['monotonic_ns'] < b['monotonic_ns'] for a,b in zip(samples,samples[1:]))
            for key,value in numeric_summary(samples,steps,boundaries,baseline,final).items():
                expected = summary[key]
                assert math.isclose(value,expected,rel_tol=1e-12,abs_tol=1e-9), (record['run_id'],key,value,expected)
            if not verify_only:
                figure(directory,summary,samples,steps,boundaries,baseline)
            if role == 'primary':
                summaries.append(summary)
    published = read(root/'results/agentenv/summary.json')
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
    args=ap.parse_args()
    rebuild(args.root.resolve(),args.verify_only)
