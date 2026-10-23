"""Minimal documented AgentENV REST/Connect JSON transport, without a CLI dependency."""
import base64
import json
from pathlib import Path
import struct
import uuid

import requests


class Client:
    def __init__(self, directory):
        self.directory = Path(directory)
        self.credentials = json.loads((self.directory/'credentials.json').read_text())
        self.url = self.credentials['url']
        assert self.url.startswith('http://127.0.0.1:')
        self.session = requests.Session()
        self.session.trust_env = False
        self.session.headers['X-API-Key'] = self.credentials['api_key']
        self.tokens = {}

    def api(self, method, path, body=None, timeout=60):
        r = self.session.request(method, self.url+path, json=body,
                                 timeout=(5, timeout), allow_redirects=False)
        if not 200 <= r.status_code < 300:
            raise RuntimeError(f'AgentENV {method} {path}: HTTP {r.status_code}: {r.text[:1200]}')
        return r.json() if r.content else None

    def create(self, image, memory_mib=8192):
        value = self.api('POST', '/sandboxes-cold',
                         dict(image=image, timeout=14400, cpuCount=2,
                              memoryMB=memory_mib, secure=True), timeout=900)
        sid = value['sandboxID']
        assert str(uuid.UUID(sid)) == sid
        self.tokens[sid] = value.get('envdAccessToken')
        if not self.tokens[sid]:
            self.tokens[sid] = self.api('GET', '/sandboxes/'+sid).get('envdAccessToken')
        return sid

    def headers(self, sid):
        if sid not in self.tokens:
            self.tokens[sid] = self.api('GET', '/sandboxes/'+sid).get('envdAccessToken')
        headers = {'x-agentenv-sandbox-id': sid, 'x-agentenv-target-port': '49983',
                   'Connect-Protocol-Version': '1'}
        if self.tokens[sid]:
            headers['X-Access-Token'] = self.tokens[sid]
        return headers

    @staticmethod
    def read_exact(stream, count):
        parts = []
        while count:
            data = stream.read(count)
            if not data:
                raise EOFError('truncated Connect envelope')
            parts.append(data)
            count -= len(data)
        return b''.join(parts)

    def execute(self, sid, command, args=(), env=None, cwd=None, stdout=None, stderr=None):
        process = dict(cmd=command, args=list(args), envs=env or {})
        if cwd:
            process['cwd'] = cwd
        message = json.dumps(dict(process=process, stdin=False)).encode()
        headers = dict(self.headers(sid), **{'Content-Type': 'application/connect+json'})
        out, err, exit_code, process_error = bytearray(), bytearray(), None, None
        with self.session.post(self.url+'/process.Process/Start', headers=headers,
                               data=struct.pack('>BI', 0, len(message))+message,
                               stream=True, timeout=(5, 90), allow_redirects=False) as r:
            if r.status_code != 200:
                raise RuntimeError(f'envd Start: HTTP {r.status_code}: {r.text[:1500]}')
            while True:
                flag, length = struct.unpack('>BI', self.read_exact(r.raw, 5))
                if length > 16*1024**2:
                    raise ValueError('envd envelope exceeds 16 MiB')
                data = json.loads(self.read_exact(r.raw, length))
                if flag & 2:
                    if data.get('error'):
                        raise RuntimeError('Connect end error: '+str(data['error']))
                    break
                event = data.get('event', {})
                for key, target, memory in [('stdout', stdout, out), ('stderr', stderr, err)]:
                    if key in event.get('data', {}):
                        decoded = base64.b64decode(event['data'][key])
                        if target is not None:
                            target.write(decoded)
                            target.flush()
                        else:
                            if len(memory) + len(decoded) > 32*1024**2:
                                raise ValueError('uncaptured envd output exceeds 32 MiB')
                            memory.extend(decoded)
                if 'end' in event:
                    exit_code = event['end'].get('exitCode', 0)
                    process_error = event['end'].get('error')
        if exit_code is None:
            raise RuntimeError('envd stream ended without process exit event')
        return dict(exit_code=exit_code, stdout=bytes(out), stderr=bytes(err), process_error=process_error)

    def upload(self, sid, local, remote):
        with Path(local).open('rb') as stream:
            r = self.session.post(self.url+'/files', params={'path': remote, 'username': 'root'},
                                  headers=self.headers(sid), files={'file': (Path(local).name, stream)},
                                  timeout=(5, 120), allow_redirects=False)
        if r.status_code != 200:
            raise RuntimeError(f'envd upload: HTTP {r.status_code}: {r.text[:1000]}')

    def download(self, sid, remote, local):
        with self.session.get(self.url+'/files', params={'path': remote, 'username': 'root'},
                              headers=self.headers(sid), stream=True, timeout=(5, 120),
                              allow_redirects=False) as response:
            if response.status_code != 200:
                raise RuntimeError(f'envd download: HTTP {response.status_code}')
            with Path(local).open('xb') as stream:
                for chunk in response.iter_content(1024**2):
                    stream.write(chunk)

    def delete(self, sid):
        self.api('DELETE', '/sandboxes/'+sid, timeout=90)
        self.tokens.pop(sid, None)
