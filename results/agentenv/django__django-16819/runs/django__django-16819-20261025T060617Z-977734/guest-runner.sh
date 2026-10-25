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
aswr_boundary 11
printf "running\t12\n" > /probe/work/phase
printf "ASWR_STEP_START 12\n"
printf "12\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "12" || exit 95
printf "after\t12\n" > /probe/work/phase
printf "ASWR_STEP_END 12 "; cat /probe/work/012.json
aswr_boundary 12
printf "running\t13\n" > /probe/work/phase
printf "ASWR_STEP_START 13\n"
printf "13\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "13" || exit 95
printf "after\t13\n" > /probe/work/phase
printf "ASWR_STEP_END 13 "; cat /probe/work/013.json
aswr_boundary 13
printf "running\t14\n" > /probe/work/phase
printf "ASWR_STEP_START 14\n"
printf "14\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "14" || exit 95
printf "after\t14\n" > /probe/work/phase
printf "ASWR_STEP_END 14 "; cat /probe/work/014.json
aswr_boundary 14
printf "running\t15\n" > /probe/work/phase
printf "ASWR_STEP_START 15\n"
printf "15\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "15" || exit 95
printf "after\t15\n" > /probe/work/phase
printf "ASWR_STEP_END 15 "; cat /probe/work/015.json
aswr_boundary 15
printf "running\t16\n" > /probe/work/phase
printf "ASWR_STEP_START 16\n"
printf "16\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "16" || exit 95
printf "after\t16\n" > /probe/work/phase
printf "ASWR_STEP_END 16 "; cat /probe/work/016.json
aswr_boundary 16
printf "running\t17\n" > /probe/work/phase
printf "ASWR_STEP_START 17\n"
printf "17\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "17" || exit 95
printf "after\t17\n" > /probe/work/phase
printf "ASWR_STEP_END 17 "; cat /probe/work/017.json
aswr_boundary 17
printf "running\t18\n" > /probe/work/phase
printf "ASWR_STEP_START 18\n"
printf "18\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "18" || exit 95
printf "after\t18\n" > /probe/work/phase
printf "ASWR_STEP_END 18 "; cat /probe/work/018.json
aswr_boundary 18
printf "running\t19\n" > /probe/work/phase
printf "ASWR_STEP_START 19\n"
printf "19\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "19" || exit 95
printf "after\t19\n" > /probe/work/phase
printf "ASWR_STEP_END 19 "; cat /probe/work/019.json
aswr_boundary 19
printf "running\t20\n" > /probe/work/phase
printf "ASWR_STEP_START 20\n"
printf "20\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "20" || exit 95
printf "after\t20\n" > /probe/work/phase
printf "ASWR_STEP_END 20 "; cat /probe/work/020.json
aswr_boundary 20
printf "running\t21\n" > /probe/work/phase
printf "ASWR_STEP_START 21\n"
printf "21\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "21" || exit 95
printf "after\t21\n" > /probe/work/phase
printf "ASWR_STEP_END 21 "; cat /probe/work/021.json
aswr_boundary 21
printf "running\t22\n" > /probe/work/phase
printf "ASWR_STEP_START 22\n"
printf "22\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "22" || exit 95
printf "after\t22\n" > /probe/work/phase
printf "ASWR_STEP_END 22 "; cat /probe/work/022.json
aswr_boundary 22
printf "running\t23\n" > /probe/work/phase
printf "ASWR_STEP_START 23\n"
printf "23\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "23" || exit 95
printf "after\t23\n" > /probe/work/phase
printf "ASWR_STEP_END 23 "; cat /probe/work/023.json
aswr_boundary 23
printf "running\t24\n" > /probe/work/phase
printf "ASWR_STEP_START 24\n"
printf "24\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "24" || exit 95
printf "after\t24\n" > /probe/work/phase
printf "ASWR_STEP_END 24 "; cat /probe/work/024.json
aswr_boundary 24
printf "running\t25\n" > /probe/work/phase
printf "ASWR_STEP_START 25\n"
printf "25\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "25" || exit 95
printf "after\t25\n" > /probe/work/phase
printf "ASWR_STEP_END 25 "; cat /probe/work/025.json
aswr_boundary 25
printf "running\t26\n" > /probe/work/phase
printf "ASWR_STEP_START 26\n"
printf "26\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "26" || exit 95
printf "after\t26\n" > /probe/work/phase
printf "ASWR_STEP_END 26 "; cat /probe/work/026.json
aswr_boundary 26
printf "running\t27\n" > /probe/work/phase
printf "ASWR_STEP_START 27\n"
printf "27\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "27" || exit 95
printf "after\t27\n" > /probe/work/phase
printf "ASWR_STEP_END 27 "; cat /probe/work/027.json
aswr_boundary 27
printf "running\t28\n" > /probe/work/phase
printf "ASWR_STEP_START 28\n"
printf "28\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "28" || exit 95
printf "after\t28\n" > /probe/work/phase
printf "ASWR_STEP_END 28 "; cat /probe/work/028.json
/probe/workload_probe snapshot > /probe/work/final.json
aswr_boundary 28
printf "QUIT\n" >&198
wait "$ASWR_WORKER_PID" || exit 95
exec 198>&- 199>&-
rm -f /probe/work/commands /probe/work/completed
printf "complete\t28\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
