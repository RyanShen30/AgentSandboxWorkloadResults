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
/probe/workload_probe scan /testbed/node_modules /testbed/build /testbed /root/.cache /usr/local/lib > /probe/work/boundary-000.json
printf "ASWR_READY\n"
printf "running\t1\n" > /probe/work/phase
printf "ASWR_STEP_START 1\n"
/probe/tool_timer /probe/input/001.sh /probe/work/001.json /testbed 900 > /probe/work/001.stdout 2> /probe/work/001.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t1\n" > /probe/work/phase
printf "ASWR_STEP_END 1 "; cat /probe/work/001.json
printf "cache_scan\t1\n" > /probe/work/phase
/probe/workload_probe scan /testbed/node_modules /testbed/build /testbed /root/.cache /usr/local/lib > /probe/work/boundary-001.json
printf "running\t2\n" > /probe/work/phase
printf "ASWR_STEP_START 2\n"
/probe/tool_timer /probe/input/002.sh /probe/work/002.json /testbed 900 > /probe/work/002.stdout 2> /probe/work/002.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t2\n" > /probe/work/phase
printf "ASWR_STEP_END 2 "; cat /probe/work/002.json
printf "running\t3\n" > /probe/work/phase
printf "ASWR_STEP_START 3\n"
/probe/tool_timer /probe/input/003.sh /probe/work/003.json /testbed 900 > /probe/work/003.stdout 2> /probe/work/003.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t3\n" > /probe/work/phase
printf "ASWR_STEP_END 3 "; cat /probe/work/003.json
printf "running\t4\n" > /probe/work/phase
printf "ASWR_STEP_START 4\n"
/probe/tool_timer /probe/input/004.sh /probe/work/004.json /testbed 900 > /probe/work/004.stdout 2> /probe/work/004.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t4\n" > /probe/work/phase
printf "ASWR_STEP_END 4 "; cat /probe/work/004.json
printf "running\t5\n" > /probe/work/phase
printf "ASWR_STEP_START 5\n"
/probe/tool_timer /probe/input/005.sh /probe/work/005.json /testbed 900 > /probe/work/005.stdout 2> /probe/work/005.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t5\n" > /probe/work/phase
printf "ASWR_STEP_END 5 "; cat /probe/work/005.json
printf "cache_scan\t5\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /testbed/node_modules /testbed/build /testbed /root/.cache /usr/local/lib > /probe/work/boundary-005.json
printf "complete\t5\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
