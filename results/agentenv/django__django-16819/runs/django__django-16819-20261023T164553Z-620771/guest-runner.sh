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
/probe/workload_probe scan /testbed /opt/conda /opt/miniconda3 > /probe/work/boundary-000.json
printf "ASWR_READY\n"
cd /testbed || exit 91
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
printf "running\t11\n" > /probe/work/phase
printf "ASWR_STEP_START 11\n"
/probe/workload_probe snapshot > /probe/work/011.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/011.sh > /probe/work/011.stdout 2> /probe/work/011.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/011.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/011.json
printf "after\t11\n" > /probe/work/phase
printf "ASWR_STEP_END 11 "; cat /probe/work/011.json
printf "running\t12\n" > /probe/work/phase
printf "ASWR_STEP_START 12\n"
/probe/workload_probe snapshot > /probe/work/012.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/012.sh > /probe/work/012.stdout 2> /probe/work/012.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/012.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/012.json
printf "after\t12\n" > /probe/work/phase
printf "ASWR_STEP_END 12 "; cat /probe/work/012.json
printf "running\t13\n" > /probe/work/phase
printf "ASWR_STEP_START 13\n"
/probe/workload_probe snapshot > /probe/work/013.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/013.sh > /probe/work/013.stdout 2> /probe/work/013.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/013.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/013.json
printf "after\t13\n" > /probe/work/phase
printf "ASWR_STEP_END 13 "; cat /probe/work/013.json
printf "running\t14\n" > /probe/work/phase
printf "ASWR_STEP_START 14\n"
/probe/workload_probe snapshot > /probe/work/014.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/014.sh > /probe/work/014.stdout 2> /probe/work/014.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/014.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/014.json
printf "after\t14\n" > /probe/work/phase
printf "ASWR_STEP_END 14 "; cat /probe/work/014.json
printf "cache_scan\t14\n" > /probe/work/phase
/probe/workload_probe scan /testbed /opt/conda /opt/miniconda3 > /probe/work/boundary-014.json
printf "running\t15\n" > /probe/work/phase
printf "ASWR_STEP_START 15\n"
/probe/workload_probe snapshot > /probe/work/015.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/015.sh > /probe/work/015.stdout 2> /probe/work/015.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/015.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/015.json
printf "after\t15\n" > /probe/work/phase
printf "ASWR_STEP_END 15 "; cat /probe/work/015.json
printf "running\t16\n" > /probe/work/phase
printf "ASWR_STEP_START 16\n"
/probe/workload_probe snapshot > /probe/work/016.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/016.sh > /probe/work/016.stdout 2> /probe/work/016.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/016.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/016.json
printf "after\t16\n" > /probe/work/phase
printf "ASWR_STEP_END 16 "; cat /probe/work/016.json
printf "running\t17\n" > /probe/work/phase
printf "ASWR_STEP_START 17\n"
/probe/workload_probe snapshot > /probe/work/017.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/017.sh > /probe/work/017.stdout 2> /probe/work/017.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/017.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/017.json
printf "after\t17\n" > /probe/work/phase
printf "ASWR_STEP_END 17 "; cat /probe/work/017.json
printf "running\t18\n" > /probe/work/phase
printf "ASWR_STEP_START 18\n"
/probe/workload_probe snapshot > /probe/work/018.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/018.sh > /probe/work/018.stdout 2> /probe/work/018.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/018.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/018.json
printf "after\t18\n" > /probe/work/phase
printf "ASWR_STEP_END 18 "; cat /probe/work/018.json
printf "running\t19\n" > /probe/work/phase
printf "ASWR_STEP_START 19\n"
/probe/workload_probe snapshot > /probe/work/019.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/019.sh > /probe/work/019.stdout 2> /probe/work/019.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/019.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/019.json
printf "after\t19\n" > /probe/work/phase
printf "ASWR_STEP_END 19 "; cat /probe/work/019.json
printf "running\t20\n" > /probe/work/phase
printf "ASWR_STEP_START 20\n"
/probe/workload_probe snapshot > /probe/work/020.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/020.sh > /probe/work/020.stdout 2> /probe/work/020.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/020.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/020.json
printf "after\t20\n" > /probe/work/phase
printf "ASWR_STEP_END 20 "; cat /probe/work/020.json
printf "running\t21\n" > /probe/work/phase
printf "ASWR_STEP_START 21\n"
/probe/workload_probe snapshot > /probe/work/021.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/021.sh > /probe/work/021.stdout 2> /probe/work/021.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/021.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/021.json
printf "after\t21\n" > /probe/work/phase
printf "ASWR_STEP_END 21 "; cat /probe/work/021.json
printf "running\t22\n" > /probe/work/phase
printf "ASWR_STEP_START 22\n"
/probe/workload_probe snapshot > /probe/work/022.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/022.sh > /probe/work/022.stdout 2> /probe/work/022.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/022.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/022.json
printf "after\t22\n" > /probe/work/phase
printf "ASWR_STEP_END 22 "; cat /probe/work/022.json
printf "running\t23\n" > /probe/work/phase
printf "ASWR_STEP_START 23\n"
/probe/workload_probe snapshot > /probe/work/023.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/023.sh > /probe/work/023.stdout 2> /probe/work/023.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/023.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/023.json
printf "after\t23\n" > /probe/work/phase
printf "ASWR_STEP_END 23 "; cat /probe/work/023.json
printf "running\t24\n" > /probe/work/phase
printf "ASWR_STEP_START 24\n"
/probe/workload_probe snapshot > /probe/work/024.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/024.sh > /probe/work/024.stdout 2> /probe/work/024.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/024.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/024.json
printf "after\t24\n" > /probe/work/phase
printf "ASWR_STEP_END 24 "; cat /probe/work/024.json
printf "running\t25\n" > /probe/work/phase
printf "ASWR_STEP_START 25\n"
/probe/workload_probe snapshot > /probe/work/025.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/025.sh > /probe/work/025.stdout 2> /probe/work/025.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/025.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/025.json
printf "after\t25\n" > /probe/work/phase
printf "ASWR_STEP_END 25 "; cat /probe/work/025.json
printf "running\t26\n" > /probe/work/phase
printf "ASWR_STEP_START 26\n"
/probe/workload_probe snapshot > /probe/work/026.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/026.sh > /probe/work/026.stdout 2> /probe/work/026.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/026.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/026.json
printf "after\t26\n" > /probe/work/phase
printf "ASWR_STEP_END 26 "; cat /probe/work/026.json
printf "running\t27\n" > /probe/work/phase
printf "ASWR_STEP_START 27\n"
/probe/workload_probe snapshot > /probe/work/027.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/027.sh > /probe/work/027.stdout 2> /probe/work/027.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/027.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/027.json
printf "after\t27\n" > /probe/work/phase
printf "ASWR_STEP_END 27 "; cat /probe/work/027.json
printf "running\t28\n" > /probe/work/phase
printf "ASWR_STEP_START 28\n"
/probe/workload_probe snapshot > /probe/work/028.before.json
ASWR_STARTED=$(/probe/clock_ns)
source /probe/input/028.sh > /probe/work/028.stdout 2> /probe/work/028.stderr
ASWR_EXIT=$?
ASWR_FINISHED=$(/probe/clock_ns)
/probe/workload_probe snapshot > /probe/work/028.after.json
printf '{"started_ns":%s,"finished_ns":%s,"exit_code":%s,"timed_out":false}\n' "$ASWR_STARTED" "$ASWR_FINISHED" "$ASWR_EXIT" > /probe/work/028.json
printf "after\t28\n" > /probe/work/phase
printf "ASWR_STEP_END 28 "; cat /probe/work/028.json
printf "cache_scan\t28\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /testbed /opt/conda /opt/miniconda3 > /probe/work/boundary-028.json
printf "complete\t28\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
