#!/bin/bash
set +e
umask 077
ASWR_CGROUP=/sys/fs/cgroup/aswr-business
/probe/workload_probe cgroup-init "$ASWR_CGROUP" > /probe/work/quiescence-setup.json || exit 94
mkfifo /probe/work/commands /probe/work/completed || exit 94
exec 198<>/probe/work/commands 199<>/probe/work/completed
/probe/workload_probe enter "$ASWR_CGROUP" /bin/bash /probe/guest-worker.sh > /probe/work/worker.stdout 2> /probe/work/worker.stderr &
ASWR_WORKER_PID=$!
trap '/probe/workload_probe thaw "$ASWR_CGROUP" > /probe/work/exit-thaw.json 2>/dev/null; touch /probe/work/monitor-stop; kill "$ASWR_WORKER_PID" 2>/dev/null || true' EXIT
for ASWR_I in {1..100}; do test -f /probe/work/worker-ready && break; sleep .02; done
test -f /probe/work/worker-ready || exit 94
aswr_boundary() {
ASWR_LABEL=$(printf "%03d" "$1")
printf "cache_scan\t%s\n" "$1" > /probe/work/phase
/probe/workload_probe freeze "$ASWR_CGROUP" > /probe/work/freeze-$ASWR_LABEL.json || exit 94
/probe/workload_probe snapshot > /probe/work/scan-start-$ASWR_LABEL.json || exit 94
/probe/workload_probe scan --frozen-cgroup "$ASWR_CGROUP" / > /probe/work/boundary-$ASWR_LABEL.json || exit 94
/probe/workload_probe snapshot > /probe/work/scan-end-$ASWR_LABEL.json || exit 94
/probe/workload_probe thaw "$ASWR_CGROUP" > /probe/work/thaw-$ASWR_LABEL.json || exit 94
}
printf "baseline\t0\n" > /probe/work/phase
/probe/workload_probe monitor /probe/work &
ASWR_MONITOR_PID=$!
for ASWR_I in {1..100}; do test -f /probe/work/monitor-ready && break; sleep .02; done
test -f /probe/work/monitor-ready || exit 90
/probe/workload_probe snapshot > /probe/work/baseline.json
aswr_boundary 0
printf "ASWR_READY\n"
printf "running\t1\n" > /probe/work/phase
printf "ASWR_STEP_START 1\n"
printf "1\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "1" || exit 95
printf "after\t1\n" > /probe/work/phase
printf "ASWR_STEP_END 1 "; cat /probe/work/001.json
aswr_boundary 1
printf "running\t2\n" > /probe/work/phase
printf "ASWR_STEP_START 2\n"
printf "2\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "2" || exit 95
printf "after\t2\n" > /probe/work/phase
printf "ASWR_STEP_END 2 "; cat /probe/work/002.json
aswr_boundary 2
printf "running\t3\n" > /probe/work/phase
printf "ASWR_STEP_START 3\n"
printf "3\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "3" || exit 95
printf "after\t3\n" > /probe/work/phase
printf "ASWR_STEP_END 3 "; cat /probe/work/003.json
aswr_boundary 3
printf "running\t4\n" > /probe/work/phase
printf "ASWR_STEP_START 4\n"
printf "4\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "4" || exit 95
printf "after\t4\n" > /probe/work/phase
printf "ASWR_STEP_END 4 "; cat /probe/work/004.json
aswr_boundary 4
printf "running\t5\n" > /probe/work/phase
printf "ASWR_STEP_START 5\n"
printf "5\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "5" || exit 95
printf "after\t5\n" > /probe/work/phase
printf "ASWR_STEP_END 5 "; cat /probe/work/005.json
aswr_boundary 5
printf "running\t6\n" > /probe/work/phase
printf "ASWR_STEP_START 6\n"
printf "6\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "6" || exit 95
printf "after\t6\n" > /probe/work/phase
printf "ASWR_STEP_END 6 "; cat /probe/work/006.json
aswr_boundary 6
printf "running\t7\n" > /probe/work/phase
printf "ASWR_STEP_START 7\n"
printf "7\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "7" || exit 95
printf "after\t7\n" > /probe/work/phase
printf "ASWR_STEP_END 7 "; cat /probe/work/007.json
aswr_boundary 7
printf "running\t8\n" > /probe/work/phase
printf "ASWR_STEP_START 8\n"
printf "8\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "8" || exit 95
printf "after\t8\n" > /probe/work/phase
printf "ASWR_STEP_END 8 "; cat /probe/work/008.json
aswr_boundary 8
printf "running\t9\n" > /probe/work/phase
printf "ASWR_STEP_START 9\n"
printf "9\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "9" || exit 95
printf "after\t9\n" > /probe/work/phase
printf "ASWR_STEP_END 9 "; cat /probe/work/009.json
aswr_boundary 9
printf "running\t10\n" > /probe/work/phase
printf "ASWR_STEP_START 10\n"
printf "10\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "10" || exit 95
printf "after\t10\n" > /probe/work/phase
printf "ASWR_STEP_END 10 "; cat /probe/work/010.json
aswr_boundary 10
printf "running\t11\n" > /probe/work/phase
printf "ASWR_STEP_START 11\n"
printf "11\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "11" || exit 95
printf "after\t11\n" > /probe/work/phase
printf "ASWR_STEP_END 11 "; cat /probe/work/011.json
/probe/workload_probe snapshot > /probe/work/final.json
aswr_boundary 11
printf "QUIT\n" >&198
wait "$ASWR_WORKER_PID" || exit 95
exec 198>&- 199>&-
rm -f /probe/work/commands /probe/work/completed
printf "complete\t11\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
