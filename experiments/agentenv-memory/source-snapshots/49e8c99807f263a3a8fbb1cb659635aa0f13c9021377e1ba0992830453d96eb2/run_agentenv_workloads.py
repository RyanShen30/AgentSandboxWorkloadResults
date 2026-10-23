"""Replay archived normalized tools in fresh AgentENV guests; preserve old results."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tarfile
import time
import traceback
import threading

from agentenv_workload_client import Client

ROOT = Path(__file__).resolve().parents[1]
TASKS = ['build-cython-ext', 'reshard-c4-data', 'hf-model-inference',
         'mozilla__pdf.js-20957', 'apache__logging-log4j2', 'large-scale-text-editing',
         'count-dataset-tokens', 'matplotlib__matplotlib-24177',
         'django__django-16819', 'compile-compcert']
SESSION = {'apache__logging-log4j2', 'django__django-16819'}
CWD = {'apache__logging-log4j2': '/data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415',
       'matplotlib__matplotlib-24177': '/testbed', 'django__django-16819': '/testbed',
       'mozilla__pdf.js-20957': '/testbed'}
ROOTS = {
    'build-cython-ext': ['/app/pyknotid', '/usr/local/lib', '/usr/include', '/root/.cache'],
    'reshard-c4-data': ['/app/c4_sample', '/app', '/root/.cache', '/usr/local/lib'],
    'hf-model-inference': ['/app/model_cache', '/app', '/root/.cache', '/usr/local/lib'],
    'mozilla__pdf.js-20957': ['/testbed/node_modules', '/testbed/build', '/testbed', '/root/.cache', '/usr/local/lib'],
    'apache__logging-log4j2': ['/root/.m2', '/root/.sdkman', CWD['apache__logging-log4j2']],
    'large-scale-text-editing': ['/app', '/usr/local/lib'],
    'count-dataset-tokens': ['/app', '/root/.cache', '/usr/local/lib'],
    'matplotlib__matplotlib-24177': ['/testbed', '/opt/conda', '/opt/miniconda3'],
    'django__django-16819': ['/testbed', '/opt/conda', '/opt/miniconda3'],
    'compile-compcert': ['/tmp/CompCert', '/tmp/coq-8.16.1', '/usr/local/lib', '/app'],
}


def dump(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n')


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def load_reference(archive, task):
    records = json.loads((archive/'provenance/runs.json').read_text())
    record = next(x for x in records if x['task_id'] == task and x['role'] == 'primary')
    source = Path(record['server_path'])
    normalized = json.loads((source/'normalized-steps.json').read_text())
    assert [s['step'] for s in normalized] == list(range(1, len(normalized)+1))
    return record, source, normalized


def prepare_input(out, source, normalized):
    destination = out/'input'
    shutil.copytree(source/'input', destination)
    # The session controller is generated separately; archived tool scripts are unchanged.
    for step in normalized:
        script = destination/f"{step['step']:03}.sh"
        assert sha(script) == step['script_sha256'], f'archived tool changed: {script.name}'
        assert script.read_text() == step['command']+'\n'
    build = ROOT/'.artifacts/agentenv-workload-build'
    for binary, name in [('workload_probe', 'workload_probe'), ('workload_timer', 'tool_timer'),
                         ('file_reader', 'file_reader'), ('clock_ns', 'clock_ns')]:
        shutil.copyfile(build/binary, out/name)
        (out/name).chmod(0o755)


def guest_runner(task, normalized, validation, barriers):
    cwd = CWD.get(task, '/app')
    session = task in SESSION
    # All control and observation output is on a bounded guest tmpfs.
    lines = ['#!/bin/bash', 'set +e', 'umask 077',
             'mkdir -p /probe/work',
             'printf "baseline\\t0\\n" > /probe/work/phase',
             '/probe/workload_probe monitor /probe/work &', 'ASWR_MONITOR_PID=$!',
             'for ASWR_I in {1..100}; do test -f /probe/work/monitor-ready && break; sleep .02; done',
             'test -f /probe/work/monitor-ready || exit 90',
             '/probe/workload_probe snapshot > /probe/work/baseline.json',
             'printf "cache_scan\\t0\\n" > /probe/work/phase',
             '/probe/workload_probe scan '+shlex.join(ROOTS[task])+' > /probe/work/boundary-000.json',
             'printf "ASWR_READY\\n"']
    if session:
        lines += ['cd '+shlex.quote(cwd)+' || exit 91']
    for step in normalized:
        i = step['step']
        timeout = max(900, int(step.get('args', {}).get('timeout', 900)))
        for background in barriers.get(str(i), []):
            marker = f'/probe/work/async-{background}.done'
            lines += [f'printf "async_dependency_wait\\t{i}\\n" > /probe/work/phase',
                      'ASWR_WAIT_START=$(/probe/clock_ns)',
                      f'while ! test -f {marker}; do sleep .2; done',
                      'ASWR_WAIT_END=$(/probe/clock_ns)',
                      f'printf \'{{"source_async_step":{background},"before_tool_step":{i},"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}}\\n\' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat {marker})" >> /probe/work/async-barriers.jsonl']
        lines += [f'printf "running\\t{i}\\n" > /probe/work/phase',
                  f'printf "ASWR_STEP_START {i}\\n"']
        if session:
            lines += [f'/probe/workload_probe snapshot > /probe/work/{i:03}.before.json',
                      'ASWR_STARTED=$(/probe/clock_ns)',
                      f'source /probe/input/{i:03}.sh > /probe/work/{i:03}.stdout 2> /probe/work/{i:03}.stderr',
                      'ASWR_EXIT=$?', 'ASWR_FINISHED=$(/probe/clock_ns)',
                      f'/probe/workload_probe snapshot > /probe/work/{i:03}.after.json',
                      f'printf \'{{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}}\\n\' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/{i:03}.json']
        else:
            lines += [f'/probe/tool_timer /probe/input/{i:03}.sh /probe/work/{i:03}.json '+shlex.quote(cwd)+f' {timeout} > /probe/work/{i:03}.stdout 2> /probe/work/{i:03}.stderr',
                      'ASWR_TRANSPORT=$?', f'test "$ASWR_TRANSPORT" -eq 0 || exit 92']
        lines += [f'printf "after\\t{i}\\n" > /probe/work/phase',
                  f'printf "ASWR_STEP_END {i} "; cat /probe/work/{i:03}.json']
    lines += [f'printf "cache_scan\\t{len(normalized)}\\n" > /probe/work/phase',
              '/probe/workload_probe snapshot > /probe/work/final.json',
              '/probe/workload_probe scan '+shlex.join(ROOTS[task])+f' > /probe/work/boundary-{len(normalized):03}.json',
              f'printf "complete\\t{len(normalized)}\\n" > /probe/work/phase',
              'touch /probe/work/monitor-stop', 'wait "$ASWR_MONITOR_PID" || exit 93',
              'printf "ASWR_MEASUREMENT_COMPLETE\\n"',
              'exit 0']
    return '\n'.join(lines)+'\n'


def safe_extract(archive, destination):
    with tarfile.open(archive) as tf:
        for member in tf.getmembers():
            assert member.isfile() or member.isdir(), 'unexpected archive type'
            assert (destination/member.name).resolve().is_relative_to(destination.resolve())
        tf.extractall(destination, filter='data')


def run(args):
    service = args.service.resolve()
    client = Client(service)
    info = json.loads((service/'service.json').read_text())
    assert info['status'] == 'READY'
    mount = service/'mount'
    task = args.task
    record, reference, normalized = load_reference(args.archive, task)
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+str(os.getpid())
    out = mount/'raw'/(task+'-'+stamp)
    out.mkdir()
    started = time.monotonic_ns()
    result = dict(status='RUNNING', backend='agentenv', task_id=task, run_id=out.name,
                  expected_actions=len(normalized), reference_run=record['run_id'],
                  cpus=2, memory_mib=32768 if task == 'compile-compcert' else 8192,
                  service_image=info['image_id'], kernel_sha256=info['kernel_sha256'],
                  sample_interval_seconds=.2, started_ns=started,
                  cache_policy='new cold-start guest; host backing warmness uncontrolled; official DAMON retained',
                  file_cache_metric='guest Cached-Shmem approximation; Buffers separate',
                  physical_deduplication='NOT_MEASURED', source_hashes={})
    dump(out/'run.json', result)
    sid = args.existing_sid
    stop_guard = threading.Event()
    guard = None
    try:
        prepare_input(out, reference, normalized)
        dump(out/'normalized-steps.json', normalized)
        validation = json.loads((reference/'validation.json').read_text())
        barriers = json.loads((Path('/home/rashen/work/AgentWorkloadProbe-20261020')/'sources/compile-compcert/async-completion-barriers.json').read_text())['wait_before_step'] if task == 'compile-compcert' else {}
        script = guest_runner(task, normalized, validation, barriers)
        (out/'guest-runner.sh').write_text(script)
        for name in ('workload_probe.c', 'workload_timer.c', 'workload_memory.h',
                     'agentenv_workload_client.py', 'run_agentenv_workloads.py'):
            result['source_hashes'][name] = sha(ROOT/'scripts'/name)
            shutil.copyfile(ROOT/'scripts'/name, out/name)
        # Prefer a declared local export; remote images retain their fixed source reference.
        images = json.loads((args.archive/'provenance/images.json').read_text())
        source_image = images[task]['image']
        local = mount/'oci'/task
        image = 'aswr.local/'+task+':replay-v1' if (local/'index.json').exists() else source_image
        result.update(source_image=source_image, requested_image=image)
        if not sid:
            create_started = time.monotonic_ns()
            sid = client.create(image, result['memory_mib'])
            result['cold_create_seconds'] = (time.monotonic_ns()-create_started)/1e9
        result['sandbox_id'] = sid
        dump(out/'run.json', result)
        def guard_loop():
            while not stop_guard.wait(.5):
                host_free, volume_free = shutil.disk_usage(ROOT).free, shutil.disk_usage(mount).free
                if host_free < 26*1024**3 or volume_free < 2*1024**3 or time.monotonic_ns()-started > 14400*10**9:
                    result['guard_failure'] = dict(host_free_bytes=host_free, volume_free_bytes=volume_free)
                    try:
                        client.delete(sid)
                    except Exception:
                        result['guard_delete_error'] = traceback.format_exc()
                    return
        guard = threading.Thread(target=guard_loop, daemon=True)
        guard.start()
        print('GUEST_READY', task, sid, 'output='+str(out), flush=True)
        preflight = client.execute(sid, '/bin/bash', ['-c',
            'uname -a; id; cat /proc/sys/kernel/random/boot_id; cat /proc/cmdline; '
            'cat /sys/module/damon_reclaim/parameters/enabled; cat /proc/mounts; '
            'mkdir -p /probe/input /dev/shm/aswr-work; '
            'test ! -e /probe/work && ln -s /dev/shm/aswr-work /probe/work; '
            'df -h / /dev/shm; command -v bash python python3 tar'])
        (out/'preflight.stdout').write_bytes(preflight['stdout'])
        (out/'preflight.stderr').write_bytes(preflight['stderr'])
        # Upload only helpers and fixed tool inputs; source repository/data stay in the image.
        bundle = out/'input-bundle.tar'
        with tarfile.open(bundle, 'w') as tf:
            tf.add(out/'input', arcname='input')
            for name in ('workload_probe', 'tool_timer', 'file_reader', 'clock_ns', 'guest-runner.sh'):
                tf.add(out/name, arcname=name)
        client.upload(sid, bundle, '/tmp/aswr-input.tar')
        setup = client.execute(sid, '/bin/bash', ['-c',
            'tar -xf /tmp/aswr-input.tar -C /probe && chmod +x /probe/workload_probe /probe/tool_timer /probe/file_reader /probe/clock_ns; '
            '/probe/workload_probe calibrate /tmp/aswr-calibration-16m.bin'])
        (out/'calibration.stdout').write_bytes(setup['stdout'])
        (out/'calibration.stderr').write_bytes(setup['stderr'])
        assert setup['exit_code'] == 0, 'guest helper setup/calibration failed'
        calibration = json.loads(setup['stdout'])
        assert calibration['status'] == 'PASS'
        dump(out/'calibration.json', calibration)
        env = dict(OMP_NUM_THREADS='2', OPENBLAS_NUM_THREADS='2', MKL_NUM_THREADS='2',
                   TOKENIZERS_PARALLELISM='false', PAGER='cat', MANPAGER='cat', LESS='-R',
                   PIP_PROGRESS_BAR='off', TQDM_DISABLE='1')
        if args.guest_proxy:
            env.update(HTTP_PROXY=args.guest_proxy, HTTPS_PROXY=args.guest_proxy,
                       http_proxy=args.guest_proxy, https_proxy=args.guest_proxy,
                       NO_PROXY='127.0.0.1,localhost', no_proxy='127.0.0.1,localhost')
        result['guest_proxy_configured'] = bool(args.guest_proxy)
        result['measurement_dispatched_ns'] = time.monotonic_ns()
        dump(out/'run.json', result)
        with (out/'runner.stdout').open('wb') as stdout, (out/'runner.stderr').open('wb') as stderr:
            execution = client.execute(sid, '/bin/bash',
                [*(['-l'] if task == 'django__django-16819' else []), '/probe/guest-runner.sh'],
                env=env, stdout=stdout, stderr=stderr)
        result['measurement_finished_ns'] = time.monotonic_ns()
        result['runner_exit_code'] = execution['exit_code']
        assert execution['exit_code'] == 0, 'guest replay control failed'
        assert b'ASWR_MEASUREMENT_COMPLETE' in (out/'runner.stdout').read_bytes()
        verify = client.execute(sid, '/bin/bash',
            [*(['-l'] if task in ('matplotlib__matplotlib-24177', 'django__django-16819') else []),
             '-o', 'pipefail', '-c', validation['command']], env=env)
        (out/'validation.stdout').write_bytes(verify['stdout'])
        (out/'validation.stderr').write_bytes(verify['stderr'])
        dump(out/'validation.json', dict(exit_code=verify['exit_code'],
             status='PASS' if verify['exit_code'] == 0 else 'FAIL', command=validation['command'],
             scope=validation['scope']))
        package = client.execute(sid, '/bin/bash', ['-c',
            'tar -cf /tmp/aswr-results.tar -C /probe/work .'])
        assert package['exit_code'] == 0
        client.download(sid, '/tmp/aswr-results.tar', out/'guest-results.tar')
        safe_extract(out/'guest-results.tar', out/'guest')
        rows = []
        for step in normalized:
            p = out/'guest'/f"{step['step']:03}.json"
            value = json.loads(p.read_text())
            value.update(step=step['step'], tool=step['tool'])
            value.setdefault('tool_seconds', (value['finished_ns']-value['started_ns'])/1e9)
            rows.append(value)
        dump(out/'steps.json', rows)
        monitor = json.loads((out/'guest/monitor-status.json').read_text())
        assert monitor['status'] == 'PASS' and monitor['samples'] >= 2
        assert not any(row.get('timed_out') for row in rows)
        old = [json.loads(line) for line in (reference/'steps.jsonl').read_text().splitlines()]
        differences = [{'step': new['step'], 'reference_exit': before['exit_code'], 'actual_exit': new['exit_code']}
                       for new, before in zip(rows, old) if new['exit_code'] != before['exit_code']]
        result.update(status='COMPLETED', actions=len(rows), tool_seconds=sum(r['tool_seconds'] for r in rows),
                      exit_differences=differences, strict_exit_match=not differences,
                      validation_status='PASS' if verify['exit_code'] == 0 else 'FAIL',
                      guest_monitor=monitor)
        print('TASK_COMPLETE', task, 'actions='+str(len(rows)),
              'validation='+result['validation_status'], 'exit_differences='+str(len(differences)), flush=True)
    except BaseException:
        result.update(status='FAIL', error=traceback.format_exc())
        if sid and not (out/'guest-results.tar').exists():
            try:
                client.execute(sid, '/bin/bash', ['-c',
                    'touch /probe/work/monitor-stop; sleep .3; tar -cf /tmp/aswr-partial.tar -C /probe/work .'])
                client.download(sid, '/tmp/aswr-partial.tar', out/'guest-partial.tar')
                safe_extract(out/'guest-partial.tar', out/'guest-partial')
                result['partial_guest_evidence_saved'] = True
            except Exception:
                result['partial_capture_error'] = traceback.format_exc()
        print('TASK_FAILED', task, 'output='+str(out), flush=True)
        raise
    finally:
        stop_guard.set()
        if guard:
            guard.join(timeout=2)
        if sid:
            try:
                client.delete(sid)
                result['cleanup'] = {'sandbox_deleted': True}
            except Exception:
                result['cleanup'] = {'sandbox_deleted': False, 'error': traceback.format_exc()}
        result['finished_ns'] = time.monotonic_ns()
        dump(out/'run.json', result)
    return out


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service', type=Path, required=True)
    ap.add_argument('--archive', type=Path, default=Path('/home/rashen/work/AgentSandboxWorkloadResults'))
    ap.add_argument('--task', choices=TASKS, required=True)
    ap.add_argument('--existing-sid')
    ap.add_argument('--guest-proxy')
    run(ap.parse_args())
