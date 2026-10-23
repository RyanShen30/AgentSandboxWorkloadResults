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
/probe/workload_probe scan /app /root/.cache /usr/local/lib > /probe/work/boundary-000.json
printf "ASWR_READY\n"
printf "running\t1\n" > /probe/work/phase
printf "ASWR_STEP_START 1\n"
/probe/tool_timer /probe/input/001.sh /probe/work/001.json /app 900 > /probe/work/001.stdout 2> /probe/work/001.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t1\n" > /probe/work/phase
printf "ASWR_STEP_END 1 "; cat /probe/work/001.json
printf "cache_scan\t1\n" > /probe/work/phase
/probe/workload_probe scan /app /root/.cache /usr/local/lib > /probe/work/boundary-001.json
printf "running\t2\n" > /probe/work/phase
printf "ASWR_STEP_START 2\n"
/probe/tool_timer /probe/input/002.sh /probe/work/002.json /app 900 > /probe/work/002.stdout 2> /probe/work/002.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t2\n" > /probe/work/phase
printf "ASWR_STEP_END 2 "; cat /probe/work/002.json
printf "running\t3\n" > /probe/work/phase
printf "ASWR_STEP_START 3\n"
/probe/tool_timer /probe/input/003.sh /probe/work/003.json /app 900 > /probe/work/003.stdout 2> /probe/work/003.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t3\n" > /probe/work/phase
printf "ASWR_STEP_END 3 "; cat /probe/work/003.json
printf "running\t4\n" > /probe/work/phase
printf "ASWR_STEP_START 4\n"
/probe/tool_timer /probe/input/004.sh /probe/work/004.json /app 900 > /probe/work/004.stdout 2> /probe/work/004.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t4\n" > /probe/work/phase
printf "ASWR_STEP_END 4 "; cat /probe/work/004.json
printf "running\t5\n" > /probe/work/phase
printf "ASWR_STEP_START 5\n"
/probe/tool_timer /probe/input/005.sh /probe/work/005.json /app 900 > /probe/work/005.stdout 2> /probe/work/005.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t5\n" > /probe/work/phase
printf "ASWR_STEP_END 5 "; cat /probe/work/005.json
printf "running\t6\n" > /probe/work/phase
printf "ASWR_STEP_START 6\n"
/probe/tool_timer /probe/input/006.sh /probe/work/006.json /app 900 > /probe/work/006.stdout 2> /probe/work/006.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t6\n" > /probe/work/phase
printf "ASWR_STEP_END 6 "; cat /probe/work/006.json
printf "running\t7\n" > /probe/work/phase
printf "ASWR_STEP_START 7\n"
/probe/tool_timer /probe/input/007.sh /probe/work/007.json /app 900 > /probe/work/007.stdout 2> /probe/work/007.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t7\n" > /probe/work/phase
printf "ASWR_STEP_END 7 "; cat /probe/work/007.json
printf "running\t8\n" > /probe/work/phase
printf "ASWR_STEP_START 8\n"
/probe/tool_timer /probe/input/008.sh /probe/work/008.json /app 900 > /probe/work/008.stdout 2> /probe/work/008.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t8\n" > /probe/work/phase
printf "ASWR_STEP_END 8 "; cat /probe/work/008.json
printf "running\t9\n" > /probe/work/phase
printf "ASWR_STEP_START 9\n"
/probe/tool_timer /probe/input/009.sh /probe/work/009.json /app 900 > /probe/work/009.stdout 2> /probe/work/009.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t9\n" > /probe/work/phase
printf "ASWR_STEP_END 9 "; cat /probe/work/009.json
printf "running\t10\n" > /probe/work/phase
printf "ASWR_STEP_START 10\n"
/probe/tool_timer /probe/input/010.sh /probe/work/010.json /app 900 > /probe/work/010.stdout 2> /probe/work/010.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t10\n" > /probe/work/phase
printf "ASWR_STEP_END 10 "; cat /probe/work/010.json
printf "running\t11\n" > /probe/work/phase
printf "ASWR_STEP_START 11\n"
/probe/tool_timer /probe/input/011.sh /probe/work/011.json /app 900 > /probe/work/011.stdout 2> /probe/work/011.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t11\n" > /probe/work/phase
printf "ASWR_STEP_END 11 "; cat /probe/work/011.json
printf "running\t12\n" > /probe/work/phase
printf "ASWR_STEP_START 12\n"
/probe/tool_timer /probe/input/012.sh /probe/work/012.json /app 900 > /probe/work/012.stdout 2> /probe/work/012.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t12\n" > /probe/work/phase
printf "ASWR_STEP_END 12 "; cat /probe/work/012.json
printf "running\t13\n" > /probe/work/phase
printf "ASWR_STEP_START 13\n"
/probe/tool_timer /probe/input/013.sh /probe/work/013.json /app 900 > /probe/work/013.stdout 2> /probe/work/013.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t13\n" > /probe/work/phase
printf "ASWR_STEP_END 13 "; cat /probe/work/013.json
printf "running\t14\n" > /probe/work/phase
printf "ASWR_STEP_START 14\n"
/probe/tool_timer /probe/input/014.sh /probe/work/014.json /app 900 > /probe/work/014.stdout 2> /probe/work/014.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t14\n" > /probe/work/phase
printf "ASWR_STEP_END 14 "; cat /probe/work/014.json
printf "running\t15\n" > /probe/work/phase
printf "ASWR_STEP_START 15\n"
/probe/tool_timer /probe/input/015.sh /probe/work/015.json /app 900 > /probe/work/015.stdout 2> /probe/work/015.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t15\n" > /probe/work/phase
printf "ASWR_STEP_END 15 "; cat /probe/work/015.json
printf "running\t16\n" > /probe/work/phase
printf "ASWR_STEP_START 16\n"
/probe/tool_timer /probe/input/016.sh /probe/work/016.json /app 900 > /probe/work/016.stdout 2> /probe/work/016.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t16\n" > /probe/work/phase
printf "ASWR_STEP_END 16 "; cat /probe/work/016.json
printf "cache_scan\t16\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /app /root/.cache /usr/local/lib > /probe/work/boundary-016.json
printf "complete\t16\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
