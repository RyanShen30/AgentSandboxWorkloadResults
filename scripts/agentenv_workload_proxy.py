"""Private TCP relay to the existing host HTTP proxy; never log request contents."""
import argparse
import ipaddress
import json
from pathlib import Path
import selectors
import socket
import threading
import time


def relay(connection, upstream_port):
    upstream = None
    try:
        upstream = socket.create_connection(('127.0.0.1', upstream_port), timeout=5)
        connection.settimeout(60)
        upstream.settimeout(60)
        with selectors.DefaultSelector() as selector:
            selector.register(connection, selectors.EVENT_READ, upstream)
            selector.register(upstream, selectors.EVENT_READ, connection)
            while True:
                ready = selector.select(timeout=180)
                if not ready:
                    return
                for key, _ in ready:
                    data = key.fileobj.recv(128*1024)
                    if not data:
                        return
                    key.data.sendall(data)
    except (OSError, TimeoutError):
        pass
    finally:
        connection.close()
        if upstream:
            upstream.close()


def main(args):
    allowed = [ipaddress.ip_network('10.211.0.0/16'), ipaddress.ip_network('10.212.0.0/16'),
               ipaddress.ip_network('169.254.0.20/30')]
    slots = threading.BoundedSemaphore(48)
    def worker(connection):
        try:
            port=args.upstream_port
            if args.upstream_file:
                config=json.loads(args.upstream_file.read_text())
                assert config['host']=='127.0.0.1' and 1<=int(config['port'])<=65535
                port=int(config['port'])
            relay(connection, port)
        finally:
            slots.release()
    with socket.socket() as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((args.address, args.port))
        server.listen(48)
        args.ready.write_text(json.dumps(dict(pid=__import__('os').getpid(),
                                              ready_ns=time.time_ns(), address=args.address, port=args.port))+'\n')
        while True:
            connection, peer = server.accept()
            address = ipaddress.ip_address(peer[0])
            if not any(address in network for network in allowed) or not slots.acquire(blocking=False):
                connection.close()
                continue
            threading.Thread(target=worker, args=(connection,), daemon=True).start()


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--address', required=True)
    ap.add_argument('--port', required=True, type=int)
    ap.add_argument('--upstream-port', default=17891, type=int)
    ap.add_argument('--upstream-file', type=Path)
    ap.add_argument('--ready', type=Path, required=True)
    main(ap.parse_args())
