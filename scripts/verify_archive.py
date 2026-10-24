#!/usr/bin/env python3
"""Validate the public documentation package; raw archives are deliberately external."""
from pathlib import Path
import hashlib,json,re,argparse
from urllib.parse import unquote
R=Path(__file__).resolve().parents[1]
def main():
 a=argparse.ArgumentParser();a.add_argument('--write-manifest',action='store_true');args=a.parse_args();p=R/'provenance/artifact-sha256.json'
 data={str(f.relative_to(R)):{'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in sorted(R.rglob('*')) if f.is_file() and '.git' not in f.parts and '__pycache__' not in f.parts and '.venv' not in f.parts and not f.name.endswith('.gz') and f.name not in {'validation.stdout','validation.stderr','dependency-inventory.txt'} and f!=p}
 if args.write_manifest:p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 errors=[]
 if not p.exists() or json.loads(p.read_text())!=data:errors.append('Public artifact manifest mismatch')
 links=0
 for f in R.rglob('*.md'):
  if 'templates' in f.parts:continue
  for link in re.findall(r'\[[^\]]*\]\(([^\s)]+)\)',f.read_text()):
   if re.match(r'^[a-z]+:',link) or link.startswith('#'):continue
   links+=1
   if not (f.parent/unquote(link.split('#',1)[0])).exists():errors.append(str(f.relative_to(R))+' -> '+link)
 docs=[p for p in R.glob('results/*/README.md') if p.parent.name!='agentenv']
 agentenv=R/'provenance/agentenv-runs.json'
 if agentenv.exists():
  selected=json.loads(agentenv.read_text())['primary']
  if len(selected)!=10 or len({r['task_id'] for r in selected})!=10:errors.append('Expected ten AgentENV primary tasks')
  for r in selected:
   if not (R/'results/agentenv'/r['task_id']/'README.md').exists():errors.append('Missing AgentENV task document: '+r['task_id'])
 if len(docs)!=10:errors.append('Expected ten task documents')
 print(json.dumps({'status':'FAIL' if errors else 'PASS','public_files':len(data)+1,'local_links':links,'task_documents':len(docs),'raw_archives':'excluded from public commit; retained on cpu-15','errors':errors},ensure_ascii=False,indent=2));raise SystemExit(bool(errors))
if __name__=='__main__':main()
