"""Sample the private service cgroup; this is not guest file-cache accounting."""
import argparse
import json
from pathlib import Path
import time


def main(args):
    service = args.service.resolve()
    info = json.loads((service/'service.json').read_text())
    cid = info['container_id']
    candidates = [Path('/sys/fs/cgroup/system.slice')/('docker-'+cid+'.scope'),
                  Path('/sys/fs/cgroup/docker')/cid]
    group = next(p for p in candidates if (p/'memory.current').exists())
    path = service/'mount/raw'/('host-service-'+str(time.time_ns())+'.jsonl')
    started, count, errors = time.monotonic(), 0, []
    with path.open('x', buffering=1) as stream:
        while not (service/'host-sampler-stop').exists() and time.monotonic()-started < 14400:
            try:
                memory = dict(line.split() for line in (group/'memory.stat').read_text().splitlines())
                value = dict(timestamp_ns=time.time_ns(), monotonic_ns=time.monotonic_ns(),
                             memory_current_bytes=int((group/'memory.current').read_text()),
                             memory_peak_bytes=int((group/'memory.peak').read_text()),
                             **{k+'_bytes': int(memory[k]) for k in ('anon', 'file', 'shmem', 'kernel')})
                stream.write(json.dumps(value)+'\n')
                count += 1
            except Exception as exc:
                errors.append({'timestamp_ns': time.time_ns(), 'error': repr(exc)})
            time.sleep(.2)
    path.with_suffix('.status.json').write_text(json.dumps(dict(samples=count, errors=errors,
        cgroup=str(group), interval_seconds=.2,
        scope='private AgentENV service: VMM/provider and charged caches; excludes external image preparation; never guest file-cache'), indent=2)+'\n')
    print('HOST_SAMPLER_STOPPED', path, count, flush=True)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service', required=True, type=Path)
    main(ap.parse_args())
