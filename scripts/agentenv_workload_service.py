"""Create/stop one fixed-capacity, private AgentENV service for workload reruns."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import socket
import shlex
import subprocess
import time
import tomllib
import urllib.request
import sys
import signal
from urllib.parse import urlsplit

from isolated_storage import GIB, available, capacity_budget, mount_identity

ROOT = Path(__file__).resolve().parents[1]
IMAGE = 'sha256:db9eb044ae3d85f9b276b9d2e5dea28cb0be95263d217ea4989f095e1d828681'
SOURCE = '004e2e11a28684f3bc4eb1f750269a7b6d4eccb4af4a9a2ba818b903984359f6'


def config_value(text, section, key, value):
    # Kept local so the published workload harness does not import other suites.
    pattern = re.compile(r'(^\['+re.escape(section)+r'\]\n)(.*?)(?=^\[|\Z)', re.M|re.S)
    def replace(match):
        body = match[2]
        field = re.compile(r'^'+re.escape(key)+r'\s*=.*$', re.M)
        assert len(field.findall(body)) == 1, 'unexpected config field: '+section+'.'+key
        return match[1]+field.sub(key+' = '+value, body)
    changed,count = pattern.subn(replace,text)
    assert count == 1, 'unexpected config section: '+section
    return changed


def run(argv, timeout=120):
    p = subprocess.run(list(map(str, argv)), capture_output=True, timeout=timeout)
    if p.returncode:
        raise RuntimeError(f'{list(map(str, argv[:3]))}: {p.stderr.decode(errors="replace")[-1200:]}')
    return p.stdout


def write(path, value):
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def validate(directory, receipt):
    assert directory.parent == ROOT / '.artifacts/agentenv-workloads'
    assert receipt['workspace'] == str(ROOT)
    mount = directory / 'mount'
    image = directory / 'volume.ext4'
    st = image.stat()
    assert [st.st_dev, st.st_ino] == receipt['image_identity']
    assert st.st_size == receipt['capacity_bytes']
    assert st.st_blocks * 512 >= st.st_size
    mount_identity(mount, receipt['device'])
    assert run(['losetup', '-j', image]).decode().startswith(receipt['device'] + ':')
    return mount


def start(args):
    os.umask(0o077)
    proxy_url=urlsplit(args.host_proxy_url)
    assert proxy_url.scheme=='http' and proxy_url.hostname=='127.0.0.1' and proxy_url.port
    assert not proxy_url.username and not proxy_url.password
    with socket.create_connection(('127.0.0.1',proxy_url.port),timeout=3):
        pass
    base = ROOT / '.artifacts/agentenv-workloads'
    base.mkdir(exist_ok=True)
    os.chown(base, int(os.environ.get('SUDO_UID', 1012)), int(os.environ.get('SUDO_GID', 1012)))
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + str(os.getpid())
    directory = base / stamp
    directory.mkdir()
    capacity = args.capacity_gib * GIB
    budget = capacity_budget(available(ROOT), capacity)
    assert budget['ready'], budget
    receipt = dict(status='PREPARING', workspace=str(ROOT), directory=str(directory),
                   image_id=IMAGE, capacity_bytes=capacity, budget=budget,
                   host_proxy_url=args.host_proxy_url,
                   started_ns=time.time_ns(), cleanup={})
    write(directory / 'service.json', receipt)
    print('PREPARING ' + str(directory), flush=True)
    image = directory / 'volume.ext4'
    mount = directory / 'mount'
    mount.mkdir()
    try:
        with image.open('xb') as stream:
            os.posix_fallocate(stream.fileno(), 0, capacity)
            os.fsync(stream.fileno())
        st = image.stat()
        receipt['image_identity'] = [st.st_dev, st.st_ino]
        run(['mkfs.ext4', '-q', '-F', '-m', '0', '-E',
             'nodiscard,lazy_itable_init=0,lazy_journal_init=0', image])
        receipt['device'] = run(['losetup', '--find', '--show', image]).decode().strip()
        write(directory / 'service.json', receipt)
        (Path('/sys/class/block') / Path(receipt['device']).name /
         'queue/discard_max_bytes').write_text('0\n')
        run(['mount', '-t', 'ext4', '-o', 'nodiscard', receipt['device'], mount])
        mount_identity(mount, receipt['device'])
        for name in ('env', 'run', 'tmp', 'oci', 'raw', 'bin'):
            (mount / name).mkdir()
        with (mount / 'cleanup-reserve').open('xb') as stream:
            os.posix_fallocate(stream.fileno(), 0, GIB // 2)
        run(['docker', 'cp', SOURCE + ':/workspace/env/deps', mount / 'env'], timeout=120)
        assert (mount / 'env/deps/kernel/vmlinux-6.1.175/vmlinux.bin').is_file()
        original = (ROOT / '.artifacts/agentenv-workloads-original.toml').read_text()
        config = original
        changes = [('image.cache.gc', 'enabled', 'false'),
                   ('pool.network', 'maintenance_enabled', 'false'),
                   ('pool.block', 'enabled', 'false'),
                   ('pool.firecracker', 'enabled', 'false'),
                   ('pool.firecracker', 'startup_prewarm', 'false'),
                   ('ublk', 'daemon_metrics_listen_addr', '""'),
                   ('network.internal', 'host_interaction_cidr', '"10.211.0.0/16"'),
                   ('network.internal', 'veth_cidr', '"10.212.0.0/16"')]
        routes = run(['ip', '-j', 'route', 'show', 'table', 'all']).decode()
        assert '10.211.' not in routes and '10.212.' not in routes
        for section, key, value in changes:
            config = config_value(config, section, key, value)
        tomllib.loads(config)
        cfg = directory / 'config.toml'
        cfg.write_text(config)
        receipt['config_overrides'] = changes
        receipt['config_sha256'] = hashlib.sha256(config.encode()).hexdigest()
        with socket.socket() as sock:
            sock.bind(('127.0.0.1', 0))
            port = sock.getsockname()[1]
        receipt['service_url'] = f'http://127.0.0.1:{port}'
        name = 'aswr-agentenv-' + stamp.lower()
        argv = ['docker', 'create', '--name', name, '--privileged', '--read-only',
                '--network', 'host', '--log-driver', 'none', '--ulimit', 'memlock=-1:-1',
                '--label', 'agentsandboxbench.workload_run=' + stamp,
                '--mount', 'type=bind,src=/dev,dst=/dev',
                '--mount', f'type=bind,src={cfg},dst=/workspace/config/default.toml,readonly']
        for source, destination in [('env', '/workspace/env'), ('run', '/run'),
                                    ('tmp', '/tmp'), ('oci', '/aswr-oci')]:
            argv += ['--mount', f'type=bind,src={mount/source},dst={destination}']
        for key in ('HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy'):
            # Existing host HTTP proxy is only used for registry transport here.
            argv += ['-e', key + '='+args.host_proxy_url]
        for key in ('NO_PROXY', 'no_proxy'):
            argv += ['-e', key + '=localhost,127.0.0.1,::1,10.211.0.0/16,10.212.0.0/16,169.254.0.20/30']
        argv += ['-e', f'API_ADDR=127.0.0.1:{port}',
                 '-e', 'AENV_FIRECRACKER_SERIAL_DIR=/workspace/env/logs/serial',
                 '-e', 'AENV_HOME_PATH=/workspace/env',
                 '--entrypoint', '/bin/sh', IMAGE, '-c',
                 'mkdir -p /workspace/env/logs; exec /server >>/workspace/env/logs/server.log 2>&1']
        receipt['container_id'] = run(argv, 30).decode().strip()
        receipt['container_name'] = name
        write(directory / 'service.json', receipt)
        run(['docker', 'start', receipt['container_id']], 30)
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        deadline = time.monotonic() + 100
        while time.monotonic() < deadline:
            inspected = json.loads(run(['docker', 'inspect', receipt['container_id']]))[0]
            assert inspected['State']['Running'], 'private service exited; inspect private server.log'
            try:
                with opener.open(receipt['service_url'] + '/health', timeout=3) as r:
                    if r.status in (200, 204):
                        break
            except Exception:
                time.sleep(1)
        else:
            raise TimeoutError('private service health timeout')
        # Credentials remain private, outside public receipts and command output.
        key = run(['docker', 'exec', receipt['container_id'], 'cat',
                   '/workspace/env/secrets/api-key']).decode().strip()
        private = directory / 'credentials.json'
        write(private, {'url': receipt['service_url'], 'api_key': key})
        private.chmod(0o600)
        request = urllib.request.Request(receipt['service_url'] + '/sandboxes',
                                         headers={'X-API-Key': key})
        with opener.open(request, timeout=10) as response:
            assert json.load(response) == []
        receipt.update(status='READY', ready_ns=time.time_ns(),
                       kernel_sha256=hashlib.sha256((mount/'env/deps/kernel/vmlinux-6.1.175/vmlinux.bin').read_bytes()).hexdigest(),
                       guest_policy='official kernel and DAMON defaults retained; no global cache drop')
        uid, gid = int(os.environ.get('SUDO_UID', 1012)), int(os.environ.get('SUDO_GID', 1012))
        for path in (directory, mount, mount/'oci', mount/'raw', mount/'bin', private):
            os.chown(path, uid, gid)
        directory.chmod(0o700)
        mount.chmod(0o755)
        (mount/'env').chmod(0o755)
        # regctl supports local OCI copying without installing host dependencies.
        regctl = mount/'env/deps/regctl/v0.11.5/regctl'
        shutil.copyfile(regctl, mount/'bin/regctl')
        (mount/'bin/regctl').chmod(0o755)
        write(directory / 'service.json', receipt)
        os.chown(directory/'service.json', uid, gid)
        print(json.dumps({k: receipt[k] for k in ('status', 'directory', 'service_url', 'container_id', 'capacity_bytes')}), flush=True)
    except BaseException:
        import traceback
        receipt.update(status='FAIL', error=traceback.format_exc())
        write(directory / 'service.json', receipt)
        if receipt.get('container_id'):
            subprocess.run(['docker', 'stop', '-t', '10', receipt['container_id']], capture_output=True, timeout=30)
        print('FAIL retained=' + str(directory), flush=True)
        raise


def stop(args):
    directory = args.directory.resolve()
    receipt = json.loads((directory/'service.json').read_text())
    mount = validate(directory, receipt)
    cid = receipt['container_id']
    inspected = json.loads(run(['docker', 'inspect', cid]))[0]
    assert inspected['Config']['Labels']['agentsandboxbench.workload_run'] == directory.name
    assert inspected['Image'] == IMAGE
    run(['docker', 'stop', '-t', '15', cid], 35)
    run(['docker', 'rm', cid], 30)
    receipt['cleanup']['container_removed'] = True
    if receipt.get('guest_proxy'):
        proxy = receipt['guest_proxy']
        if proxy.get('input_rule'):
            run([proxy['iptables_binary'], '-D', 'INPUT', *proxy['input_rule']], 10)
        try:
            command=Path('/proc', str(proxy['pid']), 'cmdline').read_bytes()
            assert b'agentenv_workload_proxy.py' in command and str(directory).encode() in command
            os.kill(proxy['pid'], signal.SIGTERM)
        except FileNotFoundError:
            pass
        run(['ip', 'addr', 'del', proxy['address']+'/32', 'dev', 'lo'], 10)
        receipt['cleanup']['owned_guest_proxy_removed'] = True
    # Raw evidence must have been archived before successful storage reclamation.
    if args.release:
        assert (directory/'archive-receipt.json').exists()
        archive = json.loads((directory/'archive-receipt.json').read_text())
        assert archive['status'] == 'VERIFIED'
        manifest=Path(archive['archive_directory'])/'file-sha256.json'
        assert hashlib.sha256(manifest.read_bytes()).hexdigest()==archive['manifest_sha256']
        run(['umount', mount], 30)
        run(['losetup', '-d', receipt['device']], 15)
        (directory/'volume.ext4').unlink()
        receipt['cleanup']['owned_volume_released'] = True
    receipt['status'] = 'STOPPED'
    write(directory/'service.json', receipt)
    print(json.dumps({'status': 'STOPPED', 'cleanup': receipt['cleanup']}))


def install_transport(args):
    directory = args.directory.resolve()
    receipt = json.loads((directory/'service.json').read_text())
    mount = validate(directory, receipt)
    images = json.loads(args.images.read_text())
    real = '/workspace/env/deps/regctl/v0.11.5/regctl.real'
    lines = ['#!/bin/sh', 'set -eu',
             'aswr_rewrite() {',
             'aswr_n=$1; shift',
             '[ "$aswr_n" -gt 0 ] || exec '+real+' "$@"',
             'aswr_arg=$1; shift', 'case "$aswr_arg" in']
    for task, value in images.items():
        assert re.fullmatch(r'[A-Za-z0-9_.-]+', task)
        source = '/aswr-oci/'+task
        repository = value['image'].split('@', 1)[0]
        if ':' in repository.rsplit('/', 1)[-1]:
            repository = repository.rsplit(':', 1)[0]
        aliases = [repository, 'aswr.local/'+task]
        patterns = [shlex.quote(value['image'])]
        for alias in aliases:
            patterns += [shlex.quote(alias), shlex.quote(alias)+':*', shlex.quote(alias)+'@*']
        lines += ['|'.join(patterns)+')',
                  'if [ -f '+shlex.quote(source+'/index.json')+' ]; then',
                  'aswr_arg='+shlex.quote('ocidir://'+source+':latest'),
                  'fi', ';;']
    lines += ['esac', 'aswr_rewrite "$((aswr_n-1))" "$@" "$aswr_arg"',
              '}', 'aswr_rewrite "$#" "$@"', '']
    path = mount/'env/deps/regctl/v0.11.5/regctl'
    destination = path.with_name('regctl.real')
    if not destination.exists():
        path.rename(destination)
    path.write_text('\n'.join(lines))
    path.chmod(0o755)
    receipt['oci_transport'] = {'scope': 'manifest resolution and copying use the same local OCI export; native OverlayBD conversion retained',
                                'wrapper_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                                'real_sha256': hashlib.sha256(destination.read_bytes()).hexdigest()}
    write(directory/'service.json', receipt)
    os.chown(directory/'service.json', int(os.environ.get('SUDO_UID', 1012)),
             int(os.environ.get('SUDO_GID', 1012)))
    print('INSTALLED local OCI transport')


def launch_proxy(directory, proxy, upstream_port):
    uid, gid = int(os.environ.get('SUDO_UID', 1012)), int(os.environ.get('SUDO_GID', 1012))
    ready = directory/'guest-proxy-ready.json'
    ready.unlink(missing_ok=True)
    config=directory/'host-proxy-upstream.json'
    write(config,dict(host='127.0.0.1',port=upstream_port))
    os.chown(config,uid,gid)
    def user_identity():
        os.setgid(gid)
        os.setuid(uid)
    with (directory/'guest-proxy.log').open('ab') as log:
        process = subprocess.Popen([sys.executable, ROOT/'scripts/agentenv_workload_proxy.py',
            '--address', proxy['address'], '--port', str(proxy['port']), '--upstream-port', str(upstream_port),
            '--upstream-file', config,
            '--ready', ready], stdout=log, stderr=log, start_new_session=True, preexec_fn=user_identity)
    deadline = time.monotonic()+5
    while not ready.exists():
        assert process.poll() is None
        assert time.monotonic() < deadline
        time.sleep(.05)
    return process.pid


def start_proxy(args):
    directory = args.directory.resolve()
    receipt = json.loads((directory/'service.json').read_text())
    validate(directory, receipt)
    if args.upstream_port is None:
        args.upstream_port=urlsplit(receipt['host_proxy_url']).port
    assert not receipt.get('guest_proxy'), 'one private relay per experiment'
    addresses = run(['ip', '-j', 'addr', 'show']).decode()
    routes = run(['ip', '-j', 'route', 'show', 'table', 'all']).decode()
    address = next(ip for ip in ('192.0.2.17', '198.51.100.17', '203.0.113.17')
                   if ip.rsplit('.', 1)[0] not in addresses+routes)
    with socket.create_connection(('127.0.0.1', args.upstream_port), timeout=3):
        pass
    run(['ip', 'addr', 'add', address+'/32', 'dev', 'lo'], 10)
    with socket.socket() as sock:
        sock.bind((address, 0))
        port = sock.getsockname()[1]
    pid=launch_proxy(directory,dict(address=address,port=port),args.upstream_port)
    uid, gid = int(os.environ.get('SUDO_UID', 1012)), int(os.environ.get('SUDO_GID', 1012))
    receipt['guest_proxy'] = dict(pid=pid, address=address, port=port,
        url=f'http://{address}:{port}', upstream='existing host loopback HTTP proxy',
        allowed_peer_cidrs=['10.211.0.0/16', '10.212.0.0/16', '169.254.0.20/30'],
        temporary_loopback_alias=True)
    write(directory/'service.json', receipt)
    os.chown(directory/'service.json', uid, gid)
    print(json.dumps({'status': 'READY', 'guest_proxy': receipt['guest_proxy']}))


def restart_proxy(args):
    from agentenv_workload_client import Client
    directory=args.directory.resolve()
    receipt=json.loads((directory/'service.json').read_text())
    validate(directory,receipt)
    assert Client(directory).api('GET','/sandboxes')==[]
    proxy=receipt['guest_proxy']
    with socket.create_connection(('127.0.0.1',args.upstream_port),timeout=3):
        pass
    previous=proxy['pid']
    try:
        command=Path('/proc',str(previous),'cmdline').read_bytes()
        assert b'agentenv_workload_proxy.py' in command and str(directory).encode() in command
        os.kill(previous,signal.SIGTERM)
        time.sleep(.3)
    except FileNotFoundError:
        pass
    proxy['pid']=launch_proxy(directory,proxy,args.upstream_port)
    proxy['reload_upstream_per_connection']=True
    receipt['host_proxy_url']='http://127.0.0.1:'+str(args.upstream_port)
    receipt.setdefault('proxy_restarts',[]).append(dict(timestamp_ns=time.time_ns(),
        previous_pid=previous,pid=proxy['pid'],upstream_port=args.upstream_port,
        reason='old host session proxy port expired; retain owned guest endpoint and INPUT rule'))
    write(directory/'service.json',receipt)
    os.chown(directory/'service.json',int(os.environ.get('SUDO_UID',1012)),int(os.environ.get('SUDO_GID',1012)))
    print('READY: owned relay upstream is reloadable; guest endpoint unchanged')


def allow_proxy(args):
    directory = args.directory.resolve()
    receipt = json.loads((directory/'service.json').read_text())
    validate(directory, receipt)
    proxy = receipt['guest_proxy']
    if proxy.get('input_rule'):
        previous = subprocess.run([proxy['iptables_binary'], '-D', 'INPUT', *proxy['input_rule']],
                                  capture_output=True, timeout=10)
    # AgentENV deliberately rejects new guest-to-host connections. Permit only
    # this experiment's network -> this owned relay address and TCP port.
    candidates = []
    binary = None
    for candidate in ('iptables', 'iptables-legacy', 'iptables-nft'):
        output = subprocess.run([candidate, '-S', 'INPUT'], capture_output=True, text=True, timeout=10)
        candidates = [line.split() for line in output.stdout.splitlines()
                      if '-s 10.211.0.0/16' in line and '-j REJECT' in line]
        if candidates:
            binary = candidate
            break
    assert len(candidates) == 1, candidates
    interface = candidates[0][candidates[0].index('-i')+1]
    rule = ['-i', interface, '-s', '10.211.0.0/16', '-d', proxy['address']+'/32',
            '-p', 'tcp', '--dport', str(proxy['port']), '-m', 'comment',
            '--comment', 'aswr-'+directory.name, '-j', 'ACCEPT']
    run([binary, '-I', 'INPUT', '1', *rule], 10)
    proxy['input_rule'] = rule
    proxy['iptables_binary'] = binary
    write(directory/'service.json', receipt)
    os.chown(directory/'service.json', int(os.environ.get('SUDO_UID', 1012)),
             int(os.environ.get('SUDO_GID', 1012)))
    print('READY: only the owned relay TCP endpoint is permitted from the private experiment CIDR')


def reset_cache(args):
    from agentenv_workload_client import Client
    directory = args.directory.resolve()
    receipt = json.loads((directory/'service.json').read_text())
    mount = validate(directory, receipt)
    assert Client(directory).api('GET', '/sandboxes') == [], 'never reset cache with a live sandbox'
    cache = mount/'env/image-cache'
    assert cache.is_dir() and not cache.is_symlink()
    count, allocated = 0, 0
    for path in cache.rglob('*'):
        st = path.lstat()
        if path.is_file() and not path.is_symlink():
            count += 1
            allocated += st.st_blocks*512
    cid = receipt['container_id']
    inspected = json.loads(run(['docker', 'inspect', cid]))[0]
    assert inspected['Config']['Labels']['agentsandboxbench.workload_run'] == directory.name
    run(['docker', 'stop', '-t', '15', cid], 35)
    shutil.rmtree(cache)
    cache.mkdir()
    run(['docker', 'start', cid], 30)
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    deadline = time.monotonic()+60
    while time.monotonic()<deadline:
        try:
            with opener.open(receipt['service_url']+'/health', timeout=3) as response:
                if response.status in (200, 204):
                    break
        except Exception:
            time.sleep(.5)
    else:
        raise TimeoutError('private service restart health timeout')
    receipt.setdefault('capacity_cache_resets', []).append(dict(timestamp_ns=time.time_ns(),
        released_allocated_bytes=allocated, files=count, reason='between tasks, fixed-volume capacity',
        scope='only private service image cache; all raw, OCI inputs, credentials and fixed dependencies preserved'))
    write(directory/'service.json', receipt)
    os.chown(directory/'service.json', int(os.environ.get('SUDO_UID', 1012)),
             int(os.environ.get('SUDO_GID', 1012)))
    print('CACHE_RESET released_bytes='+str(allocated), flush=True)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest='action', required=True)
    sp = sub.add_parser('start')
    sp.add_argument('--capacity-gib', type=int, default=40)
    current_proxy=os.environ.get('HTTPS_PROXY') or os.environ.get('HTTP_PROXY')
    sp.add_argument('--host-proxy-url',default=current_proxy,required=not current_proxy)
    sp = sub.add_parser('stop')
    sp.add_argument('directory', type=Path)
    sp.add_argument('--release', action='store_true')
    sp = sub.add_parser('install-transport')
    sp.add_argument('directory', type=Path)
    sp.add_argument('--images', type=Path, required=True)
    sp = sub.add_parser('start-proxy')
    sp.add_argument('directory', type=Path)
    sp.add_argument('--upstream-port', type=int)
    sp = sub.add_parser('restart-proxy')
    sp.add_argument('directory', type=Path)
    sp.add_argument('--upstream-port', type=int, required=True)
    sp = sub.add_parser('allow-proxy')
    sp.add_argument('directory', type=Path)
    sp = sub.add_parser('reset-cache')
    sp.add_argument('directory', type=Path)
    args = ap.parse_args()
    assert os.geteuid() == 0, 'root is required for the private VM service'
    {'start': start, 'stop': stop, 'install-transport': install_transport,
     'start-proxy': start_proxy, 'restart-proxy': restart_proxy,
     'allow-proxy': allow_proxy, 'reset-cache': reset_cache}[args.action](args)
