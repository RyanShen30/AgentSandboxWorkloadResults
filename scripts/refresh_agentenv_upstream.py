"""Refresh only the owned relay's loopback upstream from the current tool environment."""
import argparse
import json
import os
from pathlib import Path
import socket
import time
from urllib.parse import urlsplit


def refresh(service, proxy_url=None):
    url=urlsplit(proxy_url or os.environ.get('HTTPS_PROXY') or os.environ['HTTP_PROXY'])
    assert url.scheme=='http' and url.hostname=='127.0.0.1' and url.port
    assert not url.username and not url.password
    with socket.create_connection(('127.0.0.1',url.port),timeout=3):
        pass
    path=service/'host-proxy-upstream.json'
    value=dict(host='127.0.0.1',port=url.port)
    changed=not path.exists() or json.loads(path.read_text())!=value
    if changed:
        temporary=path.with_suffix('.tmp')
        temporary.write_text(json.dumps(value)+'\n')
        temporary.replace(path)
        info=json.loads((service/'service.json').read_text())
        info['host_proxy_url']=f'http://127.0.0.1:{url.port}'
        info.setdefault('upstream_refreshes',[]).append(dict(timestamp_ns=time.time_ns(),port=url.port))
        temporary=service/'service.tmp.json'
        temporary.write_text(json.dumps(info,indent=2)+'\n')
        temporary.replace(service/'service.json')
    print(json.dumps(dict(status='READY',upstream_port=url.port,changed=changed)))


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--service',type=Path,required=True)
    ap.add_argument('--proxy-url')
    a=ap.parse_args();refresh(a.service.resolve(),a.proxy_url)
