"""Explicit live-guest regressions; never runs implicitly during unit discovery."""
import argparse
import json
from pathlib import Path
import sys
import tarfile
import time
import traceback

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'scripts'))
from agentenv_workload_client import Client
from run_agentenv_workloads import frozen_guest_runner, guest_worker, ROOT, safe_extract


CASES = [
    ('nonpersistent', 'build-cython-ext', [
        'mkdir -p /tmp/aswr-worker-proof; (while :; do echo tick >> /tmp/aswr-worker-proof/ticks; sleep .01; done) > /tmp/aswr-worker-proof/log 2>&1 & echo $! > /tmp/aswr-worker-proof/pid',
        'kill -0 "$(cat /tmp/aswr-worker-proof/pid)"; exit 7',
        'sleep .1; test -s /tmp/aswr-worker-proof/ticks',
        'kill "$(cat /tmp/aswr-worker-proof/pid)"'], [0, 7, 0, 0]),
    ('persistent', 'django__django-16819', [
        'export ASWR_FIXTURE_VALUE=kept; cd /tmp; fixture_function() { echo persistent; }',
        'test "$ASWR_FIXTURE_VALUE" = kept && test "$PWD" = /tmp && fixture_function',
        'false',
        'test "$ASWR_FIXTURE_VALUE" = kept && test "$PWD" = /tmp'], [0, 0, 1, 0]),
]


def main(service,image):
    service=service.resolve()
    base=service/'mount/raw'/('protocol-worker-tests-'+str(time.time_ns()))
    base.mkdir()
    client=Client(service)
    for name,task,commands,expected in CASES:
        out=base/name;out.mkdir();sid=None
        receipt=dict(status='RUNNING',case=name,started_ns=time.time_ns())
        steps=[dict(step=i,command=command,args={}) for i,command in enumerate(commands,1)]
        try:
            print('CREATE',name,flush=True)
            sid=client.create(image)
            receipt['sandbox_id']=sid
            result=client.execute(sid,'/bin/bash',['-c','mkdir -p /probe/input /dev/shm/aswr-work /app /testbed; echo fixture > /testbed/aswr-integration-fixture; ln -s /dev/shm/aswr-work /probe/work'])
            assert result['exit_code']==0
            for i,command in enumerate(commands,1):(out/f'{i:03}.sh').write_text(command+'\n')
            (out/'guest-runner.sh').write_text(frozen_guest_runner(task,steps,{}))
            (out/'guest-worker.sh').write_text(guest_worker(task,steps))
            with tarfile.open(out/'input.tar','w') as bundle:
                for i in range(1,len(commands)+1):bundle.add(out/f'{i:03}.sh',arcname=f'input/{i:03}.sh')
                for f in ['guest-runner.sh','guest-worker.sh']:bundle.add(out/f,arcname=f)
                for source,dest in [('workload_probe','workload_probe'),('workload_timer','tool_timer'),('clock_ns','clock_ns')]:
                    bundle.add(ROOT/'.artifacts/agentenv-workload-build'/source,arcname=dest)
            client.upload(sid,out/'input.tar','/tmp/aswr-input.tar')
            result=client.execute(sid,'/bin/bash',['-c','tar -xf /tmp/aswr-input.tar -C /probe; chmod +x /probe/workload_probe /probe/tool_timer /probe/clock_ns'])
            assert result['exit_code']==0
            with (out/'runner.stdout').open('wb') as stdout,(out/'runner.stderr').open('wb') as stderr:
                result=client.execute(sid,'/bin/bash',['/probe/guest-runner.sh'],stdout=stdout,stderr=stderr)
            assert result['exit_code']==0,(name,result['exit_code'],(out/'runner.stderr').read_text())
            result=client.execute(sid,'/bin/bash',['-c','tar -cf /tmp/aswr-results.tar -C /probe/work .'])
            assert result['exit_code']==0
            client.download(sid,'/tmp/aswr-results.tar',out/'results.tar')
            guest=out/'guest';guest.mkdir();safe_extract(out/'results.tar',guest)
            codes=[json.loads((guest/f'{i:03}.json').read_text())['exit_code'] for i in range(1,len(commands)+1)]
            assert codes==expected,codes
            for i in range(len(commands)+1):
                frozen=json.loads((guest/f'freeze-{i:03}.json').read_text())
                scan=json.loads((guest/f'boundary-{i:03}.json').read_text())
                thaw=json.loads((guest/f'thaw-{i:03}.json').read_text())
                assert frozen['frozen'] and frozen['cpu_stable'] and scan['business_frozen_verified']
                assert scan['errors']==0 and not thaw['frozen']
                assert scan.get('scan_path_policy')=='canonical_absolute_v2'
                assert scan['exclusions']['observer_and_virtual_paths']>=4
                assert any(c['path']=='/testbed' and c['files']>0 for c in scan['by_top_level'])
                assert sum(c['logical_bytes'] for c in scan['by_top_level'])==scan['logical_bytes']
            assert not (guest/'commands').exists() and not (guest/'completed').exists()
            receipt.update(status='PASS',exit_codes=codes,verified_boundaries=len(commands)+1,
                           fifo_excluded_from_archive=True)
            print('PASS',name,codes,'boundaries='+str(len(commands)+1),flush=True)
        except BaseException:
            receipt.update(status='FAIL',error=traceback.format_exc())
            raise
        finally:
            if sid:
                client.delete(sid);receipt['sandbox_deleted']=True
            receipt['finished_ns']=time.time_ns()
            (out/'result.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
    print('FROZEN_PROTOCOL_PASS',base,flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--service',required=True,type=Path)
    parser.add_argument('--image',default='aswr.local/mozilla__pdf.js-20957:replay-v1')
    args=parser.parse_args();main(args.service,args.image)
