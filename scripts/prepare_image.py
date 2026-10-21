#!/usr/bin/env python3
"""Prepare one pinned workload image in an already materialized workspace."""
from pathlib import Path
import argparse,json,shlex,subprocess
ROOT=Path(__file__).resolve().parents[1]
def commands(task,workspace):
 config=json.loads((ROOT/'provenance/images.json').read_text())[task];layout=json.loads((workspace/'runtime-layout.json').read_text());pod=layout['podman'];image=config['image'];envdir=ROOT/'experiments/container-screening/environments'
 if task=='mozilla__pdf.js-20957':return [[*pod,'build','--format','docker','--network','host','-t',image,'-f',str(envdir/'pdfjs.Containerfile'),str(envdir)]]
 if task=='apache__logging-log4j2':
  repo=workspace/'preparation/log4j-source';commit='204d8251295dfa816b9b28d8d9cfaebab500f415'
  return [['git','init',str(repo)],['git','-C',str(repo),'remote','add','origin','https://github.com/apache/logging-log4j2.git'],['git','-C',str(repo),'-c','http.version=HTTP/1.1','fetch','--depth','1','origin',commit],['git','-C',str(repo),'checkout','--detach','FETCH_HEAD'],[*pod,'build','--format','docker','-t',image,'-f',str(envdir/'log4j.Containerfile'),str(repo)]]
 return [[*pod,*(['--storage-opt','overlay.ignore_chown_errors=true'] if task=='matplotlib__matplotlib-24177' else []),'pull',image]]
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--workspace',type=Path,required=True);ap.add_argument('--task',required=True,choices=list(json.loads((ROOT/'provenance/images.json').read_text())));ap.add_argument('--dry-run',action='store_true');args=ap.parse_args()
 for cmd in commands(args.task,args.workspace.resolve()):
  print(shlex.join(cmd),flush=True)
  if not args.dry_run:subprocess.run(cmd,check=True,timeout=1800)
if __name__=='__main__':main()
