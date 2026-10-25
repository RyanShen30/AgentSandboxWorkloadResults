#!/bin/bash
set +e
umask 077
cd /testbed || exit 91
touch /probe/work/worker-ready
while IFS= read -r ASWR_STEP <&198; do
case "$ASWR_STEP" in
QUIT) exit 0 ;;
1)
/probe/workload_probe snapshot > /probe/work/001.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/001.sh > /probe/work/001.stdout 2> /probe/work/001.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/001.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/001.json
printf "1\n" >&199
;;
2)
/probe/workload_probe snapshot > /probe/work/002.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/002.sh > /probe/work/002.stdout 2> /probe/work/002.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/002.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/002.json
printf "2\n" >&199
;;
3)
/probe/workload_probe snapshot > /probe/work/003.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/003.sh > /probe/work/003.stdout 2> /probe/work/003.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/003.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/003.json
printf "3\n" >&199
;;
4)
/probe/workload_probe snapshot > /probe/work/004.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/004.sh > /probe/work/004.stdout 2> /probe/work/004.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/004.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/004.json
printf "4\n" >&199
;;
5)
/probe/workload_probe snapshot > /probe/work/005.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/005.sh > /probe/work/005.stdout 2> /probe/work/005.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/005.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/005.json
printf "5\n" >&199
;;
6)
/probe/workload_probe snapshot > /probe/work/006.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/006.sh > /probe/work/006.stdout 2> /probe/work/006.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/006.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/006.json
printf "6\n" >&199
;;
7)
/probe/workload_probe snapshot > /probe/work/007.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/007.sh > /probe/work/007.stdout 2> /probe/work/007.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/007.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/007.json
printf "7\n" >&199
;;
8)
/probe/workload_probe snapshot > /probe/work/008.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/008.sh > /probe/work/008.stdout 2> /probe/work/008.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/008.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/008.json
printf "8\n" >&199
;;
9)
/probe/workload_probe snapshot > /probe/work/009.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/009.sh > /probe/work/009.stdout 2> /probe/work/009.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/009.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/009.json
printf "9\n" >&199
;;
10)
/probe/workload_probe snapshot > /probe/work/010.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/010.sh > /probe/work/010.stdout 2> /probe/work/010.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/010.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/010.json
printf "10\n" >&199
;;
11)
/probe/workload_probe snapshot > /probe/work/011.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/011.sh > /probe/work/011.stdout 2> /probe/work/011.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/011.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/011.json
printf "11\n" >&199
;;
12)
/probe/workload_probe snapshot > /probe/work/012.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/012.sh > /probe/work/012.stdout 2> /probe/work/012.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/012.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/012.json
printf "12\n" >&199
;;
13)
/probe/workload_probe snapshot > /probe/work/013.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/013.sh > /probe/work/013.stdout 2> /probe/work/013.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/013.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/013.json
printf "13\n" >&199
;;
14)
/probe/workload_probe snapshot > /probe/work/014.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/014.sh > /probe/work/014.stdout 2> /probe/work/014.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/014.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/014.json
printf "14\n" >&199
;;
15)
/probe/workload_probe snapshot > /probe/work/015.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/015.sh > /probe/work/015.stdout 2> /probe/work/015.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/015.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/015.json
printf "15\n" >&199
;;
16)
/probe/workload_probe snapshot > /probe/work/016.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/016.sh > /probe/work/016.stdout 2> /probe/work/016.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/016.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/016.json
printf "16\n" >&199
;;
17)
/probe/workload_probe snapshot > /probe/work/017.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/017.sh > /probe/work/017.stdout 2> /probe/work/017.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/017.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/017.json
printf "17\n" >&199
;;
18)
/probe/workload_probe snapshot > /probe/work/018.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/018.sh > /probe/work/018.stdout 2> /probe/work/018.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/018.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/018.json
printf "18\n" >&199
;;
19)
/probe/workload_probe snapshot > /probe/work/019.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/019.sh > /probe/work/019.stdout 2> /probe/work/019.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/019.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/019.json
printf "19\n" >&199
;;
20)
/probe/workload_probe snapshot > /probe/work/020.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/020.sh > /probe/work/020.stdout 2> /probe/work/020.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/020.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/020.json
printf "20\n" >&199
;;
21)
/probe/workload_probe snapshot > /probe/work/021.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/021.sh > /probe/work/021.stdout 2> /probe/work/021.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/021.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/021.json
printf "21\n" >&199
;;
22)
/probe/workload_probe snapshot > /probe/work/022.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/022.sh > /probe/work/022.stdout 2> /probe/work/022.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/022.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/022.json
printf "22\n" >&199
;;
23)
/probe/workload_probe snapshot > /probe/work/023.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/023.sh > /probe/work/023.stdout 2> /probe/work/023.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/023.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/023.json
printf "23\n" >&199
;;
24)
/probe/workload_probe snapshot > /probe/work/024.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/024.sh > /probe/work/024.stdout 2> /probe/work/024.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/024.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/024.json
printf "24\n" >&199
;;
25)
/probe/workload_probe snapshot > /probe/work/025.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/025.sh > /probe/work/025.stdout 2> /probe/work/025.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/025.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/025.json
printf "25\n" >&199
;;
26)
/probe/workload_probe snapshot > /probe/work/026.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/026.sh > /probe/work/026.stdout 2> /probe/work/026.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/026.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/026.json
printf "26\n" >&199
;;
27)
/probe/workload_probe snapshot > /probe/work/027.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/027.sh > /probe/work/027.stdout 2> /probe/work/027.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/027.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/027.json
printf "27\n" >&199
;;
28)
/probe/workload_probe snapshot > /probe/work/028.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/028.sh > /probe/work/028.stdout 2> /probe/work/028.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/028.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/028.json
printf "28\n" >&199
;;
*) exit 96 ;;
esac
done
exit 97
