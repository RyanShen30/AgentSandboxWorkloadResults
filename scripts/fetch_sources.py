#!/usr/bin/env python3
"""Fetch exact upstream files into a separate directory and verify their hashes."""
from pathlib import Path
import argparse,hashlib,json,urllib.request
ROOT=Path(__file__).resolve().parents[1]
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--task',help='default: all ten tasks');ap.add_argument('--dry-run',action='store_true');a=ap.parse_args()
 files=[]
 for p in sorted((ROOT/'experiments/container-screening/workloads').glob('*/provenance.json')):
  if a.task and p.parent.name!=a.task:continue
  files.extend(json.loads(p.read_text()).get('files',[]))
 if not files:raise SystemExit('No matching task')
 for f in files:
  dst=a.output.resolve()/f['path'];print(f['path'],f['sha256'],flush=True)
  if a.dry_run:continue
  if dst.exists():
   if hashlib.sha256(dst.read_bytes()).hexdigest()==f['sha256']:continue
   raise SystemExit('Existing file hash differs; refusing overwrite: '+str(dst))
  with urllib.request.urlopen(f['url'],timeout=180) as response:data=response.read()
  if hashlib.sha256(data).hexdigest()!=f['sha256']:raise SystemExit('Upstream content changed or download incomplete: '+f['url'])
  dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(data)
if __name__=='__main__':main()
