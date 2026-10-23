"""Read-only host evidence for the AgentENV workload rerun; never print secrets."""
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
import io
import tarfile


def output(argv):
    proc = subprocess.run(argv, capture_output=True, text=True, timeout=60)
    if proc.returncode:
        raise RuntimeError(f'{argv[:2]} failed: {proc.stderr[-1000:]}')
    return proc.stdout


def main():
    result = {'timestamp_ns': time.time_ns(), 'uid': os.geteuid(),
              'kernel': os.uname().release, 'host': os.uname().nodename}
    with open('/dev/kvm', 'r+b', buffering=0) as stream:
        result['kvm_api_version'] = fcntl.ioctl(stream.fileno(), 0xAE00)
    containers = [json.loads(line) for line in output(
        ['docker', 'ps', '-a', '--format', '{{json .}}']).splitlines()]
    result['container_count'] = len(containers)
    result['agentenv_containers'] = []
    for row in containers:
        if not any(x in (row.get('Names', '') + ' ' + row.get('Image', '')).lower()
                   for x in ('aenv', 'agentenv', 'asb-storage')):
            continue
        inspected = json.loads(output(['docker', 'inspect', row['ID']]))[0]
        result['agentenv_containers'].append({
            'id': inspected['Id'], 'name': inspected['Name'],
            'image': inspected['Image'],
            'state': {key: inspected['State'].get(key)
                      for key in ('Status', 'Running', 'Pid', 'StartedAt')},
            'mounts': [{key: m.get(key) for key in ('Source', 'Destination', 'RW')}
                       for m in inspected['Mounts']],
        })
        if not inspected['State']['Running']:
            for asset in ('config/default.toml', 'env/deps'):
                proc = subprocess.run(['docker', 'cp', row['ID'] + ':/workspace/' + asset, '-'],
                                      capture_output=True, timeout=60)
                if proc.returncode:
                    result.setdefault('asset_checks', {})[asset] = 'MISSING'
                    continue
                with tarfile.open(fileobj=io.BytesIO(proc.stdout)) as archive:
                    result.setdefault('asset_checks', {})[asset] = [
                        {'name': m.name, 'bytes': m.size} for m in archive.getmembers()][:80]
                    if asset.endswith('default.toml'):
                        data = archive.extractfile(archive.getmembers()[0]).read().decode()
                        destination = Path(__file__).resolve().parents[1] / '.artifacts/agentenv-workloads-original.toml'
                        destination.write_text(data)
                        destination.chmod(0o600)
                        os.chown(destination, int(os.environ.get('SUDO_UID', 0)),
                                 int(os.environ.get('SUDO_GID', 0)))
                        result['original_config_path'] = str(destination)
    images = [json.loads(line) for line in output(
        ['docker', 'images', '--no-trunc', '--format', '{{json .}}']).splitlines()]
    result['docker_image_count'] = len(images)
    result['agentenv_images'] = [r for r in images if any(
        term in r.get('Repository', '').lower() for term in ('aenv', 'agentenv'))]
    result['disk_free_bytes'] = shutil.disk_usage(Path(__file__).resolve().parents[1]).free
    result['ublk_device_present'] = Path('/dev/ublk-control').exists()
    print(json.dumps(result, ensure_ascii=False, indent=2), flush=True)


if __name__ == '__main__':
    main()
