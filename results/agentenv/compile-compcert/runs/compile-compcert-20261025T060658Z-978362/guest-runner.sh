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
IFS= read -r -t 1830 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "44" || exit 95
printf "after\t44\n" > /probe/work/phase
printf "ASWR_STEP_END 44 "; cat /probe/work/044.json
aswr_boundary 44
printf "running\t45\n" > /probe/work/phase
printf "ASWR_STEP_START 45\n"
printf "45\n" >&198
IFS= read -r -t 1830 ASWR_ACK <&199 || exit 95
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
aswr_boundary 50
printf "running\t51\n" > /probe/work/phase
printf "ASWR_STEP_START 51\n"
printf "51\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "51" || exit 95
printf "after\t51\n" > /probe/work/phase
printf "ASWR_STEP_END 51 "; cat /probe/work/051.json
aswr_boundary 51
printf "running\t52\n" > /probe/work/phase
printf "ASWR_STEP_START 52\n"
printf "52\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "52" || exit 95
printf "after\t52\n" > /probe/work/phase
printf "ASWR_STEP_END 52 "; cat /probe/work/052.json
aswr_boundary 52
printf "running\t53\n" > /probe/work/phase
printf "ASWR_STEP_START 53\n"
printf "53\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "53" || exit 95
printf "after\t53\n" > /probe/work/phase
printf "ASWR_STEP_END 53 "; cat /probe/work/053.json
aswr_boundary 53
printf "running\t54\n" > /probe/work/phase
printf "ASWR_STEP_START 54\n"
printf "54\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "54" || exit 95
printf "after\t54\n" > /probe/work/phase
printf "ASWR_STEP_END 54 "; cat /probe/work/054.json
aswr_boundary 54
printf "running\t55\n" > /probe/work/phase
printf "ASWR_STEP_START 55\n"
printf "55\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "55" || exit 95
printf "after\t55\n" > /probe/work/phase
printf "ASWR_STEP_END 55 "; cat /probe/work/055.json
aswr_boundary 55
printf "running\t56\n" > /probe/work/phase
printf "ASWR_STEP_START 56\n"
printf "56\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "56" || exit 95
printf "after\t56\n" > /probe/work/phase
printf "ASWR_STEP_END 56 "; cat /probe/work/056.json
aswr_boundary 56
printf "running\t57\n" > /probe/work/phase
printf "ASWR_STEP_START 57\n"
printf "57\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "57" || exit 95
printf "after\t57\n" > /probe/work/phase
printf "ASWR_STEP_END 57 "; cat /probe/work/057.json
aswr_boundary 57
printf "running\t58\n" > /probe/work/phase
printf "ASWR_STEP_START 58\n"
printf "58\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "58" || exit 95
printf "after\t58\n" > /probe/work/phase
printf "ASWR_STEP_END 58 "; cat /probe/work/058.json
aswr_boundary 58
printf "running\t59\n" > /probe/work/phase
printf "ASWR_STEP_START 59\n"
printf "59\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "59" || exit 95
printf "after\t59\n" > /probe/work/phase
printf "ASWR_STEP_END 59 "; cat /probe/work/059.json
aswr_boundary 59
printf "running\t60\n" > /probe/work/phase
printf "ASWR_STEP_START 60\n"
printf "60\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "60" || exit 95
printf "after\t60\n" > /probe/work/phase
printf "ASWR_STEP_END 60 "; cat /probe/work/060.json
aswr_boundary 60
printf "running\t61\n" > /probe/work/phase
printf "ASWR_STEP_START 61\n"
printf "61\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "61" || exit 95
printf "after\t61\n" > /probe/work/phase
printf "ASWR_STEP_END 61 "; cat /probe/work/061.json
aswr_boundary 61
printf "running\t62\n" > /probe/work/phase
printf "ASWR_STEP_START 62\n"
printf "62\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "62" || exit 95
printf "after\t62\n" > /probe/work/phase
printf "ASWR_STEP_END 62 "; cat /probe/work/062.json
aswr_boundary 62
printf "running\t63\n" > /probe/work/phase
printf "ASWR_STEP_START 63\n"
printf "63\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "63" || exit 95
printf "after\t63\n" > /probe/work/phase
printf "ASWR_STEP_END 63 "; cat /probe/work/063.json
aswr_boundary 63
printf "running\t64\n" > /probe/work/phase
printf "ASWR_STEP_START 64\n"
printf "64\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "64" || exit 95
printf "after\t64\n" > /probe/work/phase
printf "ASWR_STEP_END 64 "; cat /probe/work/064.json
aswr_boundary 64
printf "running\t65\n" > /probe/work/phase
printf "ASWR_STEP_START 65\n"
printf "65\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "65" || exit 95
printf "after\t65\n" > /probe/work/phase
printf "ASWR_STEP_END 65 "; cat /probe/work/065.json
aswr_boundary 65
printf "running\t66\n" > /probe/work/phase
printf "ASWR_STEP_START 66\n"
printf "66\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "66" || exit 95
printf "after\t66\n" > /probe/work/phase
printf "ASWR_STEP_END 66 "; cat /probe/work/066.json
aswr_boundary 66
printf "running\t67\n" > /probe/work/phase
printf "ASWR_STEP_START 67\n"
printf "67\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "67" || exit 95
printf "after\t67\n" > /probe/work/phase
printf "ASWR_STEP_END 67 "; cat /probe/work/067.json
aswr_boundary 67
printf "running\t68\n" > /probe/work/phase
printf "ASWR_STEP_START 68\n"
printf "68\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "68" || exit 95
printf "after\t68\n" > /probe/work/phase
printf "ASWR_STEP_END 68 "; cat /probe/work/068.json
aswr_boundary 68
printf "running\t69\n" > /probe/work/phase
printf "ASWR_STEP_START 69\n"
printf "69\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "69" || exit 95
printf "after\t69\n" > /probe/work/phase
printf "ASWR_STEP_END 69 "; cat /probe/work/069.json
aswr_boundary 69
printf "running\t70\n" > /probe/work/phase
printf "ASWR_STEP_START 70\n"
printf "70\n" >&198
IFS= read -r -t 1230 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "70" || exit 95
printf "after\t70\n" > /probe/work/phase
printf "ASWR_STEP_END 70 "; cat /probe/work/070.json
aswr_boundary 70
printf "running\t71\n" > /probe/work/phase
printf "ASWR_STEP_START 71\n"
printf "71\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "71" || exit 95
printf "after\t71\n" > /probe/work/phase
printf "ASWR_STEP_END 71 "; cat /probe/work/071.json
aswr_boundary 71
printf "running\t72\n" > /probe/work/phase
printf "ASWR_STEP_START 72\n"
printf "72\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "72" || exit 95
printf "after\t72\n" > /probe/work/phase
printf "ASWR_STEP_END 72 "; cat /probe/work/072.json
aswr_boundary 72
printf "running\t73\n" > /probe/work/phase
printf "ASWR_STEP_START 73\n"
printf "73\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "73" || exit 95
printf "after\t73\n" > /probe/work/phase
printf "ASWR_STEP_END 73 "; cat /probe/work/073.json
aswr_boundary 73
printf "running\t74\n" > /probe/work/phase
printf "ASWR_STEP_START 74\n"
printf "74\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "74" || exit 95
printf "after\t74\n" > /probe/work/phase
printf "ASWR_STEP_END 74 "; cat /probe/work/074.json
aswr_boundary 74
printf "running\t75\n" > /probe/work/phase
printf "ASWR_STEP_START 75\n"
printf "75\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "75" || exit 95
printf "after\t75\n" > /probe/work/phase
printf "ASWR_STEP_END 75 "; cat /probe/work/075.json
aswr_boundary 75
printf "running\t76\n" > /probe/work/phase
printf "ASWR_STEP_START 76\n"
printf "76\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "76" || exit 95
printf "after\t76\n" > /probe/work/phase
printf "ASWR_STEP_END 76 "; cat /probe/work/076.json
aswr_boundary 76
printf "running\t77\n" > /probe/work/phase
printf "ASWR_STEP_START 77\n"
printf "77\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "77" || exit 95
printf "after\t77\n" > /probe/work/phase
printf "ASWR_STEP_END 77 "; cat /probe/work/077.json
aswr_boundary 77
printf "running\t78\n" > /probe/work/phase
printf "ASWR_STEP_START 78\n"
printf "78\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "78" || exit 95
printf "after\t78\n" > /probe/work/phase
printf "ASWR_STEP_END 78 "; cat /probe/work/078.json
aswr_boundary 78
printf "running\t79\n" > /probe/work/phase
printf "ASWR_STEP_START 79\n"
printf "79\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "79" || exit 95
printf "after\t79\n" > /probe/work/phase
printf "ASWR_STEP_END 79 "; cat /probe/work/079.json
aswr_boundary 79
printf "running\t80\n" > /probe/work/phase
printf "ASWR_STEP_START 80\n"
printf "80\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "80" || exit 95
printf "after\t80\n" > /probe/work/phase
printf "ASWR_STEP_END 80 "; cat /probe/work/080.json
aswr_boundary 80
printf "running\t81\n" > /probe/work/phase
printf "ASWR_STEP_START 81\n"
printf "81\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "81" || exit 95
printf "after\t81\n" > /probe/work/phase
printf "ASWR_STEP_END 81 "; cat /probe/work/081.json
aswr_boundary 81
printf "running\t82\n" > /probe/work/phase
printf "ASWR_STEP_START 82\n"
printf "82\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "82" || exit 95
printf "after\t82\n" > /probe/work/phase
printf "ASWR_STEP_END 82 "; cat /probe/work/082.json
aswr_boundary 82
printf "running\t83\n" > /probe/work/phase
printf "ASWR_STEP_START 83\n"
printf "83\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "83" || exit 95
printf "after\t83\n" > /probe/work/phase
printf "ASWR_STEP_END 83 "; cat /probe/work/083.json
aswr_boundary 83
printf "running\t84\n" > /probe/work/phase
printf "ASWR_STEP_START 84\n"
printf "84\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "84" || exit 95
printf "after\t84\n" > /probe/work/phase
printf "ASWR_STEP_END 84 "; cat /probe/work/084.json
aswr_boundary 84
printf "running\t85\n" > /probe/work/phase
printf "ASWR_STEP_START 85\n"
printf "85\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "85" || exit 95
printf "after\t85\n" > /probe/work/phase
printf "ASWR_STEP_END 85 "; cat /probe/work/085.json
aswr_boundary 85
printf "running\t86\n" > /probe/work/phase
printf "ASWR_STEP_START 86\n"
printf "86\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "86" || exit 95
printf "after\t86\n" > /probe/work/phase
printf "ASWR_STEP_END 86 "; cat /probe/work/086.json
aswr_boundary 86
printf "running\t87\n" > /probe/work/phase
printf "ASWR_STEP_START 87\n"
printf "87\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "87" || exit 95
printf "after\t87\n" > /probe/work/phase
printf "ASWR_STEP_END 87 "; cat /probe/work/087.json
aswr_boundary 87
printf "async_dependency_wait\t88\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-86.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":86,"before_tool_step":88,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-86.done)" >> /probe/work/async-barriers.jsonl
printf "running\t88\n" > /probe/work/phase
printf "ASWR_STEP_START 88\n"
printf "88\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "88" || exit 95
printf "after\t88\n" > /probe/work/phase
printf "ASWR_STEP_END 88 "; cat /probe/work/088.json
aswr_boundary 88
printf "running\t89\n" > /probe/work/phase
printf "ASWR_STEP_START 89\n"
printf "89\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "89" || exit 95
printf "after\t89\n" > /probe/work/phase
printf "ASWR_STEP_END 89 "; cat /probe/work/089.json
aswr_boundary 89
printf "running\t90\n" > /probe/work/phase
printf "ASWR_STEP_START 90\n"
printf "90\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "90" || exit 95
printf "after\t90\n" > /probe/work/phase
printf "ASWR_STEP_END 90 "; cat /probe/work/090.json
aswr_boundary 90
printf "running\t91\n" > /probe/work/phase
printf "ASWR_STEP_START 91\n"
printf "91\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "91" || exit 95
printf "after\t91\n" > /probe/work/phase
printf "ASWR_STEP_END 91 "; cat /probe/work/091.json
aswr_boundary 91
printf "running\t92\n" > /probe/work/phase
printf "ASWR_STEP_START 92\n"
printf "92\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "92" || exit 95
printf "after\t92\n" > /probe/work/phase
printf "ASWR_STEP_END 92 "; cat /probe/work/092.json
aswr_boundary 92
printf "running\t93\n" > /probe/work/phase
printf "ASWR_STEP_START 93\n"
printf "93\n" >&198
IFS= read -r -t 1230 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "93" || exit 95
printf "after\t93\n" > /probe/work/phase
printf "ASWR_STEP_END 93 "; cat /probe/work/093.json
aswr_boundary 93
printf "running\t94\n" > /probe/work/phase
printf "ASWR_STEP_START 94\n"
printf "94\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "94" || exit 95
printf "after\t94\n" > /probe/work/phase
printf "ASWR_STEP_END 94 "; cat /probe/work/094.json
aswr_boundary 94
printf "running\t95\n" > /probe/work/phase
printf "ASWR_STEP_START 95\n"
printf "95\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "95" || exit 95
printf "after\t95\n" > /probe/work/phase
printf "ASWR_STEP_END 95 "; cat /probe/work/095.json
aswr_boundary 95
printf "running\t96\n" > /probe/work/phase
printf "ASWR_STEP_START 96\n"
printf "96\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "96" || exit 95
printf "after\t96\n" > /probe/work/phase
printf "ASWR_STEP_END 96 "; cat /probe/work/096.json
aswr_boundary 96
printf "running\t97\n" > /probe/work/phase
printf "ASWR_STEP_START 97\n"
printf "97\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "97" || exit 95
printf "after\t97\n" > /probe/work/phase
printf "ASWR_STEP_END 97 "; cat /probe/work/097.json
aswr_boundary 97
printf "running\t98\n" > /probe/work/phase
printf "ASWR_STEP_START 98\n"
printf "98\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "98" || exit 95
printf "after\t98\n" > /probe/work/phase
printf "ASWR_STEP_END 98 "; cat /probe/work/098.json
aswr_boundary 98
printf "running\t99\n" > /probe/work/phase
printf "ASWR_STEP_START 99\n"
printf "99\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "99" || exit 95
printf "after\t99\n" > /probe/work/phase
printf "ASWR_STEP_END 99 "; cat /probe/work/099.json
aswr_boundary 99
printf "running\t100\n" > /probe/work/phase
printf "ASWR_STEP_START 100\n"
printf "100\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "100" || exit 95
printf "after\t100\n" > /probe/work/phase
printf "ASWR_STEP_END 100 "; cat /probe/work/100.json
aswr_boundary 100
printf "running\t101\n" > /probe/work/phase
printf "ASWR_STEP_START 101\n"
printf "101\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "101" || exit 95
printf "after\t101\n" > /probe/work/phase
printf "ASWR_STEP_END 101 "; cat /probe/work/101.json
aswr_boundary 101
printf "running\t102\n" > /probe/work/phase
printf "ASWR_STEP_START 102\n"
printf "102\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "102" || exit 95
printf "after\t102\n" > /probe/work/phase
printf "ASWR_STEP_END 102 "; cat /probe/work/102.json
aswr_boundary 102
printf "running\t103\n" > /probe/work/phase
printf "ASWR_STEP_START 103\n"
printf "103\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "103" || exit 95
printf "after\t103\n" > /probe/work/phase
printf "ASWR_STEP_END 103 "; cat /probe/work/103.json
aswr_boundary 103
printf "running\t104\n" > /probe/work/phase
printf "ASWR_STEP_START 104\n"
printf "104\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "104" || exit 95
printf "after\t104\n" > /probe/work/phase
printf "ASWR_STEP_END 104 "; cat /probe/work/104.json
aswr_boundary 104
printf "running\t105\n" > /probe/work/phase
printf "ASWR_STEP_START 105\n"
printf "105\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "105" || exit 95
printf "after\t105\n" > /probe/work/phase
printf "ASWR_STEP_END 105 "; cat /probe/work/105.json
aswr_boundary 105
printf "running\t106\n" > /probe/work/phase
printf "ASWR_STEP_START 106\n"
printf "106\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "106" || exit 95
printf "after\t106\n" > /probe/work/phase
printf "ASWR_STEP_END 106 "; cat /probe/work/106.json
aswr_boundary 106
printf "async_dependency_wait\t107\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-102.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":102,"before_tool_step":107,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-102.done)" >> /probe/work/async-barriers.jsonl
printf "running\t107\n" > /probe/work/phase
printf "ASWR_STEP_START 107\n"
printf "107\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "107" || exit 95
printf "after\t107\n" > /probe/work/phase
printf "ASWR_STEP_END 107 "; cat /probe/work/107.json
aswr_boundary 107
printf "running\t108\n" > /probe/work/phase
printf "ASWR_STEP_START 108\n"
printf "108\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "108" || exit 95
printf "after\t108\n" > /probe/work/phase
printf "ASWR_STEP_END 108 "; cat /probe/work/108.json
aswr_boundary 108
printf "running\t109\n" > /probe/work/phase
printf "ASWR_STEP_START 109\n"
printf "109\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "109" || exit 95
printf "after\t109\n" > /probe/work/phase
printf "ASWR_STEP_END 109 "; cat /probe/work/109.json
aswr_boundary 109
printf "running\t110\n" > /probe/work/phase
printf "ASWR_STEP_START 110\n"
printf "110\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "110" || exit 95
printf "after\t110\n" > /probe/work/phase
printf "ASWR_STEP_END 110 "; cat /probe/work/110.json
aswr_boundary 110
printf "running\t111\n" > /probe/work/phase
printf "ASWR_STEP_START 111\n"
printf "111\n" >&198
IFS= read -r -t 1830 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "111" || exit 95
printf "after\t111\n" > /probe/work/phase
printf "ASWR_STEP_END 111 "; cat /probe/work/111.json
aswr_boundary 111
printf "running\t112\n" > /probe/work/phase
printf "ASWR_STEP_START 112\n"
printf "112\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "112" || exit 95
printf "after\t112\n" > /probe/work/phase
printf "ASWR_STEP_END 112 "; cat /probe/work/112.json
aswr_boundary 112
printf "running\t113\n" > /probe/work/phase
printf "ASWR_STEP_START 113\n"
printf "113\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "113" || exit 95
printf "after\t113\n" > /probe/work/phase
printf "ASWR_STEP_END 113 "; cat /probe/work/113.json
aswr_boundary 113
printf "running\t114\n" > /probe/work/phase
printf "ASWR_STEP_START 114\n"
printf "114\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "114" || exit 95
printf "after\t114\n" > /probe/work/phase
printf "ASWR_STEP_END 114 "; cat /probe/work/114.json
aswr_boundary 114
printf "running\t115\n" > /probe/work/phase
printf "ASWR_STEP_START 115\n"
printf "115\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "115" || exit 95
printf "after\t115\n" > /probe/work/phase
printf "ASWR_STEP_END 115 "; cat /probe/work/115.json
aswr_boundary 115
printf "running\t116\n" > /probe/work/phase
printf "ASWR_STEP_START 116\n"
printf "116\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "116" || exit 95
printf "after\t116\n" > /probe/work/phase
printf "ASWR_STEP_END 116 "; cat /probe/work/116.json
aswr_boundary 116
printf "running\t117\n" > /probe/work/phase
printf "ASWR_STEP_START 117\n"
printf "117\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "117" || exit 95
printf "after\t117\n" > /probe/work/phase
printf "ASWR_STEP_END 117 "; cat /probe/work/117.json
aswr_boundary 117
printf "running\t118\n" > /probe/work/phase
printf "ASWR_STEP_START 118\n"
printf "118\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "118" || exit 95
printf "after\t118\n" > /probe/work/phase
printf "ASWR_STEP_END 118 "; cat /probe/work/118.json
aswr_boundary 118
printf "running\t119\n" > /probe/work/phase
printf "ASWR_STEP_START 119\n"
printf "119\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "119" || exit 95
printf "after\t119\n" > /probe/work/phase
printf "ASWR_STEP_END 119 "; cat /probe/work/119.json
aswr_boundary 119
printf "running\t120\n" > /probe/work/phase
printf "ASWR_STEP_START 120\n"
printf "120\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "120" || exit 95
printf "after\t120\n" > /probe/work/phase
printf "ASWR_STEP_END 120 "; cat /probe/work/120.json
aswr_boundary 120
printf "running\t121\n" > /probe/work/phase
printf "ASWR_STEP_START 121\n"
printf "121\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "121" || exit 95
printf "after\t121\n" > /probe/work/phase
printf "ASWR_STEP_END 121 "; cat /probe/work/121.json
aswr_boundary 121
printf "running\t122\n" > /probe/work/phase
printf "ASWR_STEP_START 122\n"
printf "122\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "122" || exit 95
printf "after\t122\n" > /probe/work/phase
printf "ASWR_STEP_END 122 "; cat /probe/work/122.json
aswr_boundary 122
printf "running\t123\n" > /probe/work/phase
printf "ASWR_STEP_START 123\n"
printf "123\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "123" || exit 95
printf "after\t123\n" > /probe/work/phase
printf "ASWR_STEP_END 123 "; cat /probe/work/123.json
aswr_boundary 123
printf "running\t124\n" > /probe/work/phase
printf "ASWR_STEP_START 124\n"
printf "124\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "124" || exit 95
printf "after\t124\n" > /probe/work/phase
printf "ASWR_STEP_END 124 "; cat /probe/work/124.json
aswr_boundary 124
printf "running\t125\n" > /probe/work/phase
printf "ASWR_STEP_START 125\n"
printf "125\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "125" || exit 95
printf "after\t125\n" > /probe/work/phase
printf "ASWR_STEP_END 125 "; cat /probe/work/125.json
aswr_boundary 125
printf "running\t126\n" > /probe/work/phase
printf "ASWR_STEP_START 126\n"
printf "126\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "126" || exit 95
printf "after\t126\n" > /probe/work/phase
printf "ASWR_STEP_END 126 "; cat /probe/work/126.json
aswr_boundary 126
printf "running\t127\n" > /probe/work/phase
printf "ASWR_STEP_START 127\n"
printf "127\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "127" || exit 95
printf "after\t127\n" > /probe/work/phase
printf "ASWR_STEP_END 127 "; cat /probe/work/127.json
aswr_boundary 127
printf "running\t128\n" > /probe/work/phase
printf "ASWR_STEP_START 128\n"
printf "128\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "128" || exit 95
printf "after\t128\n" > /probe/work/phase
printf "ASWR_STEP_END 128 "; cat /probe/work/128.json
aswr_boundary 128
printf "running\t129\n" > /probe/work/phase
printf "ASWR_STEP_START 129\n"
printf "129\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "129" || exit 95
printf "after\t129\n" > /probe/work/phase
printf "ASWR_STEP_END 129 "; cat /probe/work/129.json
aswr_boundary 129
printf "running\t130\n" > /probe/work/phase
printf "ASWR_STEP_START 130\n"
printf "130\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "130" || exit 95
printf "after\t130\n" > /probe/work/phase
printf "ASWR_STEP_END 130 "; cat /probe/work/130.json
aswr_boundary 130
printf "running\t131\n" > /probe/work/phase
printf "ASWR_STEP_START 131\n"
printf "131\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "131" || exit 95
printf "after\t131\n" > /probe/work/phase
printf "ASWR_STEP_END 131 "; cat /probe/work/131.json
aswr_boundary 131
printf "running\t132\n" > /probe/work/phase
printf "ASWR_STEP_START 132\n"
printf "132\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "132" || exit 95
printf "after\t132\n" > /probe/work/phase
printf "ASWR_STEP_END 132 "; cat /probe/work/132.json
aswr_boundary 132
printf "running\t133\n" > /probe/work/phase
printf "ASWR_STEP_START 133\n"
printf "133\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "133" || exit 95
printf "after\t133\n" > /probe/work/phase
printf "ASWR_STEP_END 133 "; cat /probe/work/133.json
aswr_boundary 133
printf "async_dependency_wait\t134\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-132.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":132,"before_tool_step":134,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-132.done)" >> /probe/work/async-barriers.jsonl
printf "running\t134\n" > /probe/work/phase
printf "ASWR_STEP_START 134\n"
printf "134\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "134" || exit 95
printf "after\t134\n" > /probe/work/phase
printf "ASWR_STEP_END 134 "; cat /probe/work/134.json
aswr_boundary 134
printf "running\t135\n" > /probe/work/phase
printf "ASWR_STEP_START 135\n"
printf "135\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "135" || exit 95
printf "after\t135\n" > /probe/work/phase
printf "ASWR_STEP_END 135 "; cat /probe/work/135.json
aswr_boundary 135
printf "running\t136\n" > /probe/work/phase
printf "ASWR_STEP_START 136\n"
printf "136\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "136" || exit 95
printf "after\t136\n" > /probe/work/phase
printf "ASWR_STEP_END 136 "; cat /probe/work/136.json
aswr_boundary 136
printf "running\t137\n" > /probe/work/phase
printf "ASWR_STEP_START 137\n"
printf "137\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "137" || exit 95
printf "after\t137\n" > /probe/work/phase
printf "ASWR_STEP_END 137 "; cat /probe/work/137.json
aswr_boundary 137
printf "running\t138\n" > /probe/work/phase
printf "ASWR_STEP_START 138\n"
printf "138\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "138" || exit 95
printf "after\t138\n" > /probe/work/phase
printf "ASWR_STEP_END 138 "; cat /probe/work/138.json
aswr_boundary 138
printf "running\t139\n" > /probe/work/phase
printf "ASWR_STEP_START 139\n"
printf "139\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "139" || exit 95
printf "after\t139\n" > /probe/work/phase
printf "ASWR_STEP_END 139 "; cat /probe/work/139.json
aswr_boundary 139
printf "running\t140\n" > /probe/work/phase
printf "ASWR_STEP_START 140\n"
printf "140\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "140" || exit 95
printf "after\t140\n" > /probe/work/phase
printf "ASWR_STEP_END 140 "; cat /probe/work/140.json
aswr_boundary 140
printf "running\t141\n" > /probe/work/phase
printf "ASWR_STEP_START 141\n"
printf "141\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "141" || exit 95
printf "after\t141\n" > /probe/work/phase
printf "ASWR_STEP_END 141 "; cat /probe/work/141.json
aswr_boundary 141
printf "running\t142\n" > /probe/work/phase
printf "ASWR_STEP_START 142\n"
printf "142\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "142" || exit 95
printf "after\t142\n" > /probe/work/phase
printf "ASWR_STEP_END 142 "; cat /probe/work/142.json
aswr_boundary 142
printf "running\t143\n" > /probe/work/phase
printf "ASWR_STEP_START 143\n"
printf "143\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "143" || exit 95
printf "after\t143\n" > /probe/work/phase
printf "ASWR_STEP_END 143 "; cat /probe/work/143.json
aswr_boundary 143
printf "running\t144\n" > /probe/work/phase
printf "ASWR_STEP_START 144\n"
printf "144\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "144" || exit 95
printf "after\t144\n" > /probe/work/phase
printf "ASWR_STEP_END 144 "; cat /probe/work/144.json
aswr_boundary 144
printf "running\t145\n" > /probe/work/phase
printf "ASWR_STEP_START 145\n"
printf "145\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "145" || exit 95
printf "after\t145\n" > /probe/work/phase
printf "ASWR_STEP_END 145 "; cat /probe/work/145.json
aswr_boundary 145
printf "running\t146\n" > /probe/work/phase
printf "ASWR_STEP_START 146\n"
printf "146\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "146" || exit 95
printf "after\t146\n" > /probe/work/phase
printf "ASWR_STEP_END 146 "; cat /probe/work/146.json
aswr_boundary 146
printf "running\t147\n" > /probe/work/phase
printf "ASWR_STEP_START 147\n"
printf "147\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "147" || exit 95
printf "after\t147\n" > /probe/work/phase
printf "ASWR_STEP_END 147 "; cat /probe/work/147.json
aswr_boundary 147
printf "running\t148\n" > /probe/work/phase
printf "ASWR_STEP_START 148\n"
printf "148\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "148" || exit 95
printf "after\t148\n" > /probe/work/phase
printf "ASWR_STEP_END 148 "; cat /probe/work/148.json
aswr_boundary 148
printf "running\t149\n" > /probe/work/phase
printf "ASWR_STEP_START 149\n"
printf "149\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "149" || exit 95
printf "after\t149\n" > /probe/work/phase
printf "ASWR_STEP_END 149 "; cat /probe/work/149.json
aswr_boundary 149
printf "running\t150\n" > /probe/work/phase
printf "ASWR_STEP_START 150\n"
printf "150\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "150" || exit 95
printf "after\t150\n" > /probe/work/phase
printf "ASWR_STEP_END 150 "; cat /probe/work/150.json
aswr_boundary 150
printf "running\t151\n" > /probe/work/phase
printf "ASWR_STEP_START 151\n"
printf "151\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "151" || exit 95
printf "after\t151\n" > /probe/work/phase
printf "ASWR_STEP_END 151 "; cat /probe/work/151.json
aswr_boundary 151
printf "running\t152\n" > /probe/work/phase
printf "ASWR_STEP_START 152\n"
printf "152\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "152" || exit 95
printf "after\t152\n" > /probe/work/phase
printf "ASWR_STEP_END 152 "; cat /probe/work/152.json
aswr_boundary 152
printf "running\t153\n" > /probe/work/phase
printf "ASWR_STEP_START 153\n"
printf "153\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "153" || exit 95
printf "after\t153\n" > /probe/work/phase
printf "ASWR_STEP_END 153 "; cat /probe/work/153.json
aswr_boundary 153
printf "running\t154\n" > /probe/work/phase
printf "ASWR_STEP_START 154\n"
printf "154\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "154" || exit 95
printf "after\t154\n" > /probe/work/phase
printf "ASWR_STEP_END 154 "; cat /probe/work/154.json
aswr_boundary 154
printf "running\t155\n" > /probe/work/phase
printf "ASWR_STEP_START 155\n"
printf "155\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "155" || exit 95
printf "after\t155\n" > /probe/work/phase
printf "ASWR_STEP_END 155 "; cat /probe/work/155.json
aswr_boundary 155
printf "running\t156\n" > /probe/work/phase
printf "ASWR_STEP_START 156\n"
printf "156\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "156" || exit 95
printf "after\t156\n" > /probe/work/phase
printf "ASWR_STEP_END 156 "; cat /probe/work/156.json
aswr_boundary 156
printf "running\t157\n" > /probe/work/phase
printf "ASWR_STEP_START 157\n"
printf "157\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "157" || exit 95
printf "after\t157\n" > /probe/work/phase
printf "ASWR_STEP_END 157 "; cat /probe/work/157.json
aswr_boundary 157
printf "running\t158\n" > /probe/work/phase
printf "ASWR_STEP_START 158\n"
printf "158\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "158" || exit 95
printf "after\t158\n" > /probe/work/phase
printf "ASWR_STEP_END 158 "; cat /probe/work/158.json
aswr_boundary 158
printf "running\t159\n" > /probe/work/phase
printf "ASWR_STEP_START 159\n"
printf "159\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "159" || exit 95
printf "after\t159\n" > /probe/work/phase
printf "ASWR_STEP_END 159 "; cat /probe/work/159.json
aswr_boundary 159
printf "running\t160\n" > /probe/work/phase
printf "ASWR_STEP_START 160\n"
printf "160\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "160" || exit 95
printf "after\t160\n" > /probe/work/phase
printf "ASWR_STEP_END 160 "; cat /probe/work/160.json
aswr_boundary 160
printf "running\t161\n" > /probe/work/phase
printf "ASWR_STEP_START 161\n"
printf "161\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "161" || exit 95
printf "after\t161\n" > /probe/work/phase
printf "ASWR_STEP_END 161 "; cat /probe/work/161.json
aswr_boundary 161
printf "running\t162\n" > /probe/work/phase
printf "ASWR_STEP_START 162\n"
printf "162\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "162" || exit 95
printf "after\t162\n" > /probe/work/phase
printf "ASWR_STEP_END 162 "; cat /probe/work/162.json
aswr_boundary 162
printf "running\t163\n" > /probe/work/phase
printf "ASWR_STEP_START 163\n"
printf "163\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "163" || exit 95
printf "after\t163\n" > /probe/work/phase
printf "ASWR_STEP_END 163 "; cat /probe/work/163.json
aswr_boundary 163
printf "running\t164\n" > /probe/work/phase
printf "ASWR_STEP_START 164\n"
printf "164\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "164" || exit 95
printf "after\t164\n" > /probe/work/phase
printf "ASWR_STEP_END 164 "; cat /probe/work/164.json
aswr_boundary 164
printf "running\t165\n" > /probe/work/phase
printf "ASWR_STEP_START 165\n"
printf "165\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "165" || exit 95
printf "after\t165\n" > /probe/work/phase
printf "ASWR_STEP_END 165 "; cat /probe/work/165.json
aswr_boundary 165
printf "running\t166\n" > /probe/work/phase
printf "ASWR_STEP_START 166\n"
printf "166\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "166" || exit 95
printf "after\t166\n" > /probe/work/phase
printf "ASWR_STEP_END 166 "; cat /probe/work/166.json
aswr_boundary 166
printf "running\t167\n" > /probe/work/phase
printf "ASWR_STEP_START 167\n"
printf "167\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "167" || exit 95
printf "after\t167\n" > /probe/work/phase
printf "ASWR_STEP_END 167 "; cat /probe/work/167.json
aswr_boundary 167
printf "running\t168\n" > /probe/work/phase
printf "ASWR_STEP_START 168\n"
printf "168\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "168" || exit 95
printf "after\t168\n" > /probe/work/phase
printf "ASWR_STEP_END 168 "; cat /probe/work/168.json
aswr_boundary 168
printf "running\t169\n" > /probe/work/phase
printf "ASWR_STEP_START 169\n"
printf "169\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "169" || exit 95
printf "after\t169\n" > /probe/work/phase
printf "ASWR_STEP_END 169 "; cat /probe/work/169.json
aswr_boundary 169
printf "running\t170\n" > /probe/work/phase
printf "ASWR_STEP_START 170\n"
printf "170\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "170" || exit 95
printf "after\t170\n" > /probe/work/phase
printf "ASWR_STEP_END 170 "; cat /probe/work/170.json
aswr_boundary 170
printf "running\t171\n" > /probe/work/phase
printf "ASWR_STEP_START 171\n"
printf "171\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "171" || exit 95
printf "after\t171\n" > /probe/work/phase
printf "ASWR_STEP_END 171 "; cat /probe/work/171.json
aswr_boundary 171
printf "running\t172\n" > /probe/work/phase
printf "ASWR_STEP_START 172\n"
printf "172\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "172" || exit 95
printf "after\t172\n" > /probe/work/phase
printf "ASWR_STEP_END 172 "; cat /probe/work/172.json
aswr_boundary 172
printf "running\t173\n" > /probe/work/phase
printf "ASWR_STEP_START 173\n"
printf "173\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "173" || exit 95
printf "after\t173\n" > /probe/work/phase
printf "ASWR_STEP_END 173 "; cat /probe/work/173.json
aswr_boundary 173
printf "running\t174\n" > /probe/work/phase
printf "ASWR_STEP_START 174\n"
printf "174\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "174" || exit 95
printf "after\t174\n" > /probe/work/phase
printf "ASWR_STEP_END 174 "; cat /probe/work/174.json
aswr_boundary 174
printf "running\t175\n" > /probe/work/phase
printf "ASWR_STEP_START 175\n"
printf "175\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "175" || exit 95
printf "after\t175\n" > /probe/work/phase
printf "ASWR_STEP_END 175 "; cat /probe/work/175.json
aswr_boundary 175
printf "async_dependency_wait\t176\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-174.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":174,"before_tool_step":176,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-174.done)" >> /probe/work/async-barriers.jsonl
printf "running\t176\n" > /probe/work/phase
printf "ASWR_STEP_START 176\n"
printf "176\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "176" || exit 95
printf "after\t176\n" > /probe/work/phase
printf "ASWR_STEP_END 176 "; cat /probe/work/176.json
aswr_boundary 176
printf "running\t177\n" > /probe/work/phase
printf "ASWR_STEP_START 177\n"
printf "177\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "177" || exit 95
printf "after\t177\n" > /probe/work/phase
printf "ASWR_STEP_END 177 "; cat /probe/work/177.json
aswr_boundary 177
printf "running\t178\n" > /probe/work/phase
printf "ASWR_STEP_START 178\n"
printf "178\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "178" || exit 95
printf "after\t178\n" > /probe/work/phase
printf "ASWR_STEP_END 178 "; cat /probe/work/178.json
aswr_boundary 178
printf "running\t179\n" > /probe/work/phase
printf "ASWR_STEP_START 179\n"
printf "179\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "179" || exit 95
printf "after\t179\n" > /probe/work/phase
printf "ASWR_STEP_END 179 "; cat /probe/work/179.json
aswr_boundary 179
printf "running\t180\n" > /probe/work/phase
printf "ASWR_STEP_START 180\n"
printf "180\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "180" || exit 95
printf "after\t180\n" > /probe/work/phase
printf "ASWR_STEP_END 180 "; cat /probe/work/180.json
aswr_boundary 180
printf "running\t181\n" > /probe/work/phase
printf "ASWR_STEP_START 181\n"
printf "181\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "181" || exit 95
printf "after\t181\n" > /probe/work/phase
printf "ASWR_STEP_END 181 "; cat /probe/work/181.json
aswr_boundary 181
printf "running\t182\n" > /probe/work/phase
printf "ASWR_STEP_START 182\n"
printf "182\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "182" || exit 95
printf "after\t182\n" > /probe/work/phase
printf "ASWR_STEP_END 182 "; cat /probe/work/182.json
aswr_boundary 182
printf "running\t183\n" > /probe/work/phase
printf "ASWR_STEP_START 183\n"
printf "183\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "183" || exit 95
printf "after\t183\n" > /probe/work/phase
printf "ASWR_STEP_END 183 "; cat /probe/work/183.json
aswr_boundary 183
printf "running\t184\n" > /probe/work/phase
printf "ASWR_STEP_START 184\n"
printf "184\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "184" || exit 95
printf "after\t184\n" > /probe/work/phase
printf "ASWR_STEP_END 184 "; cat /probe/work/184.json
aswr_boundary 184
printf "running\t185\n" > /probe/work/phase
printf "ASWR_STEP_START 185\n"
printf "185\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "185" || exit 95
printf "after\t185\n" > /probe/work/phase
printf "ASWR_STEP_END 185 "; cat /probe/work/185.json
aswr_boundary 185
printf "running\t186\n" > /probe/work/phase
printf "ASWR_STEP_START 186\n"
printf "186\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "186" || exit 95
printf "after\t186\n" > /probe/work/phase
printf "ASWR_STEP_END 186 "; cat /probe/work/186.json
aswr_boundary 186
printf "running\t187\n" > /probe/work/phase
printf "ASWR_STEP_START 187\n"
printf "187\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "187" || exit 95
printf "after\t187\n" > /probe/work/phase
printf "ASWR_STEP_END 187 "; cat /probe/work/187.json
aswr_boundary 187
printf "running\t188\n" > /probe/work/phase
printf "ASWR_STEP_START 188\n"
printf "188\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "188" || exit 95
printf "after\t188\n" > /probe/work/phase
printf "ASWR_STEP_END 188 "; cat /probe/work/188.json
aswr_boundary 188
printf "running\t189\n" > /probe/work/phase
printf "ASWR_STEP_START 189\n"
printf "189\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "189" || exit 95
printf "after\t189\n" > /probe/work/phase
printf "ASWR_STEP_END 189 "; cat /probe/work/189.json
aswr_boundary 189
printf "running\t190\n" > /probe/work/phase
printf "ASWR_STEP_START 190\n"
printf "190\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "190" || exit 95
printf "after\t190\n" > /probe/work/phase
printf "ASWR_STEP_END 190 "; cat /probe/work/190.json
aswr_boundary 190
printf "running\t191\n" > /probe/work/phase
printf "ASWR_STEP_START 191\n"
printf "191\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "191" || exit 95
printf "after\t191\n" > /probe/work/phase
printf "ASWR_STEP_END 191 "; cat /probe/work/191.json
aswr_boundary 191
printf "running\t192\n" > /probe/work/phase
printf "ASWR_STEP_START 192\n"
printf "192\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "192" || exit 95
printf "after\t192\n" > /probe/work/phase
printf "ASWR_STEP_END 192 "; cat /probe/work/192.json
aswr_boundary 192
printf "running\t193\n" > /probe/work/phase
printf "ASWR_STEP_START 193\n"
printf "193\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "193" || exit 95
printf "after\t193\n" > /probe/work/phase
printf "ASWR_STEP_END 193 "; cat /probe/work/193.json
aswr_boundary 193
printf "running\t194\n" > /probe/work/phase
printf "ASWR_STEP_START 194\n"
printf "194\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "194" || exit 95
printf "after\t194\n" > /probe/work/phase
printf "ASWR_STEP_END 194 "; cat /probe/work/194.json
aswr_boundary 194
printf "running\t195\n" > /probe/work/phase
printf "ASWR_STEP_START 195\n"
printf "195\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "195" || exit 95
printf "after\t195\n" > /probe/work/phase
printf "ASWR_STEP_END 195 "; cat /probe/work/195.json
aswr_boundary 195
printf "running\t196\n" > /probe/work/phase
printf "ASWR_STEP_START 196\n"
printf "196\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "196" || exit 95
printf "after\t196\n" > /probe/work/phase
printf "ASWR_STEP_END 196 "; cat /probe/work/196.json
aswr_boundary 196
printf "running\t197\n" > /probe/work/phase
printf "ASWR_STEP_START 197\n"
printf "197\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "197" || exit 95
printf "after\t197\n" > /probe/work/phase
printf "ASWR_STEP_END 197 "; cat /probe/work/197.json
aswr_boundary 197
printf "running\t198\n" > /probe/work/phase
printf "ASWR_STEP_START 198\n"
printf "198\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "198" || exit 95
printf "after\t198\n" > /probe/work/phase
printf "ASWR_STEP_END 198 "; cat /probe/work/198.json
aswr_boundary 198
printf "running\t199\n" > /probe/work/phase
printf "ASWR_STEP_START 199\n"
printf "199\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "199" || exit 95
printf "after\t199\n" > /probe/work/phase
printf "ASWR_STEP_END 199 "; cat /probe/work/199.json
aswr_boundary 199
printf "running\t200\n" > /probe/work/phase
printf "ASWR_STEP_START 200\n"
printf "200\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "200" || exit 95
printf "after\t200\n" > /probe/work/phase
printf "ASWR_STEP_END 200 "; cat /probe/work/200.json
aswr_boundary 200
printf "running\t201\n" > /probe/work/phase
printf "ASWR_STEP_START 201\n"
printf "201\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "201" || exit 95
printf "after\t201\n" > /probe/work/phase
printf "ASWR_STEP_END 201 "; cat /probe/work/201.json
aswr_boundary 201
printf "running\t202\n" > /probe/work/phase
printf "ASWR_STEP_START 202\n"
printf "202\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "202" || exit 95
printf "after\t202\n" > /probe/work/phase
printf "ASWR_STEP_END 202 "; cat /probe/work/202.json
aswr_boundary 202
printf "running\t203\n" > /probe/work/phase
printf "ASWR_STEP_START 203\n"
printf "203\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "203" || exit 95
printf "after\t203\n" > /probe/work/phase
printf "ASWR_STEP_END 203 "; cat /probe/work/203.json
aswr_boundary 203
printf "running\t204\n" > /probe/work/phase
printf "ASWR_STEP_START 204\n"
printf "204\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "204" || exit 95
printf "after\t204\n" > /probe/work/phase
printf "ASWR_STEP_END 204 "; cat /probe/work/204.json
aswr_boundary 204
printf "running\t205\n" > /probe/work/phase
printf "ASWR_STEP_START 205\n"
printf "205\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "205" || exit 95
printf "after\t205\n" > /probe/work/phase
printf "ASWR_STEP_END 205 "; cat /probe/work/205.json
aswr_boundary 205
printf "running\t206\n" > /probe/work/phase
printf "ASWR_STEP_START 206\n"
printf "206\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "206" || exit 95
printf "after\t206\n" > /probe/work/phase
printf "ASWR_STEP_END 206 "; cat /probe/work/206.json
aswr_boundary 206
printf "running\t207\n" > /probe/work/phase
printf "ASWR_STEP_START 207\n"
printf "207\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "207" || exit 95
printf "after\t207\n" > /probe/work/phase
printf "ASWR_STEP_END 207 "; cat /probe/work/207.json
aswr_boundary 207
printf "running\t208\n" > /probe/work/phase
printf "ASWR_STEP_START 208\n"
printf "208\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "208" || exit 95
printf "after\t208\n" > /probe/work/phase
printf "ASWR_STEP_END 208 "; cat /probe/work/208.json
aswr_boundary 208
printf "running\t209\n" > /probe/work/phase
printf "ASWR_STEP_START 209\n"
printf "209\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "209" || exit 95
printf "after\t209\n" > /probe/work/phase
printf "ASWR_STEP_END 209 "; cat /probe/work/209.json
aswr_boundary 209
printf "running\t210\n" > /probe/work/phase
printf "ASWR_STEP_START 210\n"
printf "210\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "210" || exit 95
printf "after\t210\n" > /probe/work/phase
printf "ASWR_STEP_END 210 "; cat /probe/work/210.json
aswr_boundary 210
printf "running\t211\n" > /probe/work/phase
printf "ASWR_STEP_START 211\n"
printf "211\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "211" || exit 95
printf "after\t211\n" > /probe/work/phase
printf "ASWR_STEP_END 211 "; cat /probe/work/211.json
aswr_boundary 211
printf "running\t212\n" > /probe/work/phase
printf "ASWR_STEP_START 212\n"
printf "212\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "212" || exit 95
printf "after\t212\n" > /probe/work/phase
printf "ASWR_STEP_END 212 "; cat /probe/work/212.json
aswr_boundary 212
printf "running\t213\n" > /probe/work/phase
printf "ASWR_STEP_START 213\n"
printf "213\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "213" || exit 95
printf "after\t213\n" > /probe/work/phase
printf "ASWR_STEP_END 213 "; cat /probe/work/213.json
aswr_boundary 213
printf "running\t214\n" > /probe/work/phase
printf "ASWR_STEP_START 214\n"
printf "214\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "214" || exit 95
printf "after\t214\n" > /probe/work/phase
printf "ASWR_STEP_END 214 "; cat /probe/work/214.json
aswr_boundary 214
printf "running\t215\n" > /probe/work/phase
printf "ASWR_STEP_START 215\n"
printf "215\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "215" || exit 95
printf "after\t215\n" > /probe/work/phase
printf "ASWR_STEP_END 215 "; cat /probe/work/215.json
aswr_boundary 215
printf "running\t216\n" > /probe/work/phase
printf "ASWR_STEP_START 216\n"
printf "216\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "216" || exit 95
printf "after\t216\n" > /probe/work/phase
printf "ASWR_STEP_END 216 "; cat /probe/work/216.json
aswr_boundary 216
printf "running\t217\n" > /probe/work/phase
printf "ASWR_STEP_START 217\n"
printf "217\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "217" || exit 95
printf "after\t217\n" > /probe/work/phase
printf "ASWR_STEP_END 217 "; cat /probe/work/217.json
aswr_boundary 217
printf "running\t218\n" > /probe/work/phase
printf "ASWR_STEP_START 218\n"
printf "218\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "218" || exit 95
printf "after\t218\n" > /probe/work/phase
printf "ASWR_STEP_END 218 "; cat /probe/work/218.json
aswr_boundary 218
printf "running\t219\n" > /probe/work/phase
printf "ASWR_STEP_START 219\n"
printf "219\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "219" || exit 95
printf "after\t219\n" > /probe/work/phase
printf "ASWR_STEP_END 219 "; cat /probe/work/219.json
aswr_boundary 219
printf "running\t220\n" > /probe/work/phase
printf "ASWR_STEP_START 220\n"
printf "220\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "220" || exit 95
printf "after\t220\n" > /probe/work/phase
printf "ASWR_STEP_END 220 "; cat /probe/work/220.json
aswr_boundary 220
printf "running\t221\n" > /probe/work/phase
printf "ASWR_STEP_START 221\n"
printf "221\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "221" || exit 95
printf "after\t221\n" > /probe/work/phase
printf "ASWR_STEP_END 221 "; cat /probe/work/221.json
aswr_boundary 221
printf "running\t222\n" > /probe/work/phase
printf "ASWR_STEP_START 222\n"
printf "222\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "222" || exit 95
printf "after\t222\n" > /probe/work/phase
printf "ASWR_STEP_END 222 "; cat /probe/work/222.json
aswr_boundary 222
printf "running\t223\n" > /probe/work/phase
printf "ASWR_STEP_START 223\n"
printf "223\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "223" || exit 95
printf "after\t223\n" > /probe/work/phase
printf "ASWR_STEP_END 223 "; cat /probe/work/223.json
aswr_boundary 223
printf "running\t224\n" > /probe/work/phase
printf "ASWR_STEP_START 224\n"
printf "224\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "224" || exit 95
printf "after\t224\n" > /probe/work/phase
printf "ASWR_STEP_END 224 "; cat /probe/work/224.json
aswr_boundary 224
printf "running\t225\n" > /probe/work/phase
printf "ASWR_STEP_START 225\n"
printf "225\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "225" || exit 95
printf "after\t225\n" > /probe/work/phase
printf "ASWR_STEP_END 225 "; cat /probe/work/225.json
aswr_boundary 225
printf "running\t226\n" > /probe/work/phase
printf "ASWR_STEP_START 226\n"
printf "226\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "226" || exit 95
printf "after\t226\n" > /probe/work/phase
printf "ASWR_STEP_END 226 "; cat /probe/work/226.json
aswr_boundary 226
printf "running\t227\n" > /probe/work/phase
printf "ASWR_STEP_START 227\n"
printf "227\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "227" || exit 95
printf "after\t227\n" > /probe/work/phase
printf "ASWR_STEP_END 227 "; cat /probe/work/227.json
aswr_boundary 227
printf "running\t228\n" > /probe/work/phase
printf "ASWR_STEP_START 228\n"
printf "228\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "228" || exit 95
printf "after\t228\n" > /probe/work/phase
printf "ASWR_STEP_END 228 "; cat /probe/work/228.json
aswr_boundary 228
printf "running\t229\n" > /probe/work/phase
printf "ASWR_STEP_START 229\n"
printf "229\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "229" || exit 95
printf "after\t229\n" > /probe/work/phase
printf "ASWR_STEP_END 229 "; cat /probe/work/229.json
aswr_boundary 229
printf "running\t230\n" > /probe/work/phase
printf "ASWR_STEP_START 230\n"
printf "230\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "230" || exit 95
printf "after\t230\n" > /probe/work/phase
printf "ASWR_STEP_END 230 "; cat /probe/work/230.json
aswr_boundary 230
printf "running\t231\n" > /probe/work/phase
printf "ASWR_STEP_START 231\n"
printf "231\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "231" || exit 95
printf "after\t231\n" > /probe/work/phase
printf "ASWR_STEP_END 231 "; cat /probe/work/231.json
aswr_boundary 231
printf "running\t232\n" > /probe/work/phase
printf "ASWR_STEP_START 232\n"
printf "232\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "232" || exit 95
printf "after\t232\n" > /probe/work/phase
printf "ASWR_STEP_END 232 "; cat /probe/work/232.json
aswr_boundary 232
printf "running\t233\n" > /probe/work/phase
printf "ASWR_STEP_START 233\n"
printf "233\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "233" || exit 95
printf "after\t233\n" > /probe/work/phase
printf "ASWR_STEP_END 233 "; cat /probe/work/233.json
aswr_boundary 233
printf "running\t234\n" > /probe/work/phase
printf "ASWR_STEP_START 234\n"
printf "234\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "234" || exit 95
printf "after\t234\n" > /probe/work/phase
printf "ASWR_STEP_END 234 "; cat /probe/work/234.json
aswr_boundary 234
printf "running\t235\n" > /probe/work/phase
printf "ASWR_STEP_START 235\n"
printf "235\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "235" || exit 95
printf "after\t235\n" > /probe/work/phase
printf "ASWR_STEP_END 235 "; cat /probe/work/235.json
aswr_boundary 235
printf "running\t236\n" > /probe/work/phase
printf "ASWR_STEP_START 236\n"
printf "236\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "236" || exit 95
printf "after\t236\n" > /probe/work/phase
printf "ASWR_STEP_END 236 "; cat /probe/work/236.json
aswr_boundary 236
printf "running\t237\n" > /probe/work/phase
printf "ASWR_STEP_START 237\n"
printf "237\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "237" || exit 95
printf "after\t237\n" > /probe/work/phase
printf "ASWR_STEP_END 237 "; cat /probe/work/237.json
aswr_boundary 237
printf "running\t238\n" > /probe/work/phase
printf "ASWR_STEP_START 238\n"
printf "238\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "238" || exit 95
printf "after\t238\n" > /probe/work/phase
printf "ASWR_STEP_END 238 "; cat /probe/work/238.json
aswr_boundary 238
printf "running\t239\n" > /probe/work/phase
printf "ASWR_STEP_START 239\n"
printf "239\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "239" || exit 95
printf "after\t239\n" > /probe/work/phase
printf "ASWR_STEP_END 239 "; cat /probe/work/239.json
aswr_boundary 239
printf "running\t240\n" > /probe/work/phase
printf "ASWR_STEP_START 240\n"
printf "240\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "240" || exit 95
printf "after\t240\n" > /probe/work/phase
printf "ASWR_STEP_END 240 "; cat /probe/work/240.json
aswr_boundary 240
printf "running\t241\n" > /probe/work/phase
printf "ASWR_STEP_START 241\n"
printf "241\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "241" || exit 95
printf "after\t241\n" > /probe/work/phase
printf "ASWR_STEP_END 241 "; cat /probe/work/241.json
aswr_boundary 241
printf "running\t242\n" > /probe/work/phase
printf "ASWR_STEP_START 242\n"
printf "242\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "242" || exit 95
printf "after\t242\n" > /probe/work/phase
printf "ASWR_STEP_END 242 "; cat /probe/work/242.json
aswr_boundary 242
printf "running\t243\n" > /probe/work/phase
printf "ASWR_STEP_START 243\n"
printf "243\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "243" || exit 95
printf "after\t243\n" > /probe/work/phase
printf "ASWR_STEP_END 243 "; cat /probe/work/243.json
aswr_boundary 243
printf "running\t244\n" > /probe/work/phase
printf "ASWR_STEP_START 244\n"
printf "244\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "244" || exit 95
printf "after\t244\n" > /probe/work/phase
printf "ASWR_STEP_END 244 "; cat /probe/work/244.json
aswr_boundary 244
printf "async_dependency_wait\t245\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-241.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":241,"before_tool_step":245,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-241.done)" >> /probe/work/async-barriers.jsonl
printf "running\t245\n" > /probe/work/phase
printf "ASWR_STEP_START 245\n"
printf "245\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "245" || exit 95
printf "after\t245\n" > /probe/work/phase
printf "ASWR_STEP_END 245 "; cat /probe/work/245.json
aswr_boundary 245
printf "running\t246\n" > /probe/work/phase
printf "ASWR_STEP_START 246\n"
printf "246\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "246" || exit 95
printf "after\t246\n" > /probe/work/phase
printf "ASWR_STEP_END 246 "; cat /probe/work/246.json
aswr_boundary 246
printf "running\t247\n" > /probe/work/phase
printf "ASWR_STEP_START 247\n"
printf "247\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "247" || exit 95
printf "after\t247\n" > /probe/work/phase
printf "ASWR_STEP_END 247 "; cat /probe/work/247.json
aswr_boundary 247
printf "running\t248\n" > /probe/work/phase
printf "ASWR_STEP_START 248\n"
printf "248\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "248" || exit 95
printf "after\t248\n" > /probe/work/phase
printf "ASWR_STEP_END 248 "; cat /probe/work/248.json
aswr_boundary 248
printf "running\t249\n" > /probe/work/phase
printf "ASWR_STEP_START 249\n"
printf "249\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "249" || exit 95
printf "after\t249\n" > /probe/work/phase
printf "ASWR_STEP_END 249 "; cat /probe/work/249.json
aswr_boundary 249
printf "running\t250\n" > /probe/work/phase
printf "ASWR_STEP_START 250\n"
printf "250\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "250" || exit 95
printf "after\t250\n" > /probe/work/phase
printf "ASWR_STEP_END 250 "; cat /probe/work/250.json
aswr_boundary 250
printf "running\t251\n" > /probe/work/phase
printf "ASWR_STEP_START 251\n"
printf "251\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "251" || exit 95
printf "after\t251\n" > /probe/work/phase
printf "ASWR_STEP_END 251 "; cat /probe/work/251.json
aswr_boundary 251
printf "running\t252\n" > /probe/work/phase
printf "ASWR_STEP_START 252\n"
printf "252\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "252" || exit 95
printf "after\t252\n" > /probe/work/phase
printf "ASWR_STEP_END 252 "; cat /probe/work/252.json
aswr_boundary 252
printf "running\t253\n" > /probe/work/phase
printf "ASWR_STEP_START 253\n"
printf "253\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "253" || exit 95
printf "after\t253\n" > /probe/work/phase
printf "ASWR_STEP_END 253 "; cat /probe/work/253.json
aswr_boundary 253
printf "running\t254\n" > /probe/work/phase
printf "ASWR_STEP_START 254\n"
printf "254\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "254" || exit 95
printf "after\t254\n" > /probe/work/phase
printf "ASWR_STEP_END 254 "; cat /probe/work/254.json
aswr_boundary 254
printf "running\t255\n" > /probe/work/phase
printf "ASWR_STEP_START 255\n"
printf "255\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "255" || exit 95
printf "after\t255\n" > /probe/work/phase
printf "ASWR_STEP_END 255 "; cat /probe/work/255.json
aswr_boundary 255
printf "running\t256\n" > /probe/work/phase
printf "ASWR_STEP_START 256\n"
printf "256\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "256" || exit 95
printf "after\t256\n" > /probe/work/phase
printf "ASWR_STEP_END 256 "; cat /probe/work/256.json
aswr_boundary 256
printf "running\t257\n" > /probe/work/phase
printf "ASWR_STEP_START 257\n"
printf "257\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "257" || exit 95
printf "after\t257\n" > /probe/work/phase
printf "ASWR_STEP_END 257 "; cat /probe/work/257.json
aswr_boundary 257
printf "running\t258\n" > /probe/work/phase
printf "ASWR_STEP_START 258\n"
printf "258\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "258" || exit 95
printf "after\t258\n" > /probe/work/phase
printf "ASWR_STEP_END 258 "; cat /probe/work/258.json
aswr_boundary 258
printf "running\t259\n" > /probe/work/phase
printf "ASWR_STEP_START 259\n"
printf "259\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "259" || exit 95
printf "after\t259\n" > /probe/work/phase
printf "ASWR_STEP_END 259 "; cat /probe/work/259.json
aswr_boundary 259
printf "async_dependency_wait\t260\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-258.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":258,"before_tool_step":260,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-258.done)" >> /probe/work/async-barriers.jsonl
printf "running\t260\n" > /probe/work/phase
printf "ASWR_STEP_START 260\n"
printf "260\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "260" || exit 95
printf "after\t260\n" > /probe/work/phase
printf "ASWR_STEP_END 260 "; cat /probe/work/260.json
aswr_boundary 260
printf "running\t261\n" > /probe/work/phase
printf "ASWR_STEP_START 261\n"
printf "261\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "261" || exit 95
printf "after\t261\n" > /probe/work/phase
printf "ASWR_STEP_END 261 "; cat /probe/work/261.json
aswr_boundary 261
printf "running\t262\n" > /probe/work/phase
printf "ASWR_STEP_START 262\n"
printf "262\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "262" || exit 95
printf "after\t262\n" > /probe/work/phase
printf "ASWR_STEP_END 262 "; cat /probe/work/262.json
aswr_boundary 262
printf "running\t263\n" > /probe/work/phase
printf "ASWR_STEP_START 263\n"
printf "263\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "263" || exit 95
printf "after\t263\n" > /probe/work/phase
printf "ASWR_STEP_END 263 "; cat /probe/work/263.json
aswr_boundary 263
printf "running\t264\n" > /probe/work/phase
printf "ASWR_STEP_START 264\n"
printf "264\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "264" || exit 95
printf "after\t264\n" > /probe/work/phase
printf "ASWR_STEP_END 264 "; cat /probe/work/264.json
aswr_boundary 264
printf "running\t265\n" > /probe/work/phase
printf "ASWR_STEP_START 265\n"
printf "265\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "265" || exit 95
printf "after\t265\n" > /probe/work/phase
printf "ASWR_STEP_END 265 "; cat /probe/work/265.json
aswr_boundary 265
printf "running\t266\n" > /probe/work/phase
printf "ASWR_STEP_START 266\n"
printf "266\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "266" || exit 95
printf "after\t266\n" > /probe/work/phase
printf "ASWR_STEP_END 266 "; cat /probe/work/266.json
aswr_boundary 266
printf "running\t267\n" > /probe/work/phase
printf "ASWR_STEP_START 267\n"
printf "267\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "267" || exit 95
printf "after\t267\n" > /probe/work/phase
printf "ASWR_STEP_END 267 "; cat /probe/work/267.json
aswr_boundary 267
printf "running\t268\n" > /probe/work/phase
printf "ASWR_STEP_START 268\n"
printf "268\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "268" || exit 95
printf "after\t268\n" > /probe/work/phase
printf "ASWR_STEP_END 268 "; cat /probe/work/268.json
aswr_boundary 268
printf "running\t269\n" > /probe/work/phase
printf "ASWR_STEP_START 269\n"
printf "269\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "269" || exit 95
printf "after\t269\n" > /probe/work/phase
printf "ASWR_STEP_END 269 "; cat /probe/work/269.json
aswr_boundary 269
printf "running\t270\n" > /probe/work/phase
printf "ASWR_STEP_START 270\n"
printf "270\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "270" || exit 95
printf "after\t270\n" > /probe/work/phase
printf "ASWR_STEP_END 270 "; cat /probe/work/270.json
aswr_boundary 270
printf "running\t271\n" > /probe/work/phase
printf "ASWR_STEP_START 271\n"
printf "271\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "271" || exit 95
printf "after\t271\n" > /probe/work/phase
printf "ASWR_STEP_END 271 "; cat /probe/work/271.json
aswr_boundary 271
printf "running\t272\n" > /probe/work/phase
printf "ASWR_STEP_START 272\n"
printf "272\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "272" || exit 95
printf "after\t272\n" > /probe/work/phase
printf "ASWR_STEP_END 272 "; cat /probe/work/272.json
aswr_boundary 272
printf "running\t273\n" > /probe/work/phase
printf "ASWR_STEP_START 273\n"
printf "273\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "273" || exit 95
printf "after\t273\n" > /probe/work/phase
printf "ASWR_STEP_END 273 "; cat /probe/work/273.json
aswr_boundary 273
printf "running\t274\n" > /probe/work/phase
printf "ASWR_STEP_START 274\n"
printf "274\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "274" || exit 95
printf "after\t274\n" > /probe/work/phase
printf "ASWR_STEP_END 274 "; cat /probe/work/274.json
aswr_boundary 274
printf "running\t275\n" > /probe/work/phase
printf "ASWR_STEP_START 275\n"
printf "275\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "275" || exit 95
printf "after\t275\n" > /probe/work/phase
printf "ASWR_STEP_END 275 "; cat /probe/work/275.json
aswr_boundary 275
printf "async_dependency_wait\t276\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-273.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":273,"before_tool_step":276,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-273.done)" >> /probe/work/async-barriers.jsonl
printf "running\t276\n" > /probe/work/phase
printf "ASWR_STEP_START 276\n"
printf "276\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "276" || exit 95
printf "after\t276\n" > /probe/work/phase
printf "ASWR_STEP_END 276 "; cat /probe/work/276.json
aswr_boundary 276
printf "running\t277\n" > /probe/work/phase
printf "ASWR_STEP_START 277\n"
printf "277\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "277" || exit 95
printf "after\t277\n" > /probe/work/phase
printf "ASWR_STEP_END 277 "; cat /probe/work/277.json
aswr_boundary 277
printf "async_dependency_wait\t278\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-276.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":276,"before_tool_step":278,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-276.done)" >> /probe/work/async-barriers.jsonl
printf "running\t278\n" > /probe/work/phase
printf "ASWR_STEP_START 278\n"
printf "278\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "278" || exit 95
printf "after\t278\n" > /probe/work/phase
printf "ASWR_STEP_END 278 "; cat /probe/work/278.json
aswr_boundary 278
printf "running\t279\n" > /probe/work/phase
printf "ASWR_STEP_START 279\n"
printf "279\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "279" || exit 95
printf "after\t279\n" > /probe/work/phase
printf "ASWR_STEP_END 279 "; cat /probe/work/279.json
aswr_boundary 279
printf "running\t280\n" > /probe/work/phase
printf "ASWR_STEP_START 280\n"
printf "280\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "280" || exit 95
printf "after\t280\n" > /probe/work/phase
printf "ASWR_STEP_END 280 "; cat /probe/work/280.json
aswr_boundary 280
printf "running\t281\n" > /probe/work/phase
printf "ASWR_STEP_START 281\n"
printf "281\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "281" || exit 95
printf "after\t281\n" > /probe/work/phase
printf "ASWR_STEP_END 281 "; cat /probe/work/281.json
aswr_boundary 281
printf "running\t282\n" > /probe/work/phase
printf "ASWR_STEP_START 282\n"
printf "282\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "282" || exit 95
printf "after\t282\n" > /probe/work/phase
printf "ASWR_STEP_END 282 "; cat /probe/work/282.json
aswr_boundary 282
printf "running\t283\n" > /probe/work/phase
printf "ASWR_STEP_START 283\n"
printf "283\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "283" || exit 95
printf "after\t283\n" > /probe/work/phase
printf "ASWR_STEP_END 283 "; cat /probe/work/283.json
aswr_boundary 283
printf "running\t284\n" > /probe/work/phase
printf "ASWR_STEP_START 284\n"
printf "284\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "284" || exit 95
printf "after\t284\n" > /probe/work/phase
printf "ASWR_STEP_END 284 "; cat /probe/work/284.json
aswr_boundary 284
printf "running\t285\n" > /probe/work/phase
printf "ASWR_STEP_START 285\n"
printf "285\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "285" || exit 95
printf "after\t285\n" > /probe/work/phase
printf "ASWR_STEP_END 285 "; cat /probe/work/285.json
aswr_boundary 285
printf "running\t286\n" > /probe/work/phase
printf "ASWR_STEP_START 286\n"
printf "286\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "286" || exit 95
printf "after\t286\n" > /probe/work/phase
printf "ASWR_STEP_END 286 "; cat /probe/work/286.json
aswr_boundary 286
printf "running\t287\n" > /probe/work/phase
printf "ASWR_STEP_START 287\n"
printf "287\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "287" || exit 95
printf "after\t287\n" > /probe/work/phase
printf "ASWR_STEP_END 287 "; cat /probe/work/287.json
aswr_boundary 287
printf "running\t288\n" > /probe/work/phase
printf "ASWR_STEP_START 288\n"
printf "288\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "288" || exit 95
printf "after\t288\n" > /probe/work/phase
printf "ASWR_STEP_END 288 "; cat /probe/work/288.json
aswr_boundary 288
printf "running\t289\n" > /probe/work/phase
printf "ASWR_STEP_START 289\n"
printf "289\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "289" || exit 95
printf "after\t289\n" > /probe/work/phase
printf "ASWR_STEP_END 289 "; cat /probe/work/289.json
aswr_boundary 289
printf "running\t290\n" > /probe/work/phase
printf "ASWR_STEP_START 290\n"
printf "290\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "290" || exit 95
printf "after\t290\n" > /probe/work/phase
printf "ASWR_STEP_END 290 "; cat /probe/work/290.json
aswr_boundary 290
printf "running\t291\n" > /probe/work/phase
printf "ASWR_STEP_START 291\n"
printf "291\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "291" || exit 95
printf "after\t291\n" > /probe/work/phase
printf "ASWR_STEP_END 291 "; cat /probe/work/291.json
aswr_boundary 291
printf "running\t292\n" > /probe/work/phase
printf "ASWR_STEP_START 292\n"
printf "292\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "292" || exit 95
printf "after\t292\n" > /probe/work/phase
printf "ASWR_STEP_END 292 "; cat /probe/work/292.json
aswr_boundary 292
printf "running\t293\n" > /probe/work/phase
printf "ASWR_STEP_START 293\n"
printf "293\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "293" || exit 95
printf "after\t293\n" > /probe/work/phase
printf "ASWR_STEP_END 293 "; cat /probe/work/293.json
aswr_boundary 293
printf "running\t294\n" > /probe/work/phase
printf "ASWR_STEP_START 294\n"
printf "294\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "294" || exit 95
printf "after\t294\n" > /probe/work/phase
printf "ASWR_STEP_END 294 "; cat /probe/work/294.json
aswr_boundary 294
printf "running\t295\n" > /probe/work/phase
printf "ASWR_STEP_START 295\n"
printf "295\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "295" || exit 95
printf "after\t295\n" > /probe/work/phase
printf "ASWR_STEP_END 295 "; cat /probe/work/295.json
aswr_boundary 295
printf "running\t296\n" > /probe/work/phase
printf "ASWR_STEP_START 296\n"
printf "296\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "296" || exit 95
printf "after\t296\n" > /probe/work/phase
printf "ASWR_STEP_END 296 "; cat /probe/work/296.json
aswr_boundary 296
printf "running\t297\n" > /probe/work/phase
printf "ASWR_STEP_START 297\n"
printf "297\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "297" || exit 95
printf "after\t297\n" > /probe/work/phase
printf "ASWR_STEP_END 297 "; cat /probe/work/297.json
aswr_boundary 297
printf "running\t298\n" > /probe/work/phase
printf "ASWR_STEP_START 298\n"
printf "298\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "298" || exit 95
printf "after\t298\n" > /probe/work/phase
printf "ASWR_STEP_END 298 "; cat /probe/work/298.json
aswr_boundary 298
printf "running\t299\n" > /probe/work/phase
printf "ASWR_STEP_START 299\n"
printf "299\n" >&198
IFS= read -r -t 3630 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "299" || exit 95
printf "after\t299\n" > /probe/work/phase
printf "ASWR_STEP_END 299 "; cat /probe/work/299.json
aswr_boundary 299
printf "running\t300\n" > /probe/work/phase
printf "ASWR_STEP_START 300\n"
printf "300\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "300" || exit 95
printf "after\t300\n" > /probe/work/phase
printf "ASWR_STEP_END 300 "; cat /probe/work/300.json
aswr_boundary 300
printf "running\t301\n" > /probe/work/phase
printf "ASWR_STEP_START 301\n"
printf "301\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "301" || exit 95
printf "after\t301\n" > /probe/work/phase
printf "ASWR_STEP_END 301 "; cat /probe/work/301.json
aswr_boundary 301
printf "running\t302\n" > /probe/work/phase
printf "ASWR_STEP_START 302\n"
printf "302\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "302" || exit 95
printf "after\t302\n" > /probe/work/phase
printf "ASWR_STEP_END 302 "; cat /probe/work/302.json
aswr_boundary 302
printf "running\t303\n" > /probe/work/phase
printf "ASWR_STEP_START 303\n"
printf "303\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "303" || exit 95
printf "after\t303\n" > /probe/work/phase
printf "ASWR_STEP_END 303 "; cat /probe/work/303.json
aswr_boundary 303
printf "async_dependency_wait\t304\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-299.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":299,"before_tool_step":304,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-299.done)" >> /probe/work/async-barriers.jsonl
printf "running\t304\n" > /probe/work/phase
printf "ASWR_STEP_START 304\n"
printf "304\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "304" || exit 95
printf "after\t304\n" > /probe/work/phase
printf "ASWR_STEP_END 304 "; cat /probe/work/304.json
aswr_boundary 304
printf "running\t305\n" > /probe/work/phase
printf "ASWR_STEP_START 305\n"
printf "305\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "305" || exit 95
printf "after\t305\n" > /probe/work/phase
printf "ASWR_STEP_END 305 "; cat /probe/work/305.json
aswr_boundary 305
printf "running\t306\n" > /probe/work/phase
printf "ASWR_STEP_START 306\n"
printf "306\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "306" || exit 95
printf "after\t306\n" > /probe/work/phase
printf "ASWR_STEP_END 306 "; cat /probe/work/306.json
aswr_boundary 306
printf "running\t307\n" > /probe/work/phase
printf "ASWR_STEP_START 307\n"
printf "307\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "307" || exit 95
printf "after\t307\n" > /probe/work/phase
printf "ASWR_STEP_END 307 "; cat /probe/work/307.json
aswr_boundary 307
printf "running\t308\n" > /probe/work/phase
printf "ASWR_STEP_START 308\n"
printf "308\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "308" || exit 95
printf "after\t308\n" > /probe/work/phase
printf "ASWR_STEP_END 308 "; cat /probe/work/308.json
aswr_boundary 308
printf "running\t309\n" > /probe/work/phase
printf "ASWR_STEP_START 309\n"
printf "309\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "309" || exit 95
printf "after\t309\n" > /probe/work/phase
printf "ASWR_STEP_END 309 "; cat /probe/work/309.json
aswr_boundary 309
printf "running\t310\n" > /probe/work/phase
printf "ASWR_STEP_START 310\n"
printf "310\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "310" || exit 95
printf "after\t310\n" > /probe/work/phase
printf "ASWR_STEP_END 310 "; cat /probe/work/310.json
aswr_boundary 310
printf "running\t311\n" > /probe/work/phase
printf "ASWR_STEP_START 311\n"
printf "311\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "311" || exit 95
printf "after\t311\n" > /probe/work/phase
printf "ASWR_STEP_END 311 "; cat /probe/work/311.json
aswr_boundary 311
printf "running\t312\n" > /probe/work/phase
printf "ASWR_STEP_START 312\n"
printf "312\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "312" || exit 95
printf "after\t312\n" > /probe/work/phase
printf "ASWR_STEP_END 312 "; cat /probe/work/312.json
aswr_boundary 312
printf "running\t313\n" > /probe/work/phase
printf "ASWR_STEP_START 313\n"
printf "313\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "313" || exit 95
printf "after\t313\n" > /probe/work/phase
printf "ASWR_STEP_END 313 "; cat /probe/work/313.json
aswr_boundary 313
printf "running\t314\n" > /probe/work/phase
printf "ASWR_STEP_START 314\n"
printf "314\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "314" || exit 95
printf "after\t314\n" > /probe/work/phase
printf "ASWR_STEP_END 314 "; cat /probe/work/314.json
aswr_boundary 314
printf "running\t315\n" > /probe/work/phase
printf "ASWR_STEP_START 315\n"
printf "315\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "315" || exit 95
printf "after\t315\n" > /probe/work/phase
printf "ASWR_STEP_END 315 "; cat /probe/work/315.json
aswr_boundary 315
printf "running\t316\n" > /probe/work/phase
printf "ASWR_STEP_START 316\n"
printf "316\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "316" || exit 95
printf "after\t316\n" > /probe/work/phase
printf "ASWR_STEP_END 316 "; cat /probe/work/316.json
aswr_boundary 316
printf "running\t317\n" > /probe/work/phase
printf "ASWR_STEP_START 317\n"
printf "317\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "317" || exit 95
printf "after\t317\n" > /probe/work/phase
printf "ASWR_STEP_END 317 "; cat /probe/work/317.json
aswr_boundary 317
printf "running\t318\n" > /probe/work/phase
printf "ASWR_STEP_START 318\n"
printf "318\n" >&198
IFS= read -r -t 930 ASWR_ACK <&199 || exit 95
test "$ASWR_ACK" = "318" || exit 95
printf "after\t318\n" > /probe/work/phase
printf "ASWR_STEP_END 318 "; cat /probe/work/318.json
/probe/workload_probe snapshot > /probe/work/final.json
aswr_boundary 318
printf "QUIT\n" >&198
wait "$ASWR_WORKER_PID" || exit 95
exec 198>&- 199>&-
rm -f /probe/work/commands /probe/work/completed
printf "complete\t318\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
