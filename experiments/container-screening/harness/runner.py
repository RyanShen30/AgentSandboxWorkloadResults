#!/usr/bin/env python3
"""Standalone rootless-Podman replay with cgroup telemetry and paused cache scans."""
from pathlib import Path
import argparse, base64, csv, hashlib, json, os, re, shlex, shutil, subprocess, sys, threading, time, traceback
from cache_scan import two_pass
ROOT=Path(__file__).resolve().parent
POD=["podman","--root",str(ROOT/"state/storage"),"--runroot","/tmp/asbp-1012-20261020"]
IMAGES={
"reshard-c4-data":"docker.io/alexgshaw/reshard-c4-data@sha256:92d209e704785e17ad6b3f740e813dd72bc7ac33982ce435d197ab9d890eac2a",
"large-scale-text-editing":"docker.io/alexgshaw/large-scale-text-editing@sha256:719adca3f1388220546ce6a155eee56eff3c4fe318183100320606a210f6b59c",
"hf-model-inference":"docker.io/alexgshaw/hf-model-inference@sha256:0ef475aebda8abb8cbf3a1d97aee8ac4b09ca9720550e25a4a46a47930cd3bad",
"build-cython-ext":"docker.io/alexgshaw/build-cython-ext@sha256:3612a38fadb89a96f74a1a951fb0b0af734198fd160571eeaba6401593234594",
"mozilla__pdf.js-20957":"localhost/asbp-pdfjs:484518614d75"}
def proxy_args():
    result=["--http-proxy=false"]
    for key,value in os.environ.items():
        if key.lower().endswith("_proxy"):
            if key.lower()!="no_proxy":value=value.replace("127.0.0.1","10.0.2.2").replace("localhost","10.0.2.2")
            result.extend(["--env",key+"="+value])
    return result
def dump(path,value):path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+"\n")
def append(path,value):
    with path.open("a") as f:f.write(json.dumps(value,ensure_ascii=False)+"\n")
def pod(*args,timeout=60,check=True,stdout=None,stderr=None):
    p=subprocess.run(POD+list(args),capture_output=stdout is None and stderr is None,stdout=stdout,stderr=stderr,text=True,timeout=timeout)
    if check and p.returncode:raise RuntimeError("podman "+str(args[:3])+": "+(p.stderr or "")[-1200:])
    return p
def kv(path):
    return {k:int(v) for k,v in (l.split() for l in path.read_text().splitlines())}
def sample(cg):
    now=time.monotonic_ns();m=kv(cg/"memory.stat");cpu=kv(cg/"cpu.stat")
    return {"timestamp_ns":now,"memory_current_bytes":int((cg/"memory.current").read_text()),"memory_peak_bytes":int((cg/"memory.peak").read_text()),"anon_bytes":m.get("anon",0),"file_bytes":m.get("file",0),"shmem_bytes":m.get("shmem",0),"disk_file_charge_bytes":max(0,m.get("file",0)-m.get("shmem",0)),"file_mapped_bytes":m.get("file_mapped",0),"file_dirty_bytes":m.get("file_dirty",0),"cpu_usage_usec":cpu.get("usage_usec",0),"pids_current":int((cg/"pids.current").read_text())}
class Monitor:
    def __init__(self,cg,path):self.cg,self.path=cg,path;self.stop=threading.Event();self.errors=[];self.phase="baseline";self.step=0
    def loop(self):
        with self.path.open("a",buffering=1) as f:
            while not self.stop.is_set():
                try:v=sample(self.cg);v.update(phase=self.phase,step=self.step);f.write(json.dumps(v)+"\n")
                except Exception as e:self.errors.append(str(e))
                self.stop.wait(.2)
    def start(self):self.thread=threading.Thread(target=self.loop,daemon=True);self.thread.start()
    def close(self):self.stop.set();self.thread.join(timeout=5)
def expected(step):
    e=step.get("source_result") or {}
    if e.get("isError") is not None:
        result=e.get("result",{});details=result.get("details",{}) if isinstance(result,dict) else {}
        return {"source_is_error":bool(e["isError"]),"source_exit_code":details.get("exitCode",0 if not e["isError"] else None)}
    return {"source_is_error":None,"source_exit_code":step.get("source_exit_code")}
def normalize(task,step,payloads):
    tool,args=step["tool"],step["args"];changes=["Bash uses default pipeline exit semantics, matching published commands; no implicit pipefail."]
    if tool=="bash":
        cmd=args["command"]
        if task=="hf-model-inference":
            if "172.17.0.2" in cmd:cmd=cmd.replace("172.17.0.2","127.0.0.1");changes.append("Map published container IP to loopback for the same in-container HTTP check.")
            if "/proc/114" in cmd:
                cmd='pid="$(cat /probe/work/service.pid)"; '+cmd.replace("/proc/114","/proc/$pid")
                changes.append("Map published PID to the recorded background launcher PID; the Python service can run as its child.")
            if "nohup python3 app.py" in cmd:
                cmd=cmd.replace('echo "started pid $!"','pid=$!; printf "%s\\n" "$pid" > /probe/work/service.pid; echo "started pid $pid"')
                changes.append("Record background service PID for later identity checks.")
    elif tool=="write":
        path=args.get("path")
        if not path:
            cmd="printf '%s\\n' 'write: required path argument is missing' >&2; exit 64"
            changes.append("Preserve invalid source write as a validation failure; no destination is inferred.")
        else:
            content=args.get("content","")
            if task=="hf-model-inference" and path=="/app/download_model.py":
                content=content.replace("snapshot_download(MODEL_ID, local_dir=LOCAL_DIR)", 'snapshot_download(MODEL_ID, revision="714eb0fa89d2f80546fda750413ed43d93601a13", local_dir=LOCAL_DIR)')
                changes.append("Pin the public model revision; network download time remains part of this tool.")
            payload=payloads/f"{step['step']:03}.payload";payload.write_text(content)
            cmd="mkdir -p "+shlex.quote(str(Path(path).parent))+" && cat "+shlex.quote("/probe/input/"+payload.name)+" > "+shlex.quote(path)
            made_executable=step.get("source_result",{}).get("result",{}).get("details",{}).get("madeExecutable",False)
            if made_executable:
                cmd+=" && chmod +x "+shlex.quote(path)
                changes.append("Preserve the source write tool's madeExecutable metadata with chmod +x.")
            changes.append("Native write tool is bridged to a real in-container file write; original content is preserved except explicitly declared adaptations.")
    elif tool=="read":
        supplied=args["path"]
        meta=step.get("source_result",{}).get("result",{}).get("details",{}).get("meta",{})
        path=meta.get("source",{}).get("value") or re.sub(r":(?:raw|[0-9]+-[0-9]+)$","",supplied)
        span=meta.get("truncation",{}).get("shownRange")
        match=re.search(r":([0-9]+)-([0-9]+)$",supplied)
        if not span and match:span={"start":int(match[1]),"end":int(match[2])}
        reader=payloads/f"{step['step']:03}-read.py"
        reader.write_text("import io,sys\nfrom pathlib import Path\ndata=Path("+repr(path)+").read_bytes()\n"+
            ("sys.stdout.buffer.write(b''.join(line for i,line in enumerate(io.BytesIO(data),1) if "+str(span["start"])+" <= i <= "+str(span["end"])+"))\n" if span else "sys.stdout.buffer.write(data)\n"))
        cmd="python3 "+shlex.quote("/probe/input/"+reader.name)
        changes.append("Read adapter resolves the source tool's real path, reads full file bytes, and emits the published line span when available. Original semantic read implementation/timing is unavailable; output formatting is approximate.")
    else:raise RuntimeError("Unsupported tool "+tool)
    return cmd,changes
def freeze_scan(name,pid,cg,run,mon,step):
    mon.phase="pause_scan";mon.step=step;before=sample(cg);start=time.monotonic_ns()
    pod("pause",name);paused=time.monotonic_ns()
    events=kv(cg/"cgroup.events")
    if events.get("frozen")!=1:raise RuntimeError("cgroup did not report frozen=1")
    try:
        result=two_pass([f"/proc/{pid}/root"])
        result.update(step=step,pause_started_ns=start,pause_confirmed_ns=paused,cgroup_before=before,cgroup_while_paused=sample(cg),frozen_verified=True)
    finally:pod("unpause",name)
    result["resumed_ns"]=time.monotonic_ns();result["pause_seconds"]=(result["resumed_ns"]-start)/1e9
    append(run/"boundaries.jsonl",result);mon.phase="between_tools";return result
def verify(task,name,run):
    code={
"large-scale-text-editing":"test -f /app/output.csv && cmp -s /app/output.csv /app/expected.csv",
"hf-model-inference":"""python3 - <<'PYCHECK'
import json,urllib.request
for text,want in [('I love this excellent movie','positive'),('This is a horrible terrible movie','negative')]:
 r=urllib.request.Request('http://127.0.0.1:5000/sentiment',data=json.dumps({'text':text}).encode(),headers={'Content-Type':'application/json'})
 with urllib.request.urlopen(r,timeout=30) as f:d=json.load(f)
 assert d['sentiment']==want,d
 assert abs(sum(d['confidence'].values())-1)<1e-4,d
print('local service functional checks passed')
PYCHECK""",
"reshard-c4-data":"test -s /app/compress.py && test -s /app/decompress.py && python3 -m py_compile /app/compress.py /app/decompress.py",
"build-cython-ext":"""cd /tmp && python3 - <<'PYCHECK'
import subprocess
print("source_repo_commit:", subprocess.check_output(["git","-C","/app/pyknotid","rev-parse","HEAD"],text=True).strip())
from pyknotid import cinvariants
from pyknotid.spacecurves import chelpers,ccomplexity
assert all(str(x.__file__).endswith('.so') for x in [cinvariants,chelpers,ccomplexity])
print('compiled extensions import successfully')
PYCHECK""",
"mozilla__pdf.js-20957":"test -d /testbed/node_modules && test -d /testbed/build"
    }[task]
    with (run/"validation.stdout").open("w") as out,(run/"validation.stderr").open("w") as err:
        p=pod("exec",name,"bash","-o","pipefail","-c",code,timeout=120,check=False,stdout=out,stderr=err)
    return {"exit_code":p.returncode,"status":"PASS" if p.returncode==0 else "FAIL","scope":"local functional/artifact check; not the official benchmark hidden verifier","command":code}
def run_task(task,step_limit=None):
    stamp=time.strftime("%Y%m%dT%H%M%S");run=ROOT/"results"/f"{task}-{stamp}";run.mkdir(parents=True)
    for p in ["input","work","logs"]: (run/p).mkdir()
    steps=json.loads((ROOT/"sources"/task/"tool-steps.json").read_text())
    if step_limit:steps=steps[:step_limit]
    allnorm=[]
    for s in steps:
        cmd,changes=normalize(task,s,run/"input");script=run/"input"/f"{s['step']:03}.sh";script.write_text(cmd+"\n")
        allnorm.append({**s,"command":cmd,"changes":changes,"script_sha256":hashlib.sha256(script.read_bytes()).hexdigest(),**expected(s)})
    dump(run/"normalized-steps.json",allnorm)
    name="asbp-"+task.replace("_","-").replace(".","-")[:35]+"-"+stamp.lower()
    info={"task_id":task,"started_ns":time.monotonic_ns(),"backend":"rootless-podman","image":IMAGES[task],"container":name,"cpus":2,"memory_limit_bytes":8*1024**3,"sample_interval_seconds":.2,"initial_cache_policy":"Warmness uncontrolled after image preparation; initial residency is measured. No global cache drop.","memory_label":"Container cgroup memory (includes charged cache; not guest physical memory)","scope":"one real replay; native read/write adapters and dynamic IP/PID mappings declared in normalized-steps.json; adapter timing is not original native tool timing"}
    dump(run/"run.json",info);mon=None;status="FAIL";cleanup={}
    try:
        create=pod("run","-d","--name",name,"--cpus","2","--memory","8g","--memory-swap","8g","--pids-limit","1024","--shm-size","256m","--network","slirp4netns:allow_host_loopback=true",*proxy_args(),"--env","OMP_NUM_THREADS=2","--env","OPENBLAS_NUM_THREADS=2","--env","MKL_NUM_THREADS=2","--env","TOKENIZERS_PARALLELISM=false","--volume",str(ROOT/"tool_timer")+":/probe/tool_timer:ro","--volume",str(run/"input")+":/probe/input:ro","--volume",str(run/"work")+":/probe/work:rw","--entrypoint","sleep",IMAGES[task],"infinity",timeout=120)
        state=json.loads(pod("inspect",name).stdout)[0];pid=state["State"]["Pid"]
        path=Path("/proc")/str(pid)/"cgroup";rel=path.read_text().strip().split("0::",1)[1];cg=Path("/sys/fs/cgroup")/rel.lstrip("/")
        for f in ["memory.current","memory.stat","cgroup.events"]:
            if not (cg/f).exists():raise RuntimeError("Missing delegated cgroup metric "+f)
        info.update(pid=pid,cgroup=str(cg),container_id=create.stdout.strip(),image_id=state["Image"]);dump(run/"run.json",info)
        mon=Monitor(cg,run/"samples.jsonl");mon.start();freeze_scan(name,pid,cg,run,mon,0)
        started=time.monotonic()
        for s in allnorm:
            if shutil.disk_usage(ROOT).free<20*1024**3:raise RuntimeError("free disk below 20 GiB")
            if time.monotonic()-started>3600:raise RuntimeError("Task replay exceeded 3600 seconds")
            i=s["step"];mon.phase="tool";mon.step=i;dispatch=time.monotonic_ns()
            print(task,"STEP_START",i,s["tool"],flush=True)
            with (run/"logs"/f"{i:03}.stdout").open("w") as out,(run/"logs"/f"{i:03}.stderr").open("w") as err:
                p=pod("exec",name,"/probe/tool_timer",f"/probe/input/{i:03}.sh",f"/probe/work/{i:03}.json","/testbed" if task=="mozilla__pdf.js-20957" else "/app","900",timeout=930,check=False,stdout=out,stderr=err)
            finished=time.monotonic_ns();meta=run/"work"/f"{i:03}.json"
            if p.returncode or not meta.exists():raise RuntimeError(f"tool timer/transport failed at {i}: {p.returncode}")
            v=json.loads(meta.read_text());v.update(step=i,tool=s["tool"],controller_started_ns=dispatch,controller_finished_ns=finished,controller_exec_seconds=(finished-dispatch)/1e9,source_is_error=s["source_is_error"],source_exit_code=s["source_exit_code"],adapter_changes=s["changes"])
            append(run/"steps.jsonl",v);mon.phase="between_tools";b=freeze_scan(name,pid,cg,run,mon,i)
            print(task,"STEP_END",i,"exit",v["exit_code"],"tool_s",round(v["tool_seconds"],3),"cache_mib",round(b["resident_bytes"]/1024**2,2),"scan_s",round(b["scan_seconds"],3),flush=True)
            if v.get("timed_out"):raise RuntimeError("Tool timeout; remaining trajectory not executed")
        info["measurement_finished_ns"]=time.monotonic_ns()
        mon.close();mon.phase="validation"
        validation=verify(task,name,run)
        if task=="reshard-c4-data" and len(allnorm)==36:
            evidence={str(i):(run/"logs"/f"{i:03}.stdout").read_text(errors="replace") for i in [33,34]}
            evidence_ok=("CONSTRAINT VIOLATIONS: NONE" in evidence["33"] and "FINAL VERDICT: BYTE-EXACT ROUNDTRIP ON c4_sample" in evidence["33"] and "9898 files, structure + content" in evidence["34"])
            validation["trajectory_roundtrip_evidence"]=evidence_ok
            if not evidence_ok:validation["status"]="FAIL"
        if task=="mozilla__pdf.js-20957" and len(allnorm)==5:
            actual=[json.loads(x) for x in (run/"steps.jsonl").read_text().splitlines()]
            validation["cli_test_exit_codes"]={str(i):next(x["exit_code"] for x in actual if x["step"]==i) for i in [3,5]}
            if any(validation["cli_test_exit_codes"].values()):validation["status"]="FAIL"
        if task=="build-cython-ext" and len(allnorm)==83:
            text=(run/"logs/082.stdout").read_text(errors="replace")
            validation["pytest_passed_summaries"]=[int(x) for x in re.findall(r"(\d+) passed",text)]
            validation["pytest_failed_summaries"]=[int(x) for x in re.findall(r"(\d+) failed",text)]
            if any(validation["pytest_failed_summaries"]) or len(validation["pytest_passed_summaries"])<2:validation["status"]="FAIL"
        dump(run/"validation.json",validation)
        info["validation"]=validation;status="COMPLETED";info["metric_monitor_errors"]=mon.errors
        dump(run/"memory-events.json",kv(cg/"memory.events"))
    except BaseException as e:
        info["error"]=str(e);(run/"failure.txt").write_text(traceback.format_exc());print(task,"ERROR",str(e),flush=True)
    finally:
        if mon:mon.close()
        pod("unpause",name,check=False);p=pod("rm","-f",name,check=False,timeout=120);cleanup["container_removed"]=p.returncode==0
        info.update(status=status,finished_ns=time.monotonic_ns(),cleanup=cleanup);dump(run/"run.json",info)
    for source in ["steps","samples","boundaries"]:
        p=run/(source+".jsonl")
        if p.exists():
            rows=[json.loads(l) for l in p.read_text().splitlines() if l.strip()]
            flat=[{k:v for k,v in r.items() if isinstance(v,(str,int,float,bool)) or v is None} for r in rows]
            fields=list(dict.fromkeys(k for r in flat for k in r))
            with (run/(source+".csv")).open("w") as f:
                writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader();writer.writerows(flat)
    print("RUN_RESULT",str(run),status,flush=True);return run
if __name__=="__main__":
    ap=argparse.ArgumentParser();ap.add_argument("task",choices=list(IMAGES));ap.add_argument("--steps",type=int);ap.add_argument("--ack-container-metrics",action="store_true",required=True);args=ap.parse_args();run_task(args.task,args.steps)
