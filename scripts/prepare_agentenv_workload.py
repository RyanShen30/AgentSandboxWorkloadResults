"""Prepare and attest one OCI input inside the experiment's fixed-capacity volume."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time
import os

from run_agentenv_workloads import TASKS

OLD_POD = ['podman', '--root', '/home/rashen/work/AgentWorkloadProbe-20261020/state/storage',
           '--runroot', '/tmp/asbp-1012-20261020']


def read_blob(layout, digest):
    algorithm, value = digest.split(':', 1)
    assert algorithm == 'sha256'
    data = (layout/'blobs'/algorithm/value).read_bytes()
    assert hashlib.sha256(data).hexdigest() == value
    return data


def attest(layout, origin, source_inspect=None):
    index = json.loads((layout/'index.json').read_text())
    assert len(index['manifests']) == 1
    desc = index['manifests'][0]
    manifest = json.loads(read_blob(layout, desc['digest']))
    config = json.loads(read_blob(layout, manifest['config']['digest']))
    layer_bytes = 0
    for layer in manifest['layers']:
        path = layout/'blobs/sha256'/layer['digest'].split(':')[1]
        assert path.stat().st_size == layer['size']
        # Verify blobs with bounded memory, including the large data/model layers.
        with path.open('rb') as stream:
            assert hashlib.file_digest(stream, 'sha256').hexdigest() == layer['digest'].split(':')[1]
        layer_bytes += path.stat().st_size
    desc.setdefault('annotations', {})['org.opencontainers.image.ref.name'] = 'latest'
    (layout/'index.json').write_text(json.dumps(index)+'\n')
    verification = {'manifest_digest': desc['digest'], 'config_digest': manifest['config']['digest'],
                    'rootfs_diff_ids': config['rootfs']['diff_ids'], 'layer_bytes': layer_bytes,
                    'layers': len(manifest['layers']), 'platform': [config.get('os'), config.get('architecture')]}
    if source_inspect is not None:
        assert source_inspect['RootFS']['Layers'] == config['rootfs']['diff_ids']
        differences = []
        for name, key in [('Env','Env'), ('Cmd','Cmd'), ('Entrypoint','Entrypoint'),
                          ('WorkingDir','WorkingDir'), ('User','User')]:
            if (source_inspect['Config'].get(name) or None) != (config['config'].get(key) or None):
                differences.append(name)
        assert not differences, differences
        verification['source_image_id'] = source_inspect['Id']
        verification['runtime_config_fields_match'] = True
    return dict(origin, verification=verification)


def main(args):
    service = args.service.resolve()
    meta = json.loads((service/'service.json').read_text())
    assert meta['status'] == 'READY'
    host_proxy=meta['host_proxy_url']
    mount = service/'mount'
    task = args.task
    expected = json.loads((args.archive/'provenance/images.json').read_text())[task]
    layout = mount/'oci'/task
    if layout.exists() and not (layout/'index.json').exists():
        retained = layout.with_name(task+'.failed-preparation-'+str(time.time_ns()))
        layout.rename(retained)
    origin = {'task_id': task, 'source_image': expected['image'],
              'source_podman_image_id': expected['image_id'], 'started_ns': time.time_ns()}
    inspect = subprocess.run(OLD_POD+['image', 'inspect', expected['image_id']],
                             capture_output=True, text=True, timeout=30)
    source_inspect = json.loads(inspect.stdout)[0] if inspect.returncode == 0 else None
    source_pod = OLD_POD
    if source_inspect is None and task == 'apache__logging-log4j2' and not layout.exists():
        build = mount/'build'
        build.mkdir(exist_ok=True)
        repo = build/'log4j-source'
        commit = '204d8251295dfa816b9b28d8d9cfaebab500f415'
        env = dict(os.environ, HTTP_PROXY=host_proxy,
                   HTTPS_PROXY=host_proxy, http_proxy=host_proxy,
                   https_proxy=host_proxy, NO_PROXY='localhost,127.0.0.1',
                   no_proxy='localhost,127.0.0.1')
        if not repo.exists():
            subprocess.run(['git', 'init', str(repo)], check=True, env=env, timeout=30)
            subprocess.run(['git', '-C', str(repo), 'remote', 'add', 'origin',
                            'https://github.com/apache/logging-log4j2.git'], check=True, env=env, timeout=30)
            subprocess.run(['git', '-C', str(repo), '-c', 'http.version=HTTP/1.1', 'fetch',
                            '--depth', '1', 'origin', commit], check=True, env=env, timeout=600)
            subprocess.run(['git', '-C', str(repo), 'checkout', '--detach', 'FETCH_HEAD'],
                           check=True, env=env, timeout=60)
        assert subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'],text=True).strip() == commit
        source_pod = ['podman', '--root', str(mount/'build-storage'),
                      '--runroot', '/tmp/aswr-build-'+service.name]
        containerfile = args.archive/'experiments/container-screening/environments/log4j.Containerfile'
        subprocess.run(source_pod+['build', '--format', 'docker', '--layers=false',
            '--network', 'slirp4netns:allow_host_loopback=true', '-t', expected['image'],
            '-f', str(containerfile), str(repo)], check=True, timeout=1200, env=env)
        source_inspect = json.loads(subprocess.check_output(source_pod+['image','inspect',expected['image']]))[0]
        origin['rebuilt_local_image'] = dict(source_commit=commit,
            containerfile_sha256=hashlib.sha256(containerfile.read_bytes()).hexdigest(),
            base_image='ghcr.io/jetbrains-research/envbench-jvm@sha256:e6dbfbdc8f67e420b029440eb54988514bf7d9eca005ce5bad530a823414d388',
            prior_image_id=expected['image_id'], actual_image_id=source_inspect['Id'])
    if not layout.exists():
        if source_inspect is not None:
            origin['method'] = 'existing Podman image exported to OCI; filesystem diff IDs and runtime config verified'
            subprocess.run(source_pod+['save', '--format', 'oci-dir', '--output', str(layout),
                                      source_inspect['Id']], check=True, timeout=900)
        else:
            assert not expected['image'].startswith('localhost/'), 'local image must first be rebuilt from its fixed Containerfile'
            origin['method'] = 'fixed registry digest copied to OCI'
            transport_env = {k:v for k,v in os.environ.items() if k.lower() != 'all_proxy'}
            transport_env.update(HTTP_PROXY=host_proxy, HTTPS_PROXY=host_proxy,
                http_proxy=host_proxy, https_proxy=host_proxy,
                NO_PROXY='localhost,127.0.0.1', no_proxy='localhost,127.0.0.1')
            subprocess.run([str(mount/'bin/regctl'), 'image', 'copy', '--platform', 'linux/amd64',
                            expected['image'], 'ocidir://'+str(layout)+':latest'], check=True,
                           timeout=1200, env=transport_env)
            origin['registry_transport'] = 'existing host HTTP proxy'
    else:
        origin['method'] = 'attest existing local OCI export'
    value = attest(layout, origin, source_inspect)
    value.update(finished_ns=time.time_ns(), status='VERIFIED')
    (layout/'aswr-origin.json').write_text(json.dumps(value, indent=2)+'\n')
    print(json.dumps({'status': value['status'], 'task_id': task, 'verification': value['verification']}))


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service', type=Path, required=True)
    ap.add_argument('--archive', type=Path, default=Path('/home/rashen/work/AgentSandboxWorkloadResults'))
    ap.add_argument('--task', choices=TASKS, required=True)
    main(ap.parse_args())
