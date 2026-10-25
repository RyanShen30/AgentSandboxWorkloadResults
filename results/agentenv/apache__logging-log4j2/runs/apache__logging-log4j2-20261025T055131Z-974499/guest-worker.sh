#!/bin/bash
set +e
umask 077
cd /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 || exit 91
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
*) exit 96 ;;
esac
done
exit 97
