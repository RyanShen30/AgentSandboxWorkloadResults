#!/usr/bin/env python3
"""Read-only verification of archived file hashes, raw evidence, and Markdown links."""
from pathlib import Path
import argparse,gzip,hashlib,json,re,tarfile
from urllib.parse import unquote
ROOT=Path(__file__).resolve().parents[1]
def sha(b):return hashlib.sha256(b).hexdigest()
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--write-manifest',action='store_true',help='update tracked-file checksum inventory after an intentional report edit');a=ap.parse_args()
 manifest_path=ROOT/'provenance/artifact-sha256.json';exclude={manifest_path,' .git'}
 files=sorted(p for p in ROOT.rglob('*') if p.is_file() and not p.is_symlink() and '.git' not in p.parts and '__pycache__' not in p.parts and '.venv' not in p.parts and p!=manifest_path)
 hashes={str(p.relative_to(ROOT)):{'bytes':p.stat().st_size,'sha256':sha(p.read_bytes())} for p in files}
 errors=[]
 if a.write_manifest:manifest_path.write_text(json.dumps(hashes,ensure_ascii=False,indent=2)+'\n')
 elif not manifest_path.exists():errors.append('Missing artifact manifest; create it after intentional changes with --write-manifest')
 else:
  old=json.loads(manifest_path.read_text())
  for p in set(old)|set(hashes):
   if old.get(p)!=hashes.get(p):errors.append('Artifact checksum mismatch: '+p)
 inv=json.loads(gzip.decompress((ROOT/'provenance/server-file-inventory.json.gz').read_bytes()));lookup={}
 for item in inv:
  rid=item.get('run_id');key=item['path'].split('/',2)[-1] if rid else item['path'];lookup[(rid,key)]=item['sha256']
 recs=json.loads((ROOT/'provenance/runs.json').read_text());raw_checks=0
 for r in recs:
  p=ROOT/r['path']
  for f in p.iterdir():
   if f.name in {'curves.svg','curves.png','metrics.json'}:continue
   if f.suffix=='.gz' and f.name!='tool-files.tar.gz':name=f.name[:-3];data=gzip.decompress(f.read_bytes())
   elif f.is_file():name=f.name;data=f.read_bytes()
   else:continue
   expected=lookup.get((r['run_id'],name))
   if expected:
    raw_checks+=1
    if sha(data)!=expected:errors.append('Original run file mismatch: '+str(f.relative_to(ROOT)))
  with tarfile.open(p/'tool-files.tar.gz','r:gz') as tf:
   for m in tf.getmembers():
    if not m.isfile():errors.append('Nonregular tar member: '+m.name);continue
    raw_checks+=1;expected=lookup.get((r['run_id'],m.name))
    if expected!=sha(tf.extractfile(m).read()):errors.append('Original tool file mismatch: '+r['run_id']+'/'+m.name)
 for bundle in (ROOT/'experiments/container-screening/workloads').glob('*/replay-inputs.tar.gz'):
  with tarfile.open(bundle,'r:gz') as tf:
   for m in tf.getmembers():
    raw_checks+=1
    if not m.isfile() or lookup.get((None,m.name))!=sha(tf.extractfile(m).read()):errors.append('Source bundle mismatch: '+m.name)
 links=0
 for p in ROOT.rglob('*.md'):
  if any(s in p.parts for s in ['.git','.venv','templates']):continue
  for link in re.findall(r'\[[^\]]*\]\(([^\s)]+)\)',p.read_text()):
   if re.match(r'^[a-z]+:',link) or link.startswith('#'):continue
   target=(p.parent/unquote(link.split('#',1)[0])).resolve();links+=1
   if not target.exists():errors.append('Broken link: '+str(p.relative_to(ROOT))+' -> '+link)
 report=json.loads((ROOT/'provenance/report-validation.json').read_text())
 if report['primary_task_count']!=10 or report['run_count']!=11 or report['primary_calls']!=652 or report['primary_boundaries']!=662:errors.append('Unexpected aggregate counts')
 if not all(all(x.values()) for x in report['per_run'].values()):errors.append('A collection check failed')
 print(json.dumps({'status':'FAIL' if errors else 'PASS','files':len(hashes),'raw_file_hash_checks':raw_checks,'local_links':links,'errors':errors},ensure_ascii=False,indent=2))
 raise SystemExit(bool(errors))
if __name__=='__main__':main()
