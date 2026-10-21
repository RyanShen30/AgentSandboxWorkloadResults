#!/usr/bin/env python3
"""Non-faulting page-cache residency scan of owned regular files.
Counts resident (inode, page offset) entries, not unique host PFNs.
"""
from pathlib import Path
import ctypes, errno, json, os, stat, time
PAGE=os.sysconf("SC_PAGE_SIZE")
LIBC=ctypes.CDLL(None,use_errno=True)
LIBC.mmap.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong]
LIBC.mmap.restype=ctypes.c_void_p
LIBC.mincore.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_void_p]
LIBC.munmap.argtypes=[ctypes.c_void_p,ctypes.c_size_t]
FAILED=ctypes.c_void_p(-1).value
def resident(fd,size):
    if not size:return b""
    addr=LIBC.mmap(None,size,0,1,fd,0) # PROT_NONE, MAP_SHARED: do not read file data
    if addr==FAILED:raise OSError(ctypes.get_errno(),os.strerror(ctypes.get_errno()))
    try:
        vec=(ctypes.c_ubyte*((size+PAGE-1)//PAGE))()
        if LIBC.mincore(addr,size,vec):raise OSError(ctypes.get_errno(),os.strerror(ctypes.get_errno()))
        return bytes(x&1 for x in vec)
    finally:LIBC.munmap(addr,size)
def scan(roots,exclude_top=("proc","sys","dev","run","probe")):
    started=time.monotonic_ns();entries={};errors=[];excluded=0;excluded_bytes=0;files=0
    for root0 in roots:
        root=Path(root0);device=root.stat().st_dev
        walk=[(str(root.parent),[],[root.name])] if root.is_file() else os.walk(root,followlinks=False)
        for base,dirs,names in walk:
            good=[]
            for name in dirs:
                p=Path(base)/name
                try:
                    s=p.lstat()
                    if stat.S_ISDIR(s.st_mode) and s.st_dev==device and not (Path(base)==root and name in exclude_top):good.append(name)
                except OSError as e:errors.append({"path":str(p),"error":str(e)})
            dirs[:]=good
            for name in names:
                p=Path(base)/name;fd=None
                try:
                    s=p.lstat()
                    if not stat.S_ISREG(s.st_mode) or s.st_dev!=device:continue
                    files+=1;key=(s.st_dev,s.st_ino)
                    if key in entries:continue
                    # Linux may return all-resident for non-owned unwritable files:
                    # exclude those instead of silently treating them as real measurements.
                    if s.st_uid!=os.geteuid():
                        excluded+=1;excluded_bytes+=s.st_size;continue
                    fd=os.open(p,os.O_RDONLY|os.O_CLOEXEC|os.O_NOFOLLOW)
                    current=os.fstat(fd)
                    if (current.st_dev,current.st_ino,current.st_size)!=(s.st_dev,s.st_ino,s.st_size):raise RuntimeError("file changed during scan")
                    vec=resident(fd,s.st_size)
                    entries[key]={"size":s.st_size,"pages":vec,"path":str(p.relative_to(root)) if not root.is_file() else root.name}
                except (OSError,RuntimeError) as e:errors.append({"path":str(p),"error":str(e)})
                finally:
                    if fd is not None:os.close(fd)
    return {"started_ns":started,"finished_ns":time.monotonic_ns(),"entries":entries,"errors":errors,"paths":files,"excluded_nonowner_files":excluded,"excluded_nonowner_bytes":excluded_bytes}
def two_pass(roots):
    first=scan(roots);second=scan(roots);stable=0;changed=0
    for key,record in second["entries"].items():
        a=first["entries"].get(key);b=record["pages"]
        if not a or a["size"]!=record["size"]:changed+=sum(b);continue
        stable+=sum(x&y for x,y in zip(a["pages"],b))
        changed+=sum(x!=y for x,y in zip(a["pages"],b))
    regions={};largest=[]
    for record in second["entries"].values():
        path=record["path"];resident_bytes=sum(record["pages"])*PAGE
        region=path.split("/",1)[0]
        for prefix,label in [("app/c4_sample/","input_dataset"),("app/input.csv","input_dataset"),("app/expected.csv","input_dataset"),("app/model_cache/","model_cache"),("testbed/node_modules/","dependencies"),("testbed/.git/","git_metadata")]:
            if path.startswith(prefix):region=label;break
        r=regions.setdefault(region,{"resident_bytes":0,"logical_bytes":0,"files":0})
        r["resident_bytes"]+=resident_bytes;r["logical_bytes"]+=record["size"];r["files"]+=1
        largest.append({"path":path,"resident_bytes":resident_bytes,"logical_bytes":record["size"]})
    largest.sort(key=lambda r:r["resident_bytes"],reverse=True)
    return {"regions":regions,"largest_resident_files":largest[:20],"metric":"owned_file_inode_offset_residency","page_size":PAGE,"started_ns":first["started_ns"],"finished_ns":second["finished_ns"],"scan_seconds":(second["finished_ns"]-first["started_ns"])/1e9,"first_resident_bytes":sum(sum(v["pages"]) for v in first["entries"].values())*PAGE,"resident_bytes":sum(sum(v["pages"]) for v in second["entries"].values())*PAGE,"stable_resident_bytes":stable*PAGE,"changed_pages":changed,"regular_paths":second["paths"],"unique_inodes":len(second["entries"]),"logical_file_bytes":sum(v["size"] for v in second["entries"].values()),"excluded_nonowner_files":second["excluded_nonowner_files"],"excluded_nonowner_bytes":second["excluded_nonowner_bytes"],"errors":first["errors"]+second["errors"],"roots":[str(p) for p in roots],"scope":"resident disk-file pages by inode/offset; excludes pseudo mounts, symlinks and non-owned files; not host-PFN deduplication or guest physical memory"}
def calibrate(directory):
    p=Path(directory)/"private-cache-calibration.bin"
    if p.exists():raise RuntimeError("refusing to overwrite calibration input")
    size=8*1024*1024
    with p.open("xb",buffering=0) as f:f.write(os.urandom(size));os.fsync(f.fileno())
    fd=os.open(p,os.O_RDONLY)
    try:
        os.posix_fadvise(fd,0,0,os.POSIX_FADV_DONTNEED)
        cold=two_pass([p]);again=two_pass([p])
        os.pread(fd,size,0);warm=two_pass([p])
        ok=cold["resident_bytes"]==again["resident_bytes"] and warm["resident_bytes"]==size and not any(x["errors"] for x in [cold,again,warm])
        result={"status":"PASS" if ok else "FAIL","bytes":size,"cold":cold,"nonfaulting_repeat":again,"warm":warm,"note":"Only this newly created private file is advised DONTNEED; no global cache eviction."}
        return result
    finally:os.close(fd);p.unlink()
if __name__=="__main__":
    import argparse
    ap=argparse.ArgumentParser();ap.add_argument("roots",nargs="*");ap.add_argument("--calibrate",type=Path);args=ap.parse_args()
    result=calibrate(args.calibrate) if args.calibrate else two_pass(args.roots)
    print(json.dumps(result,ensure_ascii=False,indent=2))
