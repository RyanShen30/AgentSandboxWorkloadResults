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
aswr_boundary 28
printf "running\t29\n" > /probe/work/phase
printf "ASWR_STEP_START 29\n"
printf "29\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "29" || exit 95
printf "after\t29\n" > /probe/work/phase
printf "ASWR_STEP_END 29 "; cat /probe/work/029.json
aswr_boundary 29
printf "running\t30\n" > /probe/work/phase
printf "ASWR_STEP_START 30\n"
printf "30\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "30" || exit 95
printf "after\t30\n" > /probe/work/phase
printf "ASWR_STEP_END 30 "; cat /probe/work/030.json
aswr_boundary 30
printf "running\t31\n" > /probe/work/phase
printf "ASWR_STEP_START 31\n"
printf "31\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "31" || exit 95
printf "after\t31\n" > /probe/work/phase
printf "ASWR_STEP_END 31 "; cat /probe/work/031.json
aswr_boundary 31
printf "running\t32\n" > /probe/work/phase
printf "ASWR_STEP_START 32\n"
printf "32\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "32" || exit 95
printf "after\t32\n" > /probe/work/phase
printf "ASWR_STEP_END 32 "; cat /probe/work/032.json
aswr_boundary 32
printf "running\t33\n" > /probe/work/phase
printf "ASWR_STEP_START 33\n"
printf "33\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "33" || exit 95
printf "after\t33\n" > /probe/work/phase
printf "ASWR_STEP_END 33 "; cat /probe/work/033.json
aswr_boundary 33
printf "running\t34\n" > /probe/work/phase
printf "ASWR_STEP_START 34\n"
printf "34\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "34" || exit 95
printf "after\t34\n" > /probe/work/phase
printf "ASWR_STEP_END 34 "; cat /probe/work/034.json
aswr_boundary 34
printf "running\t35\n" > /probe/work/phase
printf "ASWR_STEP_START 35\n"
printf "35\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "35" || exit 95
printf "after\t35\n" > /probe/work/phase
printf "ASWR_STEP_END 35 "; cat /probe/work/035.json
aswr_boundary 35
printf "running\t36\n" > /probe/work/phase
printf "ASWR_STEP_START 36\n"
printf "36\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "36" || exit 95
printf "after\t36\n" > /probe/work/phase
printf "ASWR_STEP_END 36 "; cat /probe/work/036.json
aswr_boundary 36
printf "running\t37\n" > /probe/work/phase
printf "ASWR_STEP_START 37\n"
printf "37\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "37" || exit 95
printf "after\t37\n" > /probe/work/phase
printf "ASWR_STEP_END 37 "; cat /probe/work/037.json
aswr_boundary 37
printf "running\t38\n" > /probe/work/phase
printf "ASWR_STEP_START 38\n"
printf "38\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "38" || exit 95
printf "after\t38\n" > /probe/work/phase
printf "ASWR_STEP_END 38 "; cat /probe/work/038.json
aswr_boundary 38
printf "running\t39\n" > /probe/work/phase
printf "ASWR_STEP_START 39\n"
printf "39\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "39" || exit 95
printf "after\t39\n" > /probe/work/phase
printf "ASWR_STEP_END 39 "; cat /probe/work/039.json
aswr_boundary 39
printf "running\t40\n" > /probe/work/phase
printf "ASWR_STEP_START 40\n"
printf "40\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "40" || exit 95
printf "after\t40\n" > /probe/work/phase
printf "ASWR_STEP_END 40 "; cat /probe/work/040.json
aswr_boundary 40
printf "running\t41\n" > /probe/work/phase
printf "ASWR_STEP_START 41\n"
printf "41\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "41" || exit 95
printf "after\t41\n" > /probe/work/phase
printf "ASWR_STEP_END 41 "; cat /probe/work/041.json
aswr_boundary 41
printf "running\t42\n" > /probe/work/phase
printf "ASWR_STEP_START 42\n"
printf "42\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "42" || exit 95
printf "after\t42\n" > /probe/work/phase
printf "ASWR_STEP_END 42 "; cat /probe/work/042.json
aswr_boundary 42
printf "running\t43\n" > /probe/work/phase
printf "ASWR_STEP_START 43\n"
printf "43\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "43" || exit 95
printf "after\t43\n" > /probe/work/phase
printf "ASWR_STEP_END 43 "; cat /probe/work/043.json
aswr_boundary 43
printf "running\t44\n" > /probe/work/phase
printf "ASWR_STEP_START 44\n"
printf "44\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "44" || exit 95
printf "after\t44\n" > /probe/work/phase
printf "ASWR_STEP_END 44 "; cat /probe/work/044.json
aswr_boundary 44
printf "running\t45\n" > /probe/work/phase
printf "ASWR_STEP_START 45\n"
printf "45\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "45" || exit 95
printf "after\t45\n" > /probe/work/phase
printf "ASWR_STEP_END 45 "; cat /probe/work/045.json
aswr_boundary 45
printf "running\t46\n" > /probe/work/phase
printf "ASWR_STEP_START 46\n"
printf "46\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "46" || exit 95
printf "after\t46\n" > /probe/work/phase
printf "ASWR_STEP_END 46 "; cat /probe/work/046.json
aswr_boundary 46
printf "running\t47\n" > /probe/work/phase
printf "ASWR_STEP_START 47\n"
printf "47\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "47" || exit 95
printf "after\t47\n" > /probe/work/phase
printf "ASWR_STEP_END 47 "; cat /probe/work/047.json
aswr_boundary 47
printf "running\t48\n" > /probe/work/phase
printf "ASWR_STEP_START 48\n"
printf "48\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "48" || exit 95
printf "after\t48\n" > /probe/work/phase
printf "ASWR_STEP_END 48 "; cat /probe/work/048.json
aswr_boundary 48
printf "running\t49\n" > /probe/work/phase
printf "ASWR_STEP_START 49\n"
printf "49\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "49" || exit 95
printf "after\t49\n" > /probe/work/phase
printf "ASWR_STEP_END 49 "; cat /probe/work/049.json
aswr_boundary 49
printf "running\t50\n" > /probe/work/phase
printf "ASWR_STEP_START 50\n"
printf "50\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "50" || exit 95
printf "after\t50\n" > /probe/work/phase
printf "ASWR_STEP_END 50 "; cat /probe/work/050.json
/probe/workload_probe snapshot > /probe/work/final.json
aswr_boundary 50
printf "QUIT\n" >&198
wait "$ASWR_WORKER_PID" || exit 95
exec 198>&- 199>&-
rm -f /probe/work/commands /probe/work/completed
printf "complete\t50\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
