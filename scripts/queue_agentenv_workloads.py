"""Sequential owned experiment queue; root only manages the service and volume."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from types import SimpleNamespace

from agentenv_workload_client import Client
from agentenv_workload_service import allow_proxy, reset_cache, validate
from run_agentenv_workloads import ROOT, TASKS, PROTOCOL


def write(path, data):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(data, indent=2)+'\n')
    temporary.replace(path)
    os.chown(path, 1012, 1012)


def child(argv, log_path, mount):
    command = ['runuser', '-u', 'rashen', '--', '/usr/bin/env',
               'XDG_RUNTIME_DIR=/run/user/1012', *map(str, argv)]
    with log_path.open('wb') as log:
        process = subprocess.Popen(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        while process.poll() is None:
            if shutil.disk_usage(ROOT).free < 26*1024**3 or shutil.disk_usage(mount).free < 2*1024**3:
                import signal
                os.killpg(process.pid, signal.SIGTERM)
                process.wait(timeout=20)
                raise RuntimeError('fixed-volume or host reserve reached')
            time.sleep(.5)
    if process.returncode:
        raise RuntimeError('experiment child failed; inspect '+str(log_path))


def main(args):
    assert os.geteuid() == 0
    service = args.service.resolve()
    info = json.loads((service/'service.json').read_text())
    mount = validate(service, info)
    progress = dict(status='RUNNING', protocol=PROTOCOL, tasks=args.tasks, completed=[], started_ns=time.time_ns(), released_oci=[])
    path = service/('queue-'+str(time.time_ns())+'.json')
    if args.after_run:
        print('WAITING_FOR', args.after_run.name, flush=True)
        while json.loads((args.after_run/'run.json').read_text())['status'] == 'RUNNING':
            time.sleep(1)
        prior = json.loads((args.after_run/'run.json').read_text())
        assert prior['status']=='COMPLETED' and prior['strict_exit_match'] and prior['validation_status']=='PASS'
    write(path, progress)
    try:
        for task in args.tasks:
            progress.update(current_task=task, stage='image_preparation')
            write(path, progress)
            print('PREPARE', task, flush=True)
            # One large Matplotlib conversion needs substantial private scratch space.
            threshold = 29 if task.startswith('matplotlib') else 18
            if shutil.disk_usage(mount).free < threshold*1024**3:
                reset_cache(SimpleNamespace(directory=service))
            prepare_log = service/(task+'-prepare-'+str(time.time_ns())+'.log')
            progress['preparation_log'] = str(prepare_log)
            write(path, progress)
            child([sys.executable, '-u', ROOT/'scripts/prepare_agentenv_workload.py',
                   '--service', service, '--task', task], prepare_log, mount)
            info = json.loads((service/'service.json').read_text())
            client = Client(service)
            assert client.api('GET','/sandboxes') == []
            images = json.loads(Path('/home/rashen/work/AgentSandboxWorkloadResults/provenance/images.json').read_text())
            image = 'aswr.local/'+task+':replay-v1' if (mount/'oci'/task/'index.json').exists() else images[task]['image']
            progress.update(stage='guest_creation')
            write(path, progress)
            created = time.monotonic_ns()
            sid = client.create(image, 32768 if task=='compile-compcert' else 8192)
            creation_seconds = (time.monotonic_ns()-created)/1e9
            if info.get('guest_proxy'):
                allow_proxy(SimpleNamespace(directory=service))
            before = set((mount/'raw').glob(task+'-*'))
            progress.update(stage='replay', sandbox_id=sid, cold_create_seconds=creation_seconds)
            write(path, progress)
            print('REPLAY', task, sid, flush=True)
            command = [sys.executable, '-u', ROOT/'scripts/run_agentenv_workloads.py',
                       '--service', service, '--task', task, '--existing-sid', sid, '--git-http1']
            if info.get('guest_proxy'):
                command += ['--guest-proxy', info['guest_proxy']['url']]
            replay_log = service/(task+'-replay-'+str(time.time_ns())+'.log')
            progress['replay_log'] = str(replay_log)
            write(path, progress)
            child(command, replay_log, mount)
            after = set((mount/'raw').glob(task+'-*'))
            assert len(after-before)==1
            out = next(iter(after-before))
            result = json.loads((out/'run.json').read_text())
            write(out/'creation.json', dict(cold_create_seconds=creation_seconds, sandbox_id=sid,
                                          scope='private queue REST creation before guest setup'))
            if result['status']!='COMPLETED' or not result['strict_exit_match']:
                raise RuntimeError('replay differs from fixed reference: '+str(out))
            if result['validation_status']!='PASS' and task!='apache__logging-log4j2':
                raise RuntimeError('independent validation failed: '+str(out))
            progress['completed'].append(dict(task=task, run_id=out.name,
                                              validation_status=result['validation_status']))
            write(path, progress)
            print('COMPLETED', task, out.name, flush=True)
            if not args.keep_oci:
                assert client.api('GET','/sandboxes')==[]
                layout=mount/'oci'/task
                assert layout.parent==mount/'oci' and not layout.is_symlink()
                if layout.exists():
                    allocated=sum(p.stat().st_blocks*512 for p in layout.rglob('*') if p.is_file())
                    assert json.loads((out/'oci-origin.json').read_text())['status']=='VERIFIED'
                    shutil.rmtree(layout)
                    progress['released_oci'].append(dict(task=task,allocated_bytes=allocated,
                        scope='only this completed task OCI layout; verified identity retained in raw'))
                    write(path,progress)
                reset_cache(SimpleNamespace(directory=service))
        progress.update(status='COMPLETED', stage='done', finished_ns=time.time_ns())
    except BaseException:
        import traceback
        progress.update(status='FAIL', error=traceback.format_exc(), finished_ns=time.time_ns())
        write(path, progress)
        raise
    write(path, progress)
    print('QUEUE_COMPLETE', path, flush=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service',required=True,type=Path)
    ap.add_argument('--tasks',nargs='+',required=True,choices=TASKS)
    ap.add_argument('--after-run',type=Path)
    ap.add_argument('--keep-oci',action='store_true',help='retain reproducible OCI layouts instead of reclaiming between completed tasks')
    main(ap.parse_args())
