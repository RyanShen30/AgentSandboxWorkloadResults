#!/usr/bin/env python3
"""Prepare a separate runtime directory. Does not pull images or run tasks."""
from pathlib import Path
import argparse,gzip,hashlib,json,os,shutil,subprocess,tarfile
ROOT=Path(__file__).resolve().parents[1]
ARCHIVE_ROOT=Path(os.environ.get('ASWR_ARCHIVE_ROOT',str(ROOT)))
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--workspace',type=Path,required=True);ap.add_argument('--compile',action='store_true',help='compile three static C instrumentation helpers');args=ap.parse_args();dst=args.workspace.resolve()
 if len(list((ARCHIVE_ROOT/'experiments/container-screening/workloads').glob('*/replay-inputs.tar.gz')))!=10:
  raise SystemExit('Fixed replay input archives are retained on cpu-15. Set ASWR_ARCHIVE_ROOT to the full local archive.')
 if dst.exists() and any(dst.iterdir()):raise SystemExit('Workspace must be empty; select a new directory.')
 dst.mkdir(parents=True,exist_ok=True)
 runroot=f'/tmp/aswr-{os.getuid()}-{hashlib.sha256(str(dst).encode()).hexdigest()[:10]}'
 patches=[]
 for p in (ROOT/'experiments/container-screening/harness').iterdir():
  if not p.is_file():continue
  s=p.read_text()
  if p.name.startswith('runner'):
   old='"/tmp/asbp-1012-20261020"';assert s.count(old)==1
   new=s.replace(old,json.dumps(runroot));patches.append({'file':p.name,'only_change':'replace Podman runroot with per-workspace path','source_sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'runtime_sha256':hashlib.sha256(new.encode()).hexdigest()});s=new
  (dst/p.name).write_text(s)
 for p in sorted((ARCHIVE_ROOT/'experiments/container-screening/workloads').glob('*/replay-inputs.tar.gz')):
  with tarfile.open(p,'r:gz') as tf:
   for member in tf.getmembers():
    target=dst/member.name
    if not member.isfile() or not target.resolve().is_relative_to(dst):raise ValueError('Unexpected archive member: '+member.name)
    target.parent.mkdir(parents=True,exist_ok=True)
    with tf.extractfile(member) as f:target.write_bytes(f.read())
 for name in ['state/storage','results','preparation']: (dst/name).mkdir(parents=True,exist_ok=True)
 layout={'workspace':str(dst),'podman':['podman','--root',str(dst/'state/storage'),'--runroot',runroot],'harness_patches':patches,'scope':'runtime materialization only; no workload has been run'}
 (dst/'runtime-layout.json').write_text(json.dumps(layout,indent=2)+'\n')
 if args.compile:
  for name in ['tool_timer','file_reader','clock_ns']:subprocess.run(['gcc','-O2','-static',str(dst/(name+'.c')),'-o',str(dst/name)],check=True)
 print(json.dumps(layout,ensure_ascii=False,indent=2))
if __name__=='__main__':main()
