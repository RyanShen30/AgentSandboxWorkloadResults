"""Transport regressions that would otherwise invalidate failed-tool trajectories."""
import base64
import io
import json
from pathlib import Path
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'scripts'))
from agentenv_workload_client import Client


def frame(value, flag=0):
    data = json.dumps(value).encode()
    return struct.pack('>BI', flag, len(data))+data


class Response:
    status_code = 200

    def __init__(self, raw):
        self.raw = io.BytesIO(raw)

    def __enter__(self):
        return self

    def __exit__(self, *_):
        return False


class Session:
    def __init__(self, raw):
        self.raw = raw

    def post(self, *_args, **_kwargs):
        return Response(self.raw)


class TransportTests(unittest.TestCase):
    def client(self, raw):
        client = Client.__new__(Client)
        client.url = 'http://127.0.0.1:1'
        client.session = Session(raw)
        client.headers = lambda _: {}
        return client

    def test_nonzero_tool_exit_is_not_transport_failure(self):
        raw = (frame({'event': {'data': {'stdout': base64.b64encode(b'kept').decode()}}})+
               frame({'event': {'end': {'exitCode': 7, 'exited': True, 'error': 'exit status 7'}}})+
               frame({}, 2))
        result = self.client(raw).execute('sandbox', '/bin/bash')
        self.assertEqual(result['exit_code'], 7)
        self.assertEqual(result['stdout'], b'kept')

    def test_truncated_response_is_not_success(self):
        with self.assertRaises(EOFError):
            self.client(struct.pack('>BI', 0, 10)+b'{}').execute('sandbox', 'true')

    def test_missing_process_end_is_not_success(self):
        with self.assertRaisesRegex(RuntimeError, 'without process exit'):
            self.client(frame({}, 2)).execute('sandbox', 'true')


if __name__ == '__main__':
    unittest.main()
