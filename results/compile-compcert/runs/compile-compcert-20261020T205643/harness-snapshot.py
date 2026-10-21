#!/usr/bin/env python3
"""Second-batch replay. Batch-one runner remains unchanged."""
from pathlib import Path
import argparse, base64, csv, hashlib, json, os, re, shlex, shutil, subprocess, sys, threading, time, traceback
from cache_scan import two_pass
ROOT=Path(__file__).resolve().parent
POD=["podman","--root",str(ROOT/"state/storage"),"--runroot","/tmp/asbp-1012-20261020"]
IMAGES={
"count-dataset-tokens":"docker.io/alexgshaw/count-dataset-tokens@sha256:9c513c4ba342bd95be501f6f5eadd4806a2b18749c87c251615825100130232d",
"compile-compcert":"docker.io/alexgshaw/compile-compcert@sha256:f60236a4fe55bbb3c573210fe0fcd91551f4ee97c417453cd4985be074b35411",
"apache__logging-log4j2":"localhost/asbp-log4j2:204d8251295d",
"matplotlib__matplotlib-24177":"docker.io/swebench/sweb.eval.x86_64.matplotlib_1776_matplotlib-24177@sha256:901249fde9753b8d559a93f6a279ef1371e06426300c1ea1aa64e1723c82099e",
"django__django-16819":"docker.io/swebench/sweb.eval.x86_64.django_1776_django-16819@sha256:6c46d22aaf692840f16209fe29b1d0c940bed043fce8047eb12169215222f044"}
CWD={"apache__logging-log4j2":"/data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415","matplotlib__matplotlib-24177":"/testbed","django__django-16819":"/testbed","compile-compcert":"/app","count-dataset-tokens":"/app"}
SESSION={"apache__logging-log4j2","django__django-16819"}
MAX_TASK_SECONDS=10800
def proxy_args():
    result=["--http-proxy=false"]
    for key,value in os.environ.items():
        if key.lower() == "all_proxy": continue
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
                try:v=sample(self.cg);v.update(phase=self.phase,step=self.step,disk_free_bytes=shutil.disk_usage(ROOT).free);f.write(json.dumps(v)+"\n")
                except Exception as e:self.errors.append(str(e))
                if shutil.disk_usage(ROOT).free < 20*1024**3 and not getattr(self,"disk_low",False):
                    self.disk_low=True;self.errors.append("Free disk below 20 GiB; stopping this experiment container")
                    pod("kill",self.container,check=False)
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
        if task=="count-dataset-tokens":
            if "pip install datasets transformers tokenizers" in cmd:
                (payloads/"source-constraints.txt").write_text((ROOT/"sources/count-dataset-tokens/source-constraints.txt").read_text())
                cmd=cmd.replace("pip install datasets transformers tokenizers", "pip install -c /probe/input/source-constraints.txt datasets transformers tokenizers")
                changes.append("Constrain dependency versions to the exact Successfully installed list in public tool3; newer datasets dropped the requests dependency used by subsequent source calls.")
            cmd=cmd.replace("hf_hub_download('ryanmarten/OpenThoughts-1k-sample', 'README.md', repo_type='dataset')", "hf_hub_download('ryanmarten/OpenThoughts-1k-sample', 'README.md', repo_type='dataset', revision='a82400884621626d41bef89b7604f8054e7e00e0')")
            changes.append("Do not forward ALL_PROXY: HF's HTTP client eagerly constructs an unused SOCKS transport without socksio. Use the same host HTTP/HTTPS proxy. Pin README download to the snapshot path recorded by the read tool.")
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
    if task=="compile-compcert" and tool=="bash" and re.search(r"\bwget\s",cmd):
        retry="""wget() {
  local ASBP_FETCH_RC ASBP_FETCH_N
  for ASBP_FETCH_N in 1 2 3 4; do
    if command wget --timeout=30 --tries=1 "$@"; then return 0; else ASBP_FETCH_RC=$?; fi
    case "$ASBP_FETCH_RC" in
      4|5) if [ "$ASBP_FETCH_N" -lt 4 ]; then printf 'ASBP: retry wget transport failure (%s)\\n' "$ASBP_FETCH_RC" >&2; sleep 1; fi ;;
      *) return "$ASBP_FETCH_RC" ;;
    esac
  done
  return "$ASBP_FETCH_RC"
}
"""
        cmd=retry+cmd
        changes.append("Bound wget network/TLS failures (exit4/5) to four attempts with30s timeout; preserve original URLs, flags, HTTP errors and successful outputs. Retries remain inside measured tool runtime. Added after a transient TLS EOF produced an empty Coq archive.")
    if task=="compile-compcert" and tool=="read":
        supplied=args["path"]
        actual=step.get("source_result",{}).get("result",{}).get("details",{}).get("meta",{}).get("source",{}).get("value") or re.sub(r":(?:raw|[0-9][0-9,\-]*)$","",supplied)
        match=re.search(r":([0-9][0-9,\-]*)$",supplied)
        cmd="/probe/file_reader "+shlex.quote(actual)+( " "+shlex.quote(match[1]) if match else "")
        changes.append("Use a static C read bridge for the minimal CompCert image, without adding Python dependencies. Read the whole file and emit requested line spans; native semantic formatting/timing remains unavailable.")
    if task=="django__django-16819":
        # Public terminal observations contain one backslash where ATIF keystrokes contain two.
        cmd=cmd.replace("\\\\", "\\")
        changes.append("Decode doubled terminal backslashes once; published echoed commands show one backslash (notably find terminators and sed newline replacements). Preserve command content after this terminal encoding layer.")
    if task=="matplotlib__matplotlib-24177":
        cmd="exec bash -lc "+shlex.quote(cmd)
        changes.append("Match mini-swe-agent DockerEnvironment's login Bash invocation, activating the image's Conda testbed environment.")
    return cmd,changes
def freeze_scan(name,pid,cg,run,mon,step):
    mon.phase="pause_scan";mon.step=step;before=sample(cg);start=time.monotonic_ns()
    pod("pause",name);requested=time.monotonic_ns()
    try:
        # cgroup.freeze is asynchronous; cgroup.events is the completion acknowledgement.
        polls=0
        while True:
            events=kv(cg/"cgroup.events");polls+=1
            if events.get("frozen")==1:break
            if time.monotonic_ns()-requested>30*10**9:
                dump(run/f"freeze-timeout-{step:03}.json",{"step":step,"events":events,"freeze":(cg/"cgroup.freeze").read_text(),"pids":(cg/"cgroup.procs").read_text(),"polls":polls})
                raise RuntimeError("cgroup did not report frozen=1 within30s; refusing an unfrozen scan")
            time.sleep(.01)
        paused=time.monotonic_ns()
        result=two_pass([f"/proc/{pid}/root"])
        result.update(step=step,pause_started_ns=start,pause_requested_ns=requested,pause_confirmed_ns=paused,freeze_wait_seconds=(paused-requested)/1e9,freeze_poll_count=polls,cgroup_before=before,cgroup_while_paused=sample(cg),frozen_verified=True)
    finally:pod("unpause",name)
    result["resumed_ns"]=time.monotonic_ns();result["pause_seconds"]=(result["resumed_ns"]-start)/1e9
    append(run/"boundaries.jsonl",result);mon.phase="between_tools";return result
def verify(task,name,run):
    code={
"count-dataset-tokens":"test \"$(cat /app/answer.txt)\" = 79586 && grep -Ex '[0-9]+' /app/answer.txt && python3 -m py_compile /app/count_tokens.py",
"compile-compcert":"""set -e
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
cd /tmp/CompCert
./ccomp -version
printf 'int main(void) { return 6*7 == 42 ? 0 : 1; }\\n' > /tmp/asbp_smoke.c
./ccomp /tmp/asbp_smoke.c -o /tmp/asbp_smoke
/tmp/asbp_smoke
""",
"apache__logging-log4j2":"""cd /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 && test -d log4j-api/target/classes && test -d log4j-core/target/classes && find . -path '*/target/classes/*.class' -print -quit""",
"matplotlib__matplotlib-24177":"cd /testbed && git diff --stat && python -c 'import matplotlib, numpy; print(matplotlib.__version__, numpy.__version__)'",
"django__django-16819":"cd /testbed && git rev-parse HEAD && git diff --stat && python -m py_compile django/db/migrations/operations/models.py"
    }[task]
    with (run/"validation.stdout").open("w") as out,(run/"validation.stderr").open("w") as err:
        p=pod("exec",name,"bash",*(["-l"] if task in ["matplotlib__matplotlib-24177","django__django-16819"] else []),"-o","pipefail","-c",code,timeout=180,check=False,stdout=out,stderr=err)
    return {"exit_code":p.returncode,"status":"PASS" if p.returncode==0 else "FAIL","scope":"local artifact/smoke check only; recorded trajectory completion is independent of official benchmark correctness","command":code}
def session_start(task,name,run):
    server=run/"input/session-server.sh"
    server.write_text("""#!/bin/bash
cd """+shlex.quote(CWD[task])+"""
mkfifo /probe/work/request
exec 3<>/probe/work/request
touch /probe/work/session-ready
while IFS= read -r ASBP_STEP <&3; do
  ASBP_START=$(/probe/clock_ns)
  source "/probe/input/${ASBP_STEP}.sh" > "/probe/work/${ASBP_STEP}.stdout" 2> "/probe/work/${ASBP_STEP}.stderr"
  ASBP_RC=$?
  ASBP_END=$(/probe/clock_ns)
  printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\\n' "$ASBP_START" "$ASBP_END" "$ASBP_RC" > "/probe/work/${ASBP_STEP}.tmp"
  mv "/probe/work/${ASBP_STEP}.tmp" "/probe/work/${ASBP_STEP}.json"
done
""")
    pod("exec","-d",name,"bash",*(["-l"] if task=="django__django-16819" else []),"/probe/input/session-server.sh")
    until=time.monotonic()+30
    while not (run/"work/session-ready").exists():
        if time.monotonic()>until:raise RuntimeError("persistent shell failed to start")
        time.sleep(.05)
def execute(task,name,run,s):
    i=s["step"];timeout=max(900,int(s.get("args",{}).get("timeout",900)))
    if task in SESSION:
        with (run/"work/request").open("w") as f:f.write(f"{i:03}\n")
        meta=run/"work"/f"{i:03}.json";deadline=time.monotonic()+timeout
        while not meta.exists():
            if time.monotonic()>deadline:raise RuntimeError("Persistent-shell command timed out at "+str(i))
            if shutil.disk_usage(ROOT).free<20*1024**3:raise RuntimeError("free disk below 20 GiB")
            time.sleep(.02)
        v=json.loads(meta.read_text());v["tool_seconds"]=(v["finished_ns"]-v["started_ns"])/1e9
        dump(meta,v)
        for typ in ["stdout","stderr"]:shutil.copyfile(run/"work"/f"{i:03}.{typ}",run/"logs"/f"{i:03}.{typ}")
        return
    with (run/"logs"/f"{i:03}.stdout").open("w") as out,(run/"logs"/f"{i:03}.stderr").open("w") as err:
        p=pod("exec",name,"/probe/tool_timer",f"/probe/input/{i:03}.sh",f"/probe/work/{i:03}.json",CWD[task],str(timeout),timeout=timeout+30,check=False,stdout=out,stderr=err)
    if p.returncode:raise RuntimeError("tool timer/transport failed: "+str(p.returncode))
def run_task(task,step_limit=None):
    stamp=time.strftime("%Y%m%dT%H%M%S");run=ROOT/"results"/f"{task}-{stamp}";run.mkdir(parents=True)
    for p in ["input","work","logs"]: (run/p).mkdir()
    steps=json.loads((ROOT/"sources"/task/"tool-steps.json").read_text())
    if step_limit:steps=steps[:step_limit]
    allnorm=[]
    for s in steps:
        cmd,changes=normalize(task,s,run/"input")
        if task in SESSION:changes.append("Execute in one persistent Bash shell; clock_gettime helper brackets each sourced command. Original PTY rendering and terminal wait duration are not replayed.")
        if s.get("args",{}).get("async"):
            bg=run/"input"/f"{s['step']:03}-async.sh"
            marker=f"/probe/work/async-{s['step']}.done"
            bg.write_text("trap 'ASBP_BG_RC=$?; printf \"%s\\n\" \"$ASBP_BG_RC\" > "+marker+"' EXIT\n"+cmd+"\n")
            cmd="nohup bash "+shlex.quote("/probe/input/"+bg.name)+" > /probe/work/async-"+str(s["step"])+".stdout 2> /probe/work/async-"+str(s["step"])+".stderr < /dev/null & echo ASBP_ASYNC_PID=$!"
            changes.append("Preserve async=true as background dispatch; later recorded polls remain real commands. Timing measures launch, not whole background-job lifetime.")
        script=run/"input"/f"{s['step']:03}.sh";script.write_text(cmd+"\n")
        allnorm.append({**s,"command":cmd,"changes":changes,"script_sha256":hashlib.sha256(script.read_bytes()).hexdigest(),**expected(s)})
    dump(run/"normalized-steps.json",allnorm)
    (run/"harness-snapshot.py").write_text(Path(__file__).read_text())
    name="asbp-"+task.replace("_","-").replace(".","-")[:35]+"-"+stamp.lower()
    info={"task_id":task,"started_ns":time.monotonic_ns(),"backend":"rootless-podman","image":IMAGES[task],"container":name,"cpus":2,"memory_limit_bytes":32*1024**3,"sample_interval_seconds":.2,"initial_cache_policy":"Warmness uncontrolled after image preparation; initial residency is measured. No global cache drop.","memory_label":"Container cgroup memory (includes charged cache; not guest physical memory)","scope":"one replay of fixed public tool actions; read/write, pinned dependencies, persistent-session and async adapters are declared in normalized-steps.json; no original model thinking gaps", "rootless_ownership_compatibility":task=="matplotlib__matplotlib-24177", "persistent_shell":task in SESSION, "latency_method":"persistent Bash with CLOCK_MONOTONIC helper around sourced command" if task in SESSION else "static C fork/wait timer around Bash"}
    dump(run/"run.json",info);mon=None;status="FAIL";cleanup={}
    try:
        create=pod("run","-d","--name",name,"--cpus","2","--memory","32g","--memory-swap","32g","--pids-limit","1024","--shm-size","256m","--network","slirp4netns:allow_host_loopback=true",*proxy_args(),"--env","OMP_NUM_THREADS=2","--env","OPENBLAS_NUM_THREADS=2","--env","MKL_NUM_THREADS=2","--env","TOKENIZERS_PARALLELISM=false","--env","PAGER=cat","--env","MANPAGER=cat","--env","LESS=-R","--env","PIP_PROGRESS_BAR=off","--env","TQDM_DISABLE=1","--volume",str(ROOT/"file_reader")+":/probe/file_reader:ro","--volume",str(ROOT/"clock_ns")+":/probe/clock_ns:ro","--volume",str(ROOT/"tool_timer")+":/probe/tool_timer:ro","--volume",str(run/"input")+":/probe/input:ro","--volume",str(run/"work")+":/probe/work:rw","--entrypoint","sleep",IMAGES[task],"infinity",timeout=120)
        state=json.loads(pod("inspect",name).stdout)[0];pid=state["State"]["Pid"]
        path=Path("/proc")/str(pid)/"cgroup";rel=path.read_text().strip().split("0::",1)[1];cg=Path("/sys/fs/cgroup")/rel.lstrip("/")
        for f in ["memory.current","memory.stat","cgroup.events"]:
            if not (cg/f).exists():raise RuntimeError("Missing delegated cgroup metric "+f)
        preflight=pod("exec",name,"bash","-c","pwd; echo PATH=$PATH; command -v python python3 java mvn || true; git -C "+shlex.quote(CWD[task])+" rev-parse HEAD 2>/dev/null || true",check=False)
        (run/"preflight.stdout").write_text(preflight.stdout)
        if task in ["matplotlib__matplotlib-24177","django__django-16819"]:
            check=pod("exec",name,"bash","-lc","cd /testbed && command -v python && git rev-parse HEAD && git hash-object "+("lib/matplotlib/axes/_axes.py" if task.startswith("matplotlib") else "django/db/migrations/operations/models.py"))
            (run/"login-preflight.stdout").write_text(check.stdout)
            if "/envs/testbed/bin/python" not in check.stdout:raise RuntimeError("Conda testbed environment is not active in login Bash")
            if task.startswith("django"):
                if "967a91fdc89c3d1d3ec38ab155e461fe5b23b3c5" not in check.stdout:raise RuntimeError("Django core source blob differs from public base commit")
                ancestry=pod("exec",name,"bash","-lc","cd /testbed && git merge-base --is-ancestor 0b0998dc151feb77068e2387c34cc50ef6b356ae HEAD && git diff --exit-code 0b0998dc151feb77068e2387c34cc50ef6b356ae HEAD -- django && git log -2 --oneline",check=False)
                (run/"source-ancestry.stdout").write_text(ancestry.stdout)
                if ancestry.returncode:raise RuntimeError("Django source tree differs from the public base commit despite matching one core file")
            if task.startswith("matplotlib") and "2412f815cd" not in check.stdout:raise RuntimeError("Matplotlib axes baseline blob differs from public submission diff")
        info.update(pid=pid,cgroup=str(cg),container_id=create.stdout.strip(),image_id=state["Image"]);dump(run/"run.json",info)
        if task in SESSION:session_start(task,name,run)
        barriers=json.loads((ROOT/"sources/compile-compcert/async-completion-barriers.json").read_text())["wait_before_step"] if task=="compile-compcert" else {}
        mon=Monitor(cg,run/"samples.jsonl");mon.container=name;mon.start();freeze_scan(name,pid,cg,run,mon,0)
        started=time.monotonic()
        for s in allnorm:
            if shutil.disk_usage(ROOT).free<20*1024**3:raise RuntimeError("free disk below 20 GiB")
            if time.monotonic()-started>MAX_TASK_SECONDS:raise RuntimeError("Task replay exceeded configured time limit")
            i=s["step"]
            if task=="compile-compcert" and i==59:
                archive=Path(f"/proc/{pid}/root/tmp/coq-8.16.1.tar.gz")
                if not archive.exists() or archive.stat().st_size!=7402490:
                    raise RuntimeError("Required Coq archive missing/truncated before tool59; stop before downstream builds")
            for bg_step in barriers.get(str(i),[]):
                mon.phase="async_dependency_wait";wait_started=time.monotonic_ns()
                print(task,"ASYNC_BARRIER",bg_step,"before",i,flush=True)
                while not (run/"work"/f"async-{bg_step}.done").exists():
                    if (time.monotonic_ns()-wait_started)>3600*10**9:raise RuntimeError("Async dependency wait exceeded3600s")
                    if shutil.disk_usage(ROOT).free<20*1024**3:raise RuntimeError("free disk below20GiB")
                    time.sleep(.1)
                append(run/"async-barriers.jsonl",{"source_async_step":bg_step,"before_tool_step":i,"started_ns":wait_started,"finished_ns":time.monotonic_ns(),"job_exit_code":int((run/"work"/f"async-{bg_step}.done").read_text()),"scope":"minimum completion-order synchronization from public async-result notice; outside tool latency"})
            mon.phase="tool";mon.step=i;dispatch=time.monotonic_ns()
            print(task,"STEP_START",i,s["tool"],flush=True)
            execute(task,name,run,s)
            finished=time.monotonic_ns();meta=run/"work"/f"{i:03}.json"
            if not meta.exists():raise RuntimeError("missing tool timing metadata")
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
        size=pod("inspect","--size",name,timeout=120,check=False)
        if size.returncode==0:
            sized=json.loads(size.stdout)[0];dump(run/"container-disk.json",{k:sized.get(k) for k in ["SizeRw","SizeRootFs","Image","GraphDriver"]})
        inventory=pod("exec",name,"bash",*(["-l"] if task in ["matplotlib__matplotlib-24177","django__django-16819"] else []),"-c","python3 -m pip freeze 2>/dev/null || true; java -version 2>&1 || true; mvn -version 2>/dev/null || true",check=False,timeout=60)
        (run/"dependency-inventory.txt").write_text(inventory.stdout)
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
