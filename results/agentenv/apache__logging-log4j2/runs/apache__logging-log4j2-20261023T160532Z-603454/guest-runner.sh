#!/bin/bash
set +e
umask 077
mkdir -p /probe/work
printf "baseline\t0\n" > /probe/work/phase
/probe/workload_probe monitor /probe/work &
ASWR_MONITOR_PID=$!
for ASWR_I in {1..100}; do test -f /probe/work/monitor-ready && break; sleep .02; done
test -f /probe/work/monitor-ready || exit 90
/probe/workload_probe snapshot > /probe/work/baseline.json
printf "cache_scan\t0\n" > /probe/work/phase
/probe/workload_probe scan /root/.m2 /root/.sdkman /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 > /probe/work/boundary-000.json
printf "ASWR_READY\n"
cd /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 || exit 91
printf "running\t1\n" > /probe/work/phase
printf "ASWR_STEP_START 1\n"
/probe/workload_probe snapshot > /probe/work/001.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/001.sh > /probe/work/001.stdout 2> /probe/work/001.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/001.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/001.json
printf "after\t1\n" > /probe/work/phase
printf "ASWR_STEP_END 1 "; cat /probe/work/001.json
printf "running\t2\n" > /probe/work/phase
printf "ASWR_STEP_START 2\n"
/probe/workload_probe snapshot > /probe/work/002.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/002.sh > /probe/work/002.stdout 2> /probe/work/002.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/002.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/002.json
printf "after\t2\n" > /probe/work/phase
printf "ASWR_STEP_END 2 "; cat /probe/work/002.json
printf "running\t3\n" > /probe/work/phase
printf "ASWR_STEP_START 3\n"
/probe/workload_probe snapshot > /probe/work/003.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/003.sh > /probe/work/003.stdout 2> /probe/work/003.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/003.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/003.json
printf "after\t3\n" > /probe/work/phase
printf "ASWR_STEP_END 3 "; cat /probe/work/003.json
printf "running\t4\n" > /probe/work/phase
printf "ASWR_STEP_START 4\n"
/probe/workload_probe snapshot > /probe/work/004.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/004.sh > /probe/work/004.stdout 2> /probe/work/004.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/004.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/004.json
printf "after\t4\n" > /probe/work/phase
printf "ASWR_STEP_END 4 "; cat /probe/work/004.json
printf "running\t5\n" > /probe/work/phase
printf "ASWR_STEP_START 5\n"
/probe/workload_probe snapshot > /probe/work/005.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/005.sh > /probe/work/005.stdout 2> /probe/work/005.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/005.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/005.json
printf "after\t5\n" > /probe/work/phase
printf "ASWR_STEP_END 5 "; cat /probe/work/005.json
printf "running\t6\n" > /probe/work/phase
printf "ASWR_STEP_START 6\n"
/probe/workload_probe snapshot > /probe/work/006.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/006.sh > /probe/work/006.stdout 2> /probe/work/006.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/006.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/006.json
printf "after\t6\n" > /probe/work/phase
printf "ASWR_STEP_END 6 "; cat /probe/work/006.json
printf "running\t7\n" > /probe/work/phase
printf "ASWR_STEP_START 7\n"
/probe/workload_probe snapshot > /probe/work/007.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/007.sh > /probe/work/007.stdout 2> /probe/work/007.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/007.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/007.json
printf "after\t7\n" > /probe/work/phase
printf "ASWR_STEP_END 7 "; cat /probe/work/007.json
printf "running\t8\n" > /probe/work/phase
printf "ASWR_STEP_START 8\n"
/probe/workload_probe snapshot > /probe/work/008.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/008.sh > /probe/work/008.stdout 2> /probe/work/008.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/008.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/008.json
printf "after\t8\n" > /probe/work/phase
printf "ASWR_STEP_END 8 "; cat /probe/work/008.json
printf "running\t9\n" > /probe/work/phase
printf "ASWR_STEP_START 9\n"
/probe/workload_probe snapshot > /probe/work/009.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/009.sh > /probe/work/009.stdout 2> /probe/work/009.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/009.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/009.json
printf "after\t9\n" > /probe/work/phase
printf "ASWR_STEP_END 9 "; cat /probe/work/009.json
printf "cache_scan\t9\n" > /probe/work/phase
/probe/workload_probe scan /root/.m2 /root/.sdkman /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 > /probe/work/boundary-009.json
printf "running\t10\n" > /probe/work/phase
printf "ASWR_STEP_START 10\n"
/probe/workload_probe snapshot > /probe/work/010.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/010.sh > /probe/work/010.stdout 2> /probe/work/010.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/010.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/010.json
printf "after\t10\n" > /probe/work/phase
printf "ASWR_STEP_END 10 "; cat /probe/work/010.json
printf "cache_scan\t10\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /root/.m2 /root/.sdkman /data/project/apache__logging-log4j2@204d8251295dfa816b9b28d8d9cfaebab500f415 > /probe/work/boundary-010.json
printf "complete\t10\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
