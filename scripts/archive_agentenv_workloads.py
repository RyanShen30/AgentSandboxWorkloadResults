"""Verify an off-volume copy before allowing the owned experiment volume release."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import time


ROOT=Path(__file__).resolve().parents[1]


def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()


def main(args):
    os.umask(0o077)
    service=args.service.resolve()
    assert service.parent==ROOT/'.artifacts/agentenv-workloads'
    assert (service/'host-sampler-stop').exists()
    raw=service/'mount/raw'
    assert list(raw.glob('host-service-*.status.json')), 'host sampler must finish first'
    runs=list(raw.glob('*/run.json'))
    assert runs and all(json.loads(p.read_text())['status']!='RUNNING' for p in runs)
    assert all(json.loads(p.read_text()).get('cleanup',{}).get('sandbox_deleted') for p in runs)
    output=(ROOT/'.artifacts/agentenv-workload-archive'/service.name).resolve()
    assert not output.is_relative_to(service)
    output.mkdir(parents=True,exist_ok=False)
    paths=[p for p in raw.rglob('*') if p.is_file()]
    paths += [p for p in (service/'mount/env/logs').rglob('*') if p.is_file()]
    total=sum(p.stat().st_size for p in paths)
    assert shutil.disk_usage(ROOT).free-total >= 26*2**30
    manifest={}
    for source in sorted(paths):
        assert not source.is_symlink()
        relative=source.relative_to(service/'mount')
        target=output/relative
        target.parent.mkdir(parents=True,exist_ok=True)
        if relative.parts[0]=='raw':
            expected=digest(source)
            shutil.copyfile(source,target)
            assert digest(target)==expected==digest(source), 'copy/source changed: '+str(relative)
        else:
            # Service logs may append a heartbeat; preserve a verified byte snapshot.
            snapshot=source.read_bytes()
            expected=hashlib.sha256(snapshot).hexdigest()
            target.write_bytes(snapshot)
            assert digest(target)==expected
        manifest[str(relative)]=dict(bytes=target.stat().st_size,sha256=expected)
    audit=output/'file-sha256.json'
    audit.write_text(json.dumps(manifest,indent=2)+'\n')
    receipt=dict(status='VERIFIED',verified_ns=time.time_ns(),files=len(manifest),
                 bytes=sum(r['bytes'] for r in manifest.values()),
                 archive_directory=str(output),manifest_sha256=digest(audit),
                 scope='all regular raw evidence, plus verified service-log snapshots; OCI images/backing caches excluded')
    # Service control/configuration already lives outside the disposable volume.
    # Copy it privately for a single audit folder, retaining mode 0700/0600.
    private=output/'private-control'
    private.mkdir()
    for source in service.iterdir():
        if source.is_file() and source.name!='volume.ext4':
            if not os.access(source,os.R_OK):
                receipt.setdefault('unreadable_control_retained_at_service',[]).append(source.name)
                continue
            shutil.copyfile(source,private/source.name)
            (private/source.name).chmod(0o600)
    (service/'archive-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    (output/'archive-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt),flush=True)


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service',required=True,type=Path)
    main(ap.parse_args())
