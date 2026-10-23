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
/probe/workload_probe scan /tmp/CompCert /tmp/coq-8.16.1 /usr/local/lib /app > /probe/work/boundary-000.json
printf "ASWR_READY\n"
printf "running\t1\n" > /probe/work/phase
printf "ASWR_STEP_START 1\n"
/probe/tool_timer /probe/input/001.sh /probe/work/001.json /app 900 > /probe/work/001.stdout 2> /probe/work/001.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t1\n" > /probe/work/phase
printf "ASWR_STEP_END 1 "; cat /probe/work/001.json
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
printf "running\t17\n" > /probe/work/phase
printf "ASWR_STEP_START 17\n"
/probe/tool_timer /probe/input/017.sh /probe/work/017.json /app 900 > /probe/work/017.stdout 2> /probe/work/017.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t17\n" > /probe/work/phase
printf "ASWR_STEP_END 17 "; cat /probe/work/017.json
printf "running\t18\n" > /probe/work/phase
printf "ASWR_STEP_START 18\n"
/probe/tool_timer /probe/input/018.sh /probe/work/018.json /app 900 > /probe/work/018.stdout 2> /probe/work/018.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t18\n" > /probe/work/phase
printf "ASWR_STEP_END 18 "; cat /probe/work/018.json
printf "running\t19\n" > /probe/work/phase
printf "ASWR_STEP_START 19\n"
/probe/tool_timer /probe/input/019.sh /probe/work/019.json /app 900 > /probe/work/019.stdout 2> /probe/work/019.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t19\n" > /probe/work/phase
printf "ASWR_STEP_END 19 "; cat /probe/work/019.json
printf "running\t20\n" > /probe/work/phase
printf "ASWR_STEP_START 20\n"
/probe/tool_timer /probe/input/020.sh /probe/work/020.json /app 900 > /probe/work/020.stdout 2> /probe/work/020.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t20\n" > /probe/work/phase
printf "ASWR_STEP_END 20 "; cat /probe/work/020.json
printf "running\t21\n" > /probe/work/phase
printf "ASWR_STEP_START 21\n"
/probe/tool_timer /probe/input/021.sh /probe/work/021.json /app 900 > /probe/work/021.stdout 2> /probe/work/021.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t21\n" > /probe/work/phase
printf "ASWR_STEP_END 21 "; cat /probe/work/021.json
printf "running\t22\n" > /probe/work/phase
printf "ASWR_STEP_START 22\n"
/probe/tool_timer /probe/input/022.sh /probe/work/022.json /app 900 > /probe/work/022.stdout 2> /probe/work/022.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t22\n" > /probe/work/phase
printf "ASWR_STEP_END 22 "; cat /probe/work/022.json
printf "running\t23\n" > /probe/work/phase
printf "ASWR_STEP_START 23\n"
/probe/tool_timer /probe/input/023.sh /probe/work/023.json /app 900 > /probe/work/023.stdout 2> /probe/work/023.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t23\n" > /probe/work/phase
printf "ASWR_STEP_END 23 "; cat /probe/work/023.json
printf "running\t24\n" > /probe/work/phase
printf "ASWR_STEP_START 24\n"
/probe/tool_timer /probe/input/024.sh /probe/work/024.json /app 900 > /probe/work/024.stdout 2> /probe/work/024.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t24\n" > /probe/work/phase
printf "ASWR_STEP_END 24 "; cat /probe/work/024.json
printf "running\t25\n" > /probe/work/phase
printf "ASWR_STEP_START 25\n"
/probe/tool_timer /probe/input/025.sh /probe/work/025.json /app 900 > /probe/work/025.stdout 2> /probe/work/025.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t25\n" > /probe/work/phase
printf "ASWR_STEP_END 25 "; cat /probe/work/025.json
printf "running\t26\n" > /probe/work/phase
printf "ASWR_STEP_START 26\n"
/probe/tool_timer /probe/input/026.sh /probe/work/026.json /app 900 > /probe/work/026.stdout 2> /probe/work/026.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t26\n" > /probe/work/phase
printf "ASWR_STEP_END 26 "; cat /probe/work/026.json
printf "running\t27\n" > /probe/work/phase
printf "ASWR_STEP_START 27\n"
/probe/tool_timer /probe/input/027.sh /probe/work/027.json /app 900 > /probe/work/027.stdout 2> /probe/work/027.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t27\n" > /probe/work/phase
printf "ASWR_STEP_END 27 "; cat /probe/work/027.json
printf "running\t28\n" > /probe/work/phase
printf "ASWR_STEP_START 28\n"
/probe/tool_timer /probe/input/028.sh /probe/work/028.json /app 900 > /probe/work/028.stdout 2> /probe/work/028.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t28\n" > /probe/work/phase
printf "ASWR_STEP_END 28 "; cat /probe/work/028.json
printf "running\t29\n" > /probe/work/phase
printf "ASWR_STEP_START 29\n"
/probe/tool_timer /probe/input/029.sh /probe/work/029.json /app 900 > /probe/work/029.stdout 2> /probe/work/029.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t29\n" > /probe/work/phase
printf "ASWR_STEP_END 29 "; cat /probe/work/029.json
printf "running\t30\n" > /probe/work/phase
printf "ASWR_STEP_START 30\n"
/probe/tool_timer /probe/input/030.sh /probe/work/030.json /app 900 > /probe/work/030.stdout 2> /probe/work/030.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t30\n" > /probe/work/phase
printf "ASWR_STEP_END 30 "; cat /probe/work/030.json
printf "running\t31\n" > /probe/work/phase
printf "ASWR_STEP_START 31\n"
/probe/tool_timer /probe/input/031.sh /probe/work/031.json /app 900 > /probe/work/031.stdout 2> /probe/work/031.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t31\n" > /probe/work/phase
printf "ASWR_STEP_END 31 "; cat /probe/work/031.json
printf "running\t32\n" > /probe/work/phase
printf "ASWR_STEP_START 32\n"
/probe/tool_timer /probe/input/032.sh /probe/work/032.json /app 900 > /probe/work/032.stdout 2> /probe/work/032.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t32\n" > /probe/work/phase
printf "ASWR_STEP_END 32 "; cat /probe/work/032.json
printf "running\t33\n" > /probe/work/phase
printf "ASWR_STEP_START 33\n"
/probe/tool_timer /probe/input/033.sh /probe/work/033.json /app 900 > /probe/work/033.stdout 2> /probe/work/033.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t33\n" > /probe/work/phase
printf "ASWR_STEP_END 33 "; cat /probe/work/033.json
printf "running\t34\n" > /probe/work/phase
printf "ASWR_STEP_START 34\n"
/probe/tool_timer /probe/input/034.sh /probe/work/034.json /app 900 > /probe/work/034.stdout 2> /probe/work/034.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t34\n" > /probe/work/phase
printf "ASWR_STEP_END 34 "; cat /probe/work/034.json
printf "running\t35\n" > /probe/work/phase
printf "ASWR_STEP_START 35\n"
/probe/tool_timer /probe/input/035.sh /probe/work/035.json /app 900 > /probe/work/035.stdout 2> /probe/work/035.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t35\n" > /probe/work/phase
printf "ASWR_STEP_END 35 "; cat /probe/work/035.json
printf "running\t36\n" > /probe/work/phase
printf "ASWR_STEP_START 36\n"
/probe/tool_timer /probe/input/036.sh /probe/work/036.json /app 900 > /probe/work/036.stdout 2> /probe/work/036.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t36\n" > /probe/work/phase
printf "ASWR_STEP_END 36 "; cat /probe/work/036.json
printf "running\t37\n" > /probe/work/phase
printf "ASWR_STEP_START 37\n"
/probe/tool_timer /probe/input/037.sh /probe/work/037.json /app 900 > /probe/work/037.stdout 2> /probe/work/037.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t37\n" > /probe/work/phase
printf "ASWR_STEP_END 37 "; cat /probe/work/037.json
printf "running\t38\n" > /probe/work/phase
printf "ASWR_STEP_START 38\n"
/probe/tool_timer /probe/input/038.sh /probe/work/038.json /app 900 > /probe/work/038.stdout 2> /probe/work/038.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t38\n" > /probe/work/phase
printf "ASWR_STEP_END 38 "; cat /probe/work/038.json
printf "running\t39\n" > /probe/work/phase
printf "ASWR_STEP_START 39\n"
/probe/tool_timer /probe/input/039.sh /probe/work/039.json /app 900 > /probe/work/039.stdout 2> /probe/work/039.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t39\n" > /probe/work/phase
printf "ASWR_STEP_END 39 "; cat /probe/work/039.json
printf "running\t40\n" > /probe/work/phase
printf "ASWR_STEP_START 40\n"
/probe/tool_timer /probe/input/040.sh /probe/work/040.json /app 900 > /probe/work/040.stdout 2> /probe/work/040.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t40\n" > /probe/work/phase
printf "ASWR_STEP_END 40 "; cat /probe/work/040.json
printf "running\t41\n" > /probe/work/phase
printf "ASWR_STEP_START 41\n"
/probe/tool_timer /probe/input/041.sh /probe/work/041.json /app 900 > /probe/work/041.stdout 2> /probe/work/041.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t41\n" > /probe/work/phase
printf "ASWR_STEP_END 41 "; cat /probe/work/041.json
printf "running\t42\n" > /probe/work/phase
printf "ASWR_STEP_START 42\n"
/probe/tool_timer /probe/input/042.sh /probe/work/042.json /app 900 > /probe/work/042.stdout 2> /probe/work/042.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t42\n" > /probe/work/phase
printf "ASWR_STEP_END 42 "; cat /probe/work/042.json
printf "running\t43\n" > /probe/work/phase
printf "ASWR_STEP_START 43\n"
/probe/tool_timer /probe/input/043.sh /probe/work/043.json /app 900 > /probe/work/043.stdout 2> /probe/work/043.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t43\n" > /probe/work/phase
printf "ASWR_STEP_END 43 "; cat /probe/work/043.json
printf "running\t44\n" > /probe/work/phase
printf "ASWR_STEP_START 44\n"
/probe/tool_timer /probe/input/044.sh /probe/work/044.json /app 1800 > /probe/work/044.stdout 2> /probe/work/044.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t44\n" > /probe/work/phase
printf "ASWR_STEP_END 44 "; cat /probe/work/044.json
printf "running\t45\n" > /probe/work/phase
printf "ASWR_STEP_START 45\n"
/probe/tool_timer /probe/input/045.sh /probe/work/045.json /app 1800 > /probe/work/045.stdout 2> /probe/work/045.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t45\n" > /probe/work/phase
printf "ASWR_STEP_END 45 "; cat /probe/work/045.json
printf "running\t46\n" > /probe/work/phase
printf "ASWR_STEP_START 46\n"
/probe/tool_timer /probe/input/046.sh /probe/work/046.json /app 900 > /probe/work/046.stdout 2> /probe/work/046.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t46\n" > /probe/work/phase
printf "ASWR_STEP_END 46 "; cat /probe/work/046.json
printf "running\t47\n" > /probe/work/phase
printf "ASWR_STEP_START 47\n"
/probe/tool_timer /probe/input/047.sh /probe/work/047.json /app 900 > /probe/work/047.stdout 2> /probe/work/047.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t47\n" > /probe/work/phase
printf "ASWR_STEP_END 47 "; cat /probe/work/047.json
printf "running\t48\n" > /probe/work/phase
printf "ASWR_STEP_START 48\n"
/probe/tool_timer /probe/input/048.sh /probe/work/048.json /app 900 > /probe/work/048.stdout 2> /probe/work/048.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t48\n" > /probe/work/phase
printf "ASWR_STEP_END 48 "; cat /probe/work/048.json
printf "running\t49\n" > /probe/work/phase
printf "ASWR_STEP_START 49\n"
/probe/tool_timer /probe/input/049.sh /probe/work/049.json /app 900 > /probe/work/049.stdout 2> /probe/work/049.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t49\n" > /probe/work/phase
printf "ASWR_STEP_END 49 "; cat /probe/work/049.json
printf "running\t50\n" > /probe/work/phase
printf "ASWR_STEP_START 50\n"
/probe/tool_timer /probe/input/050.sh /probe/work/050.json /app 900 > /probe/work/050.stdout 2> /probe/work/050.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t50\n" > /probe/work/phase
printf "ASWR_STEP_END 50 "; cat /probe/work/050.json
printf "running\t51\n" > /probe/work/phase
printf "ASWR_STEP_START 51\n"
/probe/tool_timer /probe/input/051.sh /probe/work/051.json /app 900 > /probe/work/051.stdout 2> /probe/work/051.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t51\n" > /probe/work/phase
printf "ASWR_STEP_END 51 "; cat /probe/work/051.json
printf "running\t52\n" > /probe/work/phase
printf "ASWR_STEP_START 52\n"
/probe/tool_timer /probe/input/052.sh /probe/work/052.json /app 900 > /probe/work/052.stdout 2> /probe/work/052.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t52\n" > /probe/work/phase
printf "ASWR_STEP_END 52 "; cat /probe/work/052.json
printf "running\t53\n" > /probe/work/phase
printf "ASWR_STEP_START 53\n"
/probe/tool_timer /probe/input/053.sh /probe/work/053.json /app 900 > /probe/work/053.stdout 2> /probe/work/053.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t53\n" > /probe/work/phase
printf "ASWR_STEP_END 53 "; cat /probe/work/053.json
printf "running\t54\n" > /probe/work/phase
printf "ASWR_STEP_START 54\n"
/probe/tool_timer /probe/input/054.sh /probe/work/054.json /app 900 > /probe/work/054.stdout 2> /probe/work/054.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t54\n" > /probe/work/phase
printf "ASWR_STEP_END 54 "; cat /probe/work/054.json
printf "running\t55\n" > /probe/work/phase
printf "ASWR_STEP_START 55\n"
/probe/tool_timer /probe/input/055.sh /probe/work/055.json /app 900 > /probe/work/055.stdout 2> /probe/work/055.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t55\n" > /probe/work/phase
printf "ASWR_STEP_END 55 "; cat /probe/work/055.json
printf "running\t56\n" > /probe/work/phase
printf "ASWR_STEP_START 56\n"
/probe/tool_timer /probe/input/056.sh /probe/work/056.json /app 900 > /probe/work/056.stdout 2> /probe/work/056.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t56\n" > /probe/work/phase
printf "ASWR_STEP_END 56 "; cat /probe/work/056.json
printf "running\t57\n" > /probe/work/phase
printf "ASWR_STEP_START 57\n"
/probe/tool_timer /probe/input/057.sh /probe/work/057.json /app 900 > /probe/work/057.stdout 2> /probe/work/057.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t57\n" > /probe/work/phase
printf "ASWR_STEP_END 57 "; cat /probe/work/057.json
printf "running\t58\n" > /probe/work/phase
printf "ASWR_STEP_START 58\n"
/probe/tool_timer /probe/input/058.sh /probe/work/058.json /app 900 > /probe/work/058.stdout 2> /probe/work/058.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t58\n" > /probe/work/phase
printf "ASWR_STEP_END 58 "; cat /probe/work/058.json
printf "running\t59\n" > /probe/work/phase
printf "ASWR_STEP_START 59\n"
/probe/tool_timer /probe/input/059.sh /probe/work/059.json /app 900 > /probe/work/059.stdout 2> /probe/work/059.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t59\n" > /probe/work/phase
printf "ASWR_STEP_END 59 "; cat /probe/work/059.json
printf "running\t60\n" > /probe/work/phase
printf "ASWR_STEP_START 60\n"
/probe/tool_timer /probe/input/060.sh /probe/work/060.json /app 900 > /probe/work/060.stdout 2> /probe/work/060.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t60\n" > /probe/work/phase
printf "ASWR_STEP_END 60 "; cat /probe/work/060.json
printf "running\t61\n" > /probe/work/phase
printf "ASWR_STEP_START 61\n"
/probe/tool_timer /probe/input/061.sh /probe/work/061.json /app 900 > /probe/work/061.stdout 2> /probe/work/061.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t61\n" > /probe/work/phase
printf "ASWR_STEP_END 61 "; cat /probe/work/061.json
printf "running\t62\n" > /probe/work/phase
printf "ASWR_STEP_START 62\n"
/probe/tool_timer /probe/input/062.sh /probe/work/062.json /app 900 > /probe/work/062.stdout 2> /probe/work/062.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t62\n" > /probe/work/phase
printf "ASWR_STEP_END 62 "; cat /probe/work/062.json
printf "running\t63\n" > /probe/work/phase
printf "ASWR_STEP_START 63\n"
/probe/tool_timer /probe/input/063.sh /probe/work/063.json /app 900 > /probe/work/063.stdout 2> /probe/work/063.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t63\n" > /probe/work/phase
printf "ASWR_STEP_END 63 "; cat /probe/work/063.json
printf "running\t64\n" > /probe/work/phase
printf "ASWR_STEP_START 64\n"
/probe/tool_timer /probe/input/064.sh /probe/work/064.json /app 900 > /probe/work/064.stdout 2> /probe/work/064.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t64\n" > /probe/work/phase
printf "ASWR_STEP_END 64 "; cat /probe/work/064.json
printf "running\t65\n" > /probe/work/phase
printf "ASWR_STEP_START 65\n"
/probe/tool_timer /probe/input/065.sh /probe/work/065.json /app 900 > /probe/work/065.stdout 2> /probe/work/065.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t65\n" > /probe/work/phase
printf "ASWR_STEP_END 65 "; cat /probe/work/065.json
printf "running\t66\n" > /probe/work/phase
printf "ASWR_STEP_START 66\n"
/probe/tool_timer /probe/input/066.sh /probe/work/066.json /app 900 > /probe/work/066.stdout 2> /probe/work/066.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t66\n" > /probe/work/phase
printf "ASWR_STEP_END 66 "; cat /probe/work/066.json
printf "running\t67\n" > /probe/work/phase
printf "ASWR_STEP_START 67\n"
/probe/tool_timer /probe/input/067.sh /probe/work/067.json /app 900 > /probe/work/067.stdout 2> /probe/work/067.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t67\n" > /probe/work/phase
printf "ASWR_STEP_END 67 "; cat /probe/work/067.json
printf "running\t68\n" > /probe/work/phase
printf "ASWR_STEP_START 68\n"
/probe/tool_timer /probe/input/068.sh /probe/work/068.json /app 900 > /probe/work/068.stdout 2> /probe/work/068.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t68\n" > /probe/work/phase
printf "ASWR_STEP_END 68 "; cat /probe/work/068.json
printf "running\t69\n" > /probe/work/phase
printf "ASWR_STEP_START 69\n"
/probe/tool_timer /probe/input/069.sh /probe/work/069.json /app 900 > /probe/work/069.stdout 2> /probe/work/069.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t69\n" > /probe/work/phase
printf "ASWR_STEP_END 69 "; cat /probe/work/069.json
printf "running\t70\n" > /probe/work/phase
printf "ASWR_STEP_START 70\n"
/probe/tool_timer /probe/input/070.sh /probe/work/070.json /app 1200 > /probe/work/070.stdout 2> /probe/work/070.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t70\n" > /probe/work/phase
printf "ASWR_STEP_END 70 "; cat /probe/work/070.json
printf "running\t71\n" > /probe/work/phase
printf "ASWR_STEP_START 71\n"
/probe/tool_timer /probe/input/071.sh /probe/work/071.json /app 900 > /probe/work/071.stdout 2> /probe/work/071.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t71\n" > /probe/work/phase
printf "ASWR_STEP_END 71 "; cat /probe/work/071.json
printf "running\t72\n" > /probe/work/phase
printf "ASWR_STEP_START 72\n"
/probe/tool_timer /probe/input/072.sh /probe/work/072.json /app 900 > /probe/work/072.stdout 2> /probe/work/072.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t72\n" > /probe/work/phase
printf "ASWR_STEP_END 72 "; cat /probe/work/072.json
printf "running\t73\n" > /probe/work/phase
printf "ASWR_STEP_START 73\n"
/probe/tool_timer /probe/input/073.sh /probe/work/073.json /app 900 > /probe/work/073.stdout 2> /probe/work/073.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t73\n" > /probe/work/phase
printf "ASWR_STEP_END 73 "; cat /probe/work/073.json
printf "running\t74\n" > /probe/work/phase
printf "ASWR_STEP_START 74\n"
/probe/tool_timer /probe/input/074.sh /probe/work/074.json /app 900 > /probe/work/074.stdout 2> /probe/work/074.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t74\n" > /probe/work/phase
printf "ASWR_STEP_END 74 "; cat /probe/work/074.json
printf "running\t75\n" > /probe/work/phase
printf "ASWR_STEP_START 75\n"
/probe/tool_timer /probe/input/075.sh /probe/work/075.json /app 900 > /probe/work/075.stdout 2> /probe/work/075.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t75\n" > /probe/work/phase
printf "ASWR_STEP_END 75 "; cat /probe/work/075.json
printf "running\t76\n" > /probe/work/phase
printf "ASWR_STEP_START 76\n"
/probe/tool_timer /probe/input/076.sh /probe/work/076.json /app 900 > /probe/work/076.stdout 2> /probe/work/076.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t76\n" > /probe/work/phase
printf "ASWR_STEP_END 76 "; cat /probe/work/076.json
printf "running\t77\n" > /probe/work/phase
printf "ASWR_STEP_START 77\n"
/probe/tool_timer /probe/input/077.sh /probe/work/077.json /app 900 > /probe/work/077.stdout 2> /probe/work/077.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t77\n" > /probe/work/phase
printf "ASWR_STEP_END 77 "; cat /probe/work/077.json
printf "running\t78\n" > /probe/work/phase
printf "ASWR_STEP_START 78\n"
/probe/tool_timer /probe/input/078.sh /probe/work/078.json /app 900 > /probe/work/078.stdout 2> /probe/work/078.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t78\n" > /probe/work/phase
printf "ASWR_STEP_END 78 "; cat /probe/work/078.json
printf "running\t79\n" > /probe/work/phase
printf "ASWR_STEP_START 79\n"
/probe/tool_timer /probe/input/079.sh /probe/work/079.json /app 900 > /probe/work/079.stdout 2> /probe/work/079.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t79\n" > /probe/work/phase
printf "ASWR_STEP_END 79 "; cat /probe/work/079.json
printf "running\t80\n" > /probe/work/phase
printf "ASWR_STEP_START 80\n"
/probe/tool_timer /probe/input/080.sh /probe/work/080.json /app 900 > /probe/work/080.stdout 2> /probe/work/080.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t80\n" > /probe/work/phase
printf "ASWR_STEP_END 80 "; cat /probe/work/080.json
printf "running\t81\n" > /probe/work/phase
printf "ASWR_STEP_START 81\n"
/probe/tool_timer /probe/input/081.sh /probe/work/081.json /app 900 > /probe/work/081.stdout 2> /probe/work/081.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t81\n" > /probe/work/phase
printf "ASWR_STEP_END 81 "; cat /probe/work/081.json
printf "running\t82\n" > /probe/work/phase
printf "ASWR_STEP_START 82\n"
/probe/tool_timer /probe/input/082.sh /probe/work/082.json /app 900 > /probe/work/082.stdout 2> /probe/work/082.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t82\n" > /probe/work/phase
printf "ASWR_STEP_END 82 "; cat /probe/work/082.json
printf "running\t83\n" > /probe/work/phase
printf "ASWR_STEP_START 83\n"
/probe/tool_timer /probe/input/083.sh /probe/work/083.json /app 900 > /probe/work/083.stdout 2> /probe/work/083.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t83\n" > /probe/work/phase
printf "ASWR_STEP_END 83 "; cat /probe/work/083.json
printf "running\t84\n" > /probe/work/phase
printf "ASWR_STEP_START 84\n"
/probe/tool_timer /probe/input/084.sh /probe/work/084.json /app 900 > /probe/work/084.stdout 2> /probe/work/084.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t84\n" > /probe/work/phase
printf "ASWR_STEP_END 84 "; cat /probe/work/084.json
printf "running\t85\n" > /probe/work/phase
printf "ASWR_STEP_START 85\n"
/probe/tool_timer /probe/input/085.sh /probe/work/085.json /app 900 > /probe/work/085.stdout 2> /probe/work/085.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t85\n" > /probe/work/phase
printf "ASWR_STEP_END 85 "; cat /probe/work/085.json
printf "running\t86\n" > /probe/work/phase
printf "ASWR_STEP_START 86\n"
/probe/tool_timer /probe/input/086.sh /probe/work/086.json /app 3600 > /probe/work/086.stdout 2> /probe/work/086.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t86\n" > /probe/work/phase
printf "ASWR_STEP_END 86 "; cat /probe/work/086.json
printf "running\t87\n" > /probe/work/phase
printf "ASWR_STEP_START 87\n"
/probe/tool_timer /probe/input/087.sh /probe/work/087.json /app 900 > /probe/work/087.stdout 2> /probe/work/087.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t87\n" > /probe/work/phase
printf "ASWR_STEP_END 87 "; cat /probe/work/087.json
printf "async_dependency_wait\t88\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-86.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":86,"before_tool_step":88,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-86.done)" >> /probe/work/async-barriers.jsonl
printf "running\t88\n" > /probe/work/phase
printf "ASWR_STEP_START 88\n"
/probe/tool_timer /probe/input/088.sh /probe/work/088.json /app 3600 > /probe/work/088.stdout 2> /probe/work/088.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t88\n" > /probe/work/phase
printf "ASWR_STEP_END 88 "; cat /probe/work/088.json
printf "running\t89\n" > /probe/work/phase
printf "ASWR_STEP_START 89\n"
/probe/tool_timer /probe/input/089.sh /probe/work/089.json /app 900 > /probe/work/089.stdout 2> /probe/work/089.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t89\n" > /probe/work/phase
printf "ASWR_STEP_END 89 "; cat /probe/work/089.json
printf "running\t90\n" > /probe/work/phase
printf "ASWR_STEP_START 90\n"
/probe/tool_timer /probe/input/090.sh /probe/work/090.json /app 900 > /probe/work/090.stdout 2> /probe/work/090.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t90\n" > /probe/work/phase
printf "ASWR_STEP_END 90 "; cat /probe/work/090.json
printf "running\t91\n" > /probe/work/phase
printf "ASWR_STEP_START 91\n"
/probe/tool_timer /probe/input/091.sh /probe/work/091.json /app 900 > /probe/work/091.stdout 2> /probe/work/091.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t91\n" > /probe/work/phase
printf "ASWR_STEP_END 91 "; cat /probe/work/091.json
printf "running\t92\n" > /probe/work/phase
printf "ASWR_STEP_START 92\n"
/probe/tool_timer /probe/input/092.sh /probe/work/092.json /app 900 > /probe/work/092.stdout 2> /probe/work/092.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t92\n" > /probe/work/phase
printf "ASWR_STEP_END 92 "; cat /probe/work/092.json
printf "running\t93\n" > /probe/work/phase
printf "ASWR_STEP_START 93\n"
/probe/tool_timer /probe/input/093.sh /probe/work/093.json /app 1200 > /probe/work/093.stdout 2> /probe/work/093.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t93\n" > /probe/work/phase
printf "ASWR_STEP_END 93 "; cat /probe/work/093.json
printf "running\t94\n" > /probe/work/phase
printf "ASWR_STEP_START 94\n"
/probe/tool_timer /probe/input/094.sh /probe/work/094.json /app 900 > /probe/work/094.stdout 2> /probe/work/094.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t94\n" > /probe/work/phase
printf "ASWR_STEP_END 94 "; cat /probe/work/094.json
printf "running\t95\n" > /probe/work/phase
printf "ASWR_STEP_START 95\n"
/probe/tool_timer /probe/input/095.sh /probe/work/095.json /app 900 > /probe/work/095.stdout 2> /probe/work/095.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t95\n" > /probe/work/phase
printf "ASWR_STEP_END 95 "; cat /probe/work/095.json
printf "running\t96\n" > /probe/work/phase
printf "ASWR_STEP_START 96\n"
/probe/tool_timer /probe/input/096.sh /probe/work/096.json /app 900 > /probe/work/096.stdout 2> /probe/work/096.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t96\n" > /probe/work/phase
printf "ASWR_STEP_END 96 "; cat /probe/work/096.json
printf "running\t97\n" > /probe/work/phase
printf "ASWR_STEP_START 97\n"
/probe/tool_timer /probe/input/097.sh /probe/work/097.json /app 900 > /probe/work/097.stdout 2> /probe/work/097.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t97\n" > /probe/work/phase
printf "ASWR_STEP_END 97 "; cat /probe/work/097.json
printf "running\t98\n" > /probe/work/phase
printf "ASWR_STEP_START 98\n"
/probe/tool_timer /probe/input/098.sh /probe/work/098.json /app 900 > /probe/work/098.stdout 2> /probe/work/098.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t98\n" > /probe/work/phase
printf "ASWR_STEP_END 98 "; cat /probe/work/098.json
printf "running\t99\n" > /probe/work/phase
printf "ASWR_STEP_START 99\n"
/probe/tool_timer /probe/input/099.sh /probe/work/099.json /app 900 > /probe/work/099.stdout 2> /probe/work/099.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t99\n" > /probe/work/phase
printf "ASWR_STEP_END 99 "; cat /probe/work/099.json
printf "running\t100\n" > /probe/work/phase
printf "ASWR_STEP_START 100\n"
/probe/tool_timer /probe/input/100.sh /probe/work/100.json /app 900 > /probe/work/100.stdout 2> /probe/work/100.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t100\n" > /probe/work/phase
printf "ASWR_STEP_END 100 "; cat /probe/work/100.json
printf "running\t101\n" > /probe/work/phase
printf "ASWR_STEP_START 101\n"
/probe/tool_timer /probe/input/101.sh /probe/work/101.json /app 900 > /probe/work/101.stdout 2> /probe/work/101.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t101\n" > /probe/work/phase
printf "ASWR_STEP_END 101 "; cat /probe/work/101.json
printf "running\t102\n" > /probe/work/phase
printf "ASWR_STEP_START 102\n"
/probe/tool_timer /probe/input/102.sh /probe/work/102.json /app 3600 > /probe/work/102.stdout 2> /probe/work/102.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t102\n" > /probe/work/phase
printf "ASWR_STEP_END 102 "; cat /probe/work/102.json
printf "running\t103\n" > /probe/work/phase
printf "ASWR_STEP_START 103\n"
/probe/tool_timer /probe/input/103.sh /probe/work/103.json /app 900 > /probe/work/103.stdout 2> /probe/work/103.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t103\n" > /probe/work/phase
printf "ASWR_STEP_END 103 "; cat /probe/work/103.json
printf "running\t104\n" > /probe/work/phase
printf "ASWR_STEP_START 104\n"
/probe/tool_timer /probe/input/104.sh /probe/work/104.json /app 900 > /probe/work/104.stdout 2> /probe/work/104.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t104\n" > /probe/work/phase
printf "ASWR_STEP_END 104 "; cat /probe/work/104.json
printf "running\t105\n" > /probe/work/phase
printf "ASWR_STEP_START 105\n"
/probe/tool_timer /probe/input/105.sh /probe/work/105.json /app 900 > /probe/work/105.stdout 2> /probe/work/105.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t105\n" > /probe/work/phase
printf "ASWR_STEP_END 105 "; cat /probe/work/105.json
printf "running\t106\n" > /probe/work/phase
printf "ASWR_STEP_START 106\n"
/probe/tool_timer /probe/input/106.sh /probe/work/106.json /app 900 > /probe/work/106.stdout 2> /probe/work/106.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t106\n" > /probe/work/phase
printf "ASWR_STEP_END 106 "; cat /probe/work/106.json
printf "async_dependency_wait\t107\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-102.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":102,"before_tool_step":107,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-102.done)" >> /probe/work/async-barriers.jsonl
printf "running\t107\n" > /probe/work/phase
printf "ASWR_STEP_START 107\n"
/probe/tool_timer /probe/input/107.sh /probe/work/107.json /app 900 > /probe/work/107.stdout 2> /probe/work/107.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t107\n" > /probe/work/phase
printf "ASWR_STEP_END 107 "; cat /probe/work/107.json
printf "running\t108\n" > /probe/work/phase
printf "ASWR_STEP_START 108\n"
/probe/tool_timer /probe/input/108.sh /probe/work/108.json /app 900 > /probe/work/108.stdout 2> /probe/work/108.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t108\n" > /probe/work/phase
printf "ASWR_STEP_END 108 "; cat /probe/work/108.json
printf "running\t109\n" > /probe/work/phase
printf "ASWR_STEP_START 109\n"
/probe/tool_timer /probe/input/109.sh /probe/work/109.json /app 900 > /probe/work/109.stdout 2> /probe/work/109.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t109\n" > /probe/work/phase
printf "ASWR_STEP_END 109 "; cat /probe/work/109.json
printf "running\t110\n" > /probe/work/phase
printf "ASWR_STEP_START 110\n"
/probe/tool_timer /probe/input/110.sh /probe/work/110.json /app 900 > /probe/work/110.stdout 2> /probe/work/110.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t110\n" > /probe/work/phase
printf "ASWR_STEP_END 110 "; cat /probe/work/110.json
printf "running\t111\n" > /probe/work/phase
printf "ASWR_STEP_START 111\n"
/probe/tool_timer /probe/input/111.sh /probe/work/111.json /app 1800 > /probe/work/111.stdout 2> /probe/work/111.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t111\n" > /probe/work/phase
printf "ASWR_STEP_END 111 "; cat /probe/work/111.json
printf "running\t112\n" > /probe/work/phase
printf "ASWR_STEP_START 112\n"
/probe/tool_timer /probe/input/112.sh /probe/work/112.json /app 3600 > /probe/work/112.stdout 2> /probe/work/112.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t112\n" > /probe/work/phase
printf "ASWR_STEP_END 112 "; cat /probe/work/112.json
printf "running\t113\n" > /probe/work/phase
printf "ASWR_STEP_START 113\n"
/probe/tool_timer /probe/input/113.sh /probe/work/113.json /app 900 > /probe/work/113.stdout 2> /probe/work/113.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t113\n" > /probe/work/phase
printf "ASWR_STEP_END 113 "; cat /probe/work/113.json
printf "running\t114\n" > /probe/work/phase
printf "ASWR_STEP_START 114\n"
/probe/tool_timer /probe/input/114.sh /probe/work/114.json /app 900 > /probe/work/114.stdout 2> /probe/work/114.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t114\n" > /probe/work/phase
printf "ASWR_STEP_END 114 "; cat /probe/work/114.json
printf "running\t115\n" > /probe/work/phase
printf "ASWR_STEP_START 115\n"
/probe/tool_timer /probe/input/115.sh /probe/work/115.json /app 900 > /probe/work/115.stdout 2> /probe/work/115.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t115\n" > /probe/work/phase
printf "ASWR_STEP_END 115 "; cat /probe/work/115.json
printf "running\t116\n" > /probe/work/phase
printf "ASWR_STEP_START 116\n"
/probe/tool_timer /probe/input/116.sh /probe/work/116.json /app 900 > /probe/work/116.stdout 2> /probe/work/116.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t116\n" > /probe/work/phase
printf "ASWR_STEP_END 116 "; cat /probe/work/116.json
printf "running\t117\n" > /probe/work/phase
printf "ASWR_STEP_START 117\n"
/probe/tool_timer /probe/input/117.sh /probe/work/117.json /app 900 > /probe/work/117.stdout 2> /probe/work/117.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t117\n" > /probe/work/phase
printf "ASWR_STEP_END 117 "; cat /probe/work/117.json
printf "running\t118\n" > /probe/work/phase
printf "ASWR_STEP_START 118\n"
/probe/tool_timer /probe/input/118.sh /probe/work/118.json /app 900 > /probe/work/118.stdout 2> /probe/work/118.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t118\n" > /probe/work/phase
printf "ASWR_STEP_END 118 "; cat /probe/work/118.json
printf "running\t119\n" > /probe/work/phase
printf "ASWR_STEP_START 119\n"
/probe/tool_timer /probe/input/119.sh /probe/work/119.json /app 900 > /probe/work/119.stdout 2> /probe/work/119.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t119\n" > /probe/work/phase
printf "ASWR_STEP_END 119 "; cat /probe/work/119.json
printf "running\t120\n" > /probe/work/phase
printf "ASWR_STEP_START 120\n"
/probe/tool_timer /probe/input/120.sh /probe/work/120.json /app 900 > /probe/work/120.stdout 2> /probe/work/120.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t120\n" > /probe/work/phase
printf "ASWR_STEP_END 120 "; cat /probe/work/120.json
printf "running\t121\n" > /probe/work/phase
printf "ASWR_STEP_START 121\n"
/probe/tool_timer /probe/input/121.sh /probe/work/121.json /app 900 > /probe/work/121.stdout 2> /probe/work/121.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t121\n" > /probe/work/phase
printf "ASWR_STEP_END 121 "; cat /probe/work/121.json
printf "running\t122\n" > /probe/work/phase
printf "ASWR_STEP_START 122\n"
/probe/tool_timer /probe/input/122.sh /probe/work/122.json /app 900 > /probe/work/122.stdout 2> /probe/work/122.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t122\n" > /probe/work/phase
printf "ASWR_STEP_END 122 "; cat /probe/work/122.json
printf "running\t123\n" > /probe/work/phase
printf "ASWR_STEP_START 123\n"
/probe/tool_timer /probe/input/123.sh /probe/work/123.json /app 900 > /probe/work/123.stdout 2> /probe/work/123.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t123\n" > /probe/work/phase
printf "ASWR_STEP_END 123 "; cat /probe/work/123.json
printf "running\t124\n" > /probe/work/phase
printf "ASWR_STEP_START 124\n"
/probe/tool_timer /probe/input/124.sh /probe/work/124.json /app 900 > /probe/work/124.stdout 2> /probe/work/124.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t124\n" > /probe/work/phase
printf "ASWR_STEP_END 124 "; cat /probe/work/124.json
printf "running\t125\n" > /probe/work/phase
printf "ASWR_STEP_START 125\n"
/probe/tool_timer /probe/input/125.sh /probe/work/125.json /app 900 > /probe/work/125.stdout 2> /probe/work/125.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t125\n" > /probe/work/phase
printf "ASWR_STEP_END 125 "; cat /probe/work/125.json
printf "running\t126\n" > /probe/work/phase
printf "ASWR_STEP_START 126\n"
/probe/tool_timer /probe/input/126.sh /probe/work/126.json /app 900 > /probe/work/126.stdout 2> /probe/work/126.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t126\n" > /probe/work/phase
printf "ASWR_STEP_END 126 "; cat /probe/work/126.json
printf "running\t127\n" > /probe/work/phase
printf "ASWR_STEP_START 127\n"
/probe/tool_timer /probe/input/127.sh /probe/work/127.json /app 900 > /probe/work/127.stdout 2> /probe/work/127.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t127\n" > /probe/work/phase
printf "ASWR_STEP_END 127 "; cat /probe/work/127.json
printf "running\t128\n" > /probe/work/phase
printf "ASWR_STEP_START 128\n"
/probe/tool_timer /probe/input/128.sh /probe/work/128.json /app 900 > /probe/work/128.stdout 2> /probe/work/128.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t128\n" > /probe/work/phase
printf "ASWR_STEP_END 128 "; cat /probe/work/128.json
printf "running\t129\n" > /probe/work/phase
printf "ASWR_STEP_START 129\n"
/probe/tool_timer /probe/input/129.sh /probe/work/129.json /app 900 > /probe/work/129.stdout 2> /probe/work/129.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t129\n" > /probe/work/phase
printf "ASWR_STEP_END 129 "; cat /probe/work/129.json
printf "running\t130\n" > /probe/work/phase
printf "ASWR_STEP_START 130\n"
/probe/tool_timer /probe/input/130.sh /probe/work/130.json /app 900 > /probe/work/130.stdout 2> /probe/work/130.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t130\n" > /probe/work/phase
printf "ASWR_STEP_END 130 "; cat /probe/work/130.json
printf "running\t131\n" > /probe/work/phase
printf "ASWR_STEP_START 131\n"
/probe/tool_timer /probe/input/131.sh /probe/work/131.json /app 900 > /probe/work/131.stdout 2> /probe/work/131.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t131\n" > /probe/work/phase
printf "ASWR_STEP_END 131 "; cat /probe/work/131.json
printf "running\t132\n" > /probe/work/phase
printf "ASWR_STEP_START 132\n"
/probe/tool_timer /probe/input/132.sh /probe/work/132.json /app 3600 > /probe/work/132.stdout 2> /probe/work/132.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t132\n" > /probe/work/phase
printf "ASWR_STEP_END 132 "; cat /probe/work/132.json
printf "running\t133\n" > /probe/work/phase
printf "ASWR_STEP_START 133\n"
/probe/tool_timer /probe/input/133.sh /probe/work/133.json /app 900 > /probe/work/133.stdout 2> /probe/work/133.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t133\n" > /probe/work/phase
printf "ASWR_STEP_END 133 "; cat /probe/work/133.json
printf "async_dependency_wait\t134\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-132.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":132,"before_tool_step":134,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-132.done)" >> /probe/work/async-barriers.jsonl
printf "running\t134\n" > /probe/work/phase
printf "ASWR_STEP_START 134\n"
/probe/tool_timer /probe/input/134.sh /probe/work/134.json /app 900 > /probe/work/134.stdout 2> /probe/work/134.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t134\n" > /probe/work/phase
printf "ASWR_STEP_END 134 "; cat /probe/work/134.json
printf "running\t135\n" > /probe/work/phase
printf "ASWR_STEP_START 135\n"
/probe/tool_timer /probe/input/135.sh /probe/work/135.json /app 900 > /probe/work/135.stdout 2> /probe/work/135.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t135\n" > /probe/work/phase
printf "ASWR_STEP_END 135 "; cat /probe/work/135.json
printf "running\t136\n" > /probe/work/phase
printf "ASWR_STEP_START 136\n"
/probe/tool_timer /probe/input/136.sh /probe/work/136.json /app 900 > /probe/work/136.stdout 2> /probe/work/136.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t136\n" > /probe/work/phase
printf "ASWR_STEP_END 136 "; cat /probe/work/136.json
printf "running\t137\n" > /probe/work/phase
printf "ASWR_STEP_START 137\n"
/probe/tool_timer /probe/input/137.sh /probe/work/137.json /app 900 > /probe/work/137.stdout 2> /probe/work/137.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t137\n" > /probe/work/phase
printf "ASWR_STEP_END 137 "; cat /probe/work/137.json
printf "running\t138\n" > /probe/work/phase
printf "ASWR_STEP_START 138\n"
/probe/tool_timer /probe/input/138.sh /probe/work/138.json /app 900 > /probe/work/138.stdout 2> /probe/work/138.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t138\n" > /probe/work/phase
printf "ASWR_STEP_END 138 "; cat /probe/work/138.json
printf "running\t139\n" > /probe/work/phase
printf "ASWR_STEP_START 139\n"
/probe/tool_timer /probe/input/139.sh /probe/work/139.json /app 900 > /probe/work/139.stdout 2> /probe/work/139.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t139\n" > /probe/work/phase
printf "ASWR_STEP_END 139 "; cat /probe/work/139.json
printf "running\t140\n" > /probe/work/phase
printf "ASWR_STEP_START 140\n"
/probe/tool_timer /probe/input/140.sh /probe/work/140.json /app 900 > /probe/work/140.stdout 2> /probe/work/140.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t140\n" > /probe/work/phase
printf "ASWR_STEP_END 140 "; cat /probe/work/140.json
printf "running\t141\n" > /probe/work/phase
printf "ASWR_STEP_START 141\n"
/probe/tool_timer /probe/input/141.sh /probe/work/141.json /app 900 > /probe/work/141.stdout 2> /probe/work/141.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t141\n" > /probe/work/phase
printf "ASWR_STEP_END 141 "; cat /probe/work/141.json
printf "running\t142\n" > /probe/work/phase
printf "ASWR_STEP_START 142\n"
/probe/tool_timer /probe/input/142.sh /probe/work/142.json /app 900 > /probe/work/142.stdout 2> /probe/work/142.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t142\n" > /probe/work/phase
printf "ASWR_STEP_END 142 "; cat /probe/work/142.json
printf "running\t143\n" > /probe/work/phase
printf "ASWR_STEP_START 143\n"
/probe/tool_timer /probe/input/143.sh /probe/work/143.json /app 900 > /probe/work/143.stdout 2> /probe/work/143.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t143\n" > /probe/work/phase
printf "ASWR_STEP_END 143 "; cat /probe/work/143.json
printf "running\t144\n" > /probe/work/phase
printf "ASWR_STEP_START 144\n"
/probe/tool_timer /probe/input/144.sh /probe/work/144.json /app 900 > /probe/work/144.stdout 2> /probe/work/144.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t144\n" > /probe/work/phase
printf "ASWR_STEP_END 144 "; cat /probe/work/144.json
printf "running\t145\n" > /probe/work/phase
printf "ASWR_STEP_START 145\n"
/probe/tool_timer /probe/input/145.sh /probe/work/145.json /app 900 > /probe/work/145.stdout 2> /probe/work/145.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t145\n" > /probe/work/phase
printf "ASWR_STEP_END 145 "; cat /probe/work/145.json
printf "running\t146\n" > /probe/work/phase
printf "ASWR_STEP_START 146\n"
/probe/tool_timer /probe/input/146.sh /probe/work/146.json /app 900 > /probe/work/146.stdout 2> /probe/work/146.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t146\n" > /probe/work/phase
printf "ASWR_STEP_END 146 "; cat /probe/work/146.json
printf "running\t147\n" > /probe/work/phase
printf "ASWR_STEP_START 147\n"
/probe/tool_timer /probe/input/147.sh /probe/work/147.json /app 900 > /probe/work/147.stdout 2> /probe/work/147.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t147\n" > /probe/work/phase
printf "ASWR_STEP_END 147 "; cat /probe/work/147.json
printf "running\t148\n" > /probe/work/phase
printf "ASWR_STEP_START 148\n"
/probe/tool_timer /probe/input/148.sh /probe/work/148.json /app 900 > /probe/work/148.stdout 2> /probe/work/148.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t148\n" > /probe/work/phase
printf "ASWR_STEP_END 148 "; cat /probe/work/148.json
printf "running\t149\n" > /probe/work/phase
printf "ASWR_STEP_START 149\n"
/probe/tool_timer /probe/input/149.sh /probe/work/149.json /app 900 > /probe/work/149.stdout 2> /probe/work/149.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t149\n" > /probe/work/phase
printf "ASWR_STEP_END 149 "; cat /probe/work/149.json
printf "running\t150\n" > /probe/work/phase
printf "ASWR_STEP_START 150\n"
/probe/tool_timer /probe/input/150.sh /probe/work/150.json /app 900 > /probe/work/150.stdout 2> /probe/work/150.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t150\n" > /probe/work/phase
printf "ASWR_STEP_END 150 "; cat /probe/work/150.json
printf "running\t151\n" > /probe/work/phase
printf "ASWR_STEP_START 151\n"
/probe/tool_timer /probe/input/151.sh /probe/work/151.json /app 900 > /probe/work/151.stdout 2> /probe/work/151.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t151\n" > /probe/work/phase
printf "ASWR_STEP_END 151 "; cat /probe/work/151.json
printf "running\t152\n" > /probe/work/phase
printf "ASWR_STEP_START 152\n"
/probe/tool_timer /probe/input/152.sh /probe/work/152.json /app 900 > /probe/work/152.stdout 2> /probe/work/152.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t152\n" > /probe/work/phase
printf "ASWR_STEP_END 152 "; cat /probe/work/152.json
printf "running\t153\n" > /probe/work/phase
printf "ASWR_STEP_START 153\n"
/probe/tool_timer /probe/input/153.sh /probe/work/153.json /app 900 > /probe/work/153.stdout 2> /probe/work/153.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t153\n" > /probe/work/phase
printf "ASWR_STEP_END 153 "; cat /probe/work/153.json
printf "running\t154\n" > /probe/work/phase
printf "ASWR_STEP_START 154\n"
/probe/tool_timer /probe/input/154.sh /probe/work/154.json /app 900 > /probe/work/154.stdout 2> /probe/work/154.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t154\n" > /probe/work/phase
printf "ASWR_STEP_END 154 "; cat /probe/work/154.json
printf "running\t155\n" > /probe/work/phase
printf "ASWR_STEP_START 155\n"
/probe/tool_timer /probe/input/155.sh /probe/work/155.json /app 900 > /probe/work/155.stdout 2> /probe/work/155.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t155\n" > /probe/work/phase
printf "ASWR_STEP_END 155 "; cat /probe/work/155.json
printf "running\t156\n" > /probe/work/phase
printf "ASWR_STEP_START 156\n"
/probe/tool_timer /probe/input/156.sh /probe/work/156.json /app 900 > /probe/work/156.stdout 2> /probe/work/156.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t156\n" > /probe/work/phase
printf "ASWR_STEP_END 156 "; cat /probe/work/156.json
printf "running\t157\n" > /probe/work/phase
printf "ASWR_STEP_START 157\n"
/probe/tool_timer /probe/input/157.sh /probe/work/157.json /app 900 > /probe/work/157.stdout 2> /probe/work/157.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t157\n" > /probe/work/phase
printf "ASWR_STEP_END 157 "; cat /probe/work/157.json
printf "running\t158\n" > /probe/work/phase
printf "ASWR_STEP_START 158\n"
/probe/tool_timer /probe/input/158.sh /probe/work/158.json /app 900 > /probe/work/158.stdout 2> /probe/work/158.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t158\n" > /probe/work/phase
printf "ASWR_STEP_END 158 "; cat /probe/work/158.json
printf "running\t159\n" > /probe/work/phase
printf "ASWR_STEP_START 159\n"
/probe/tool_timer /probe/input/159.sh /probe/work/159.json /app 900 > /probe/work/159.stdout 2> /probe/work/159.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t159\n" > /probe/work/phase
printf "ASWR_STEP_END 159 "; cat /probe/work/159.json
printf "running\t160\n" > /probe/work/phase
printf "ASWR_STEP_START 160\n"
/probe/tool_timer /probe/input/160.sh /probe/work/160.json /app 900 > /probe/work/160.stdout 2> /probe/work/160.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t160\n" > /probe/work/phase
printf "ASWR_STEP_END 160 "; cat /probe/work/160.json
printf "running\t161\n" > /probe/work/phase
printf "ASWR_STEP_START 161\n"
/probe/tool_timer /probe/input/161.sh /probe/work/161.json /app 900 > /probe/work/161.stdout 2> /probe/work/161.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t161\n" > /probe/work/phase
printf "ASWR_STEP_END 161 "; cat /probe/work/161.json
printf "running\t162\n" > /probe/work/phase
printf "ASWR_STEP_START 162\n"
/probe/tool_timer /probe/input/162.sh /probe/work/162.json /app 900 > /probe/work/162.stdout 2> /probe/work/162.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t162\n" > /probe/work/phase
printf "ASWR_STEP_END 162 "; cat /probe/work/162.json
printf "running\t163\n" > /probe/work/phase
printf "ASWR_STEP_START 163\n"
/probe/tool_timer /probe/input/163.sh /probe/work/163.json /app 900 > /probe/work/163.stdout 2> /probe/work/163.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t163\n" > /probe/work/phase
printf "ASWR_STEP_END 163 "; cat /probe/work/163.json
printf "running\t164\n" > /probe/work/phase
printf "ASWR_STEP_START 164\n"
/probe/tool_timer /probe/input/164.sh /probe/work/164.json /app 900 > /probe/work/164.stdout 2> /probe/work/164.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t164\n" > /probe/work/phase
printf "ASWR_STEP_END 164 "; cat /probe/work/164.json
printf "running\t165\n" > /probe/work/phase
printf "ASWR_STEP_START 165\n"
/probe/tool_timer /probe/input/165.sh /probe/work/165.json /app 900 > /probe/work/165.stdout 2> /probe/work/165.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t165\n" > /probe/work/phase
printf "ASWR_STEP_END 165 "; cat /probe/work/165.json
printf "running\t166\n" > /probe/work/phase
printf "ASWR_STEP_START 166\n"
/probe/tool_timer /probe/input/166.sh /probe/work/166.json /app 900 > /probe/work/166.stdout 2> /probe/work/166.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t166\n" > /probe/work/phase
printf "ASWR_STEP_END 166 "; cat /probe/work/166.json
printf "running\t167\n" > /probe/work/phase
printf "ASWR_STEP_START 167\n"
/probe/tool_timer /probe/input/167.sh /probe/work/167.json /app 900 > /probe/work/167.stdout 2> /probe/work/167.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t167\n" > /probe/work/phase
printf "ASWR_STEP_END 167 "; cat /probe/work/167.json
printf "running\t168\n" > /probe/work/phase
printf "ASWR_STEP_START 168\n"
/probe/tool_timer /probe/input/168.sh /probe/work/168.json /app 900 > /probe/work/168.stdout 2> /probe/work/168.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t168\n" > /probe/work/phase
printf "ASWR_STEP_END 168 "; cat /probe/work/168.json
printf "running\t169\n" > /probe/work/phase
printf "ASWR_STEP_START 169\n"
/probe/tool_timer /probe/input/169.sh /probe/work/169.json /app 900 > /probe/work/169.stdout 2> /probe/work/169.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t169\n" > /probe/work/phase
printf "ASWR_STEP_END 169 "; cat /probe/work/169.json
printf "running\t170\n" > /probe/work/phase
printf "ASWR_STEP_START 170\n"
/probe/tool_timer /probe/input/170.sh /probe/work/170.json /app 900 > /probe/work/170.stdout 2> /probe/work/170.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t170\n" > /probe/work/phase
printf "ASWR_STEP_END 170 "; cat /probe/work/170.json
printf "running\t171\n" > /probe/work/phase
printf "ASWR_STEP_START 171\n"
/probe/tool_timer /probe/input/171.sh /probe/work/171.json /app 900 > /probe/work/171.stdout 2> /probe/work/171.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t171\n" > /probe/work/phase
printf "ASWR_STEP_END 171 "; cat /probe/work/171.json
printf "running\t172\n" > /probe/work/phase
printf "ASWR_STEP_START 172\n"
/probe/tool_timer /probe/input/172.sh /probe/work/172.json /app 900 > /probe/work/172.stdout 2> /probe/work/172.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t172\n" > /probe/work/phase
printf "ASWR_STEP_END 172 "; cat /probe/work/172.json
printf "running\t173\n" > /probe/work/phase
printf "ASWR_STEP_START 173\n"
/probe/tool_timer /probe/input/173.sh /probe/work/173.json /app 900 > /probe/work/173.stdout 2> /probe/work/173.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t173\n" > /probe/work/phase
printf "ASWR_STEP_END 173 "; cat /probe/work/173.json
printf "running\t174\n" > /probe/work/phase
printf "ASWR_STEP_START 174\n"
/probe/tool_timer /probe/input/174.sh /probe/work/174.json /app 3600 > /probe/work/174.stdout 2> /probe/work/174.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t174\n" > /probe/work/phase
printf "ASWR_STEP_END 174 "; cat /probe/work/174.json
printf "running\t175\n" > /probe/work/phase
printf "ASWR_STEP_START 175\n"
/probe/tool_timer /probe/input/175.sh /probe/work/175.json /app 900 > /probe/work/175.stdout 2> /probe/work/175.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t175\n" > /probe/work/phase
printf "ASWR_STEP_END 175 "; cat /probe/work/175.json
printf "async_dependency_wait\t176\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-174.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":174,"before_tool_step":176,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-174.done)" >> /probe/work/async-barriers.jsonl
printf "running\t176\n" > /probe/work/phase
printf "ASWR_STEP_START 176\n"
/probe/tool_timer /probe/input/176.sh /probe/work/176.json /app 900 > /probe/work/176.stdout 2> /probe/work/176.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t176\n" > /probe/work/phase
printf "ASWR_STEP_END 176 "; cat /probe/work/176.json
printf "running\t177\n" > /probe/work/phase
printf "ASWR_STEP_START 177\n"
/probe/tool_timer /probe/input/177.sh /probe/work/177.json /app 900 > /probe/work/177.stdout 2> /probe/work/177.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t177\n" > /probe/work/phase
printf "ASWR_STEP_END 177 "; cat /probe/work/177.json
printf "running\t178\n" > /probe/work/phase
printf "ASWR_STEP_START 178\n"
/probe/tool_timer /probe/input/178.sh /probe/work/178.json /app 900 > /probe/work/178.stdout 2> /probe/work/178.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t178\n" > /probe/work/phase
printf "ASWR_STEP_END 178 "; cat /probe/work/178.json
printf "running\t179\n" > /probe/work/phase
printf "ASWR_STEP_START 179\n"
/probe/tool_timer /probe/input/179.sh /probe/work/179.json /app 900 > /probe/work/179.stdout 2> /probe/work/179.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t179\n" > /probe/work/phase
printf "ASWR_STEP_END 179 "; cat /probe/work/179.json
printf "running\t180\n" > /probe/work/phase
printf "ASWR_STEP_START 180\n"
/probe/tool_timer /probe/input/180.sh /probe/work/180.json /app 900 > /probe/work/180.stdout 2> /probe/work/180.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t180\n" > /probe/work/phase
printf "ASWR_STEP_END 180 "; cat /probe/work/180.json
printf "running\t181\n" > /probe/work/phase
printf "ASWR_STEP_START 181\n"
/probe/tool_timer /probe/input/181.sh /probe/work/181.json /app 900 > /probe/work/181.stdout 2> /probe/work/181.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t181\n" > /probe/work/phase
printf "ASWR_STEP_END 181 "; cat /probe/work/181.json
printf "running\t182\n" > /probe/work/phase
printf "ASWR_STEP_START 182\n"
/probe/tool_timer /probe/input/182.sh /probe/work/182.json /app 900 > /probe/work/182.stdout 2> /probe/work/182.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t182\n" > /probe/work/phase
printf "ASWR_STEP_END 182 "; cat /probe/work/182.json
printf "running\t183\n" > /probe/work/phase
printf "ASWR_STEP_START 183\n"
/probe/tool_timer /probe/input/183.sh /probe/work/183.json /app 900 > /probe/work/183.stdout 2> /probe/work/183.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t183\n" > /probe/work/phase
printf "ASWR_STEP_END 183 "; cat /probe/work/183.json
printf "running\t184\n" > /probe/work/phase
printf "ASWR_STEP_START 184\n"
/probe/tool_timer /probe/input/184.sh /probe/work/184.json /app 900 > /probe/work/184.stdout 2> /probe/work/184.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t184\n" > /probe/work/phase
printf "ASWR_STEP_END 184 "; cat /probe/work/184.json
printf "running\t185\n" > /probe/work/phase
printf "ASWR_STEP_START 185\n"
/probe/tool_timer /probe/input/185.sh /probe/work/185.json /app 900 > /probe/work/185.stdout 2> /probe/work/185.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t185\n" > /probe/work/phase
printf "ASWR_STEP_END 185 "; cat /probe/work/185.json
printf "cache_scan\t185\n" > /probe/work/phase
/probe/workload_probe scan /tmp/CompCert /tmp/coq-8.16.1 /usr/local/lib /app > /probe/work/boundary-185.json
printf "running\t186\n" > /probe/work/phase
printf "ASWR_STEP_START 186\n"
/probe/tool_timer /probe/input/186.sh /probe/work/186.json /app 900 > /probe/work/186.stdout 2> /probe/work/186.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t186\n" > /probe/work/phase
printf "ASWR_STEP_END 186 "; cat /probe/work/186.json
printf "running\t187\n" > /probe/work/phase
printf "ASWR_STEP_START 187\n"
/probe/tool_timer /probe/input/187.sh /probe/work/187.json /app 900 > /probe/work/187.stdout 2> /probe/work/187.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t187\n" > /probe/work/phase
printf "ASWR_STEP_END 187 "; cat /probe/work/187.json
printf "running\t188\n" > /probe/work/phase
printf "ASWR_STEP_START 188\n"
/probe/tool_timer /probe/input/188.sh /probe/work/188.json /app 900 > /probe/work/188.stdout 2> /probe/work/188.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t188\n" > /probe/work/phase
printf "ASWR_STEP_END 188 "; cat /probe/work/188.json
printf "running\t189\n" > /probe/work/phase
printf "ASWR_STEP_START 189\n"
/probe/tool_timer /probe/input/189.sh /probe/work/189.json /app 900 > /probe/work/189.stdout 2> /probe/work/189.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t189\n" > /probe/work/phase
printf "ASWR_STEP_END 189 "; cat /probe/work/189.json
printf "running\t190\n" > /probe/work/phase
printf "ASWR_STEP_START 190\n"
/probe/tool_timer /probe/input/190.sh /probe/work/190.json /app 900 > /probe/work/190.stdout 2> /probe/work/190.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t190\n" > /probe/work/phase
printf "ASWR_STEP_END 190 "; cat /probe/work/190.json
printf "running\t191\n" > /probe/work/phase
printf "ASWR_STEP_START 191\n"
/probe/tool_timer /probe/input/191.sh /probe/work/191.json /app 900 > /probe/work/191.stdout 2> /probe/work/191.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t191\n" > /probe/work/phase
printf "ASWR_STEP_END 191 "; cat /probe/work/191.json
printf "running\t192\n" > /probe/work/phase
printf "ASWR_STEP_START 192\n"
/probe/tool_timer /probe/input/192.sh /probe/work/192.json /app 900 > /probe/work/192.stdout 2> /probe/work/192.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t192\n" > /probe/work/phase
printf "ASWR_STEP_END 192 "; cat /probe/work/192.json
printf "running\t193\n" > /probe/work/phase
printf "ASWR_STEP_START 193\n"
/probe/tool_timer /probe/input/193.sh /probe/work/193.json /app 900 > /probe/work/193.stdout 2> /probe/work/193.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t193\n" > /probe/work/phase
printf "ASWR_STEP_END 193 "; cat /probe/work/193.json
printf "running\t194\n" > /probe/work/phase
printf "ASWR_STEP_START 194\n"
/probe/tool_timer /probe/input/194.sh /probe/work/194.json /app 900 > /probe/work/194.stdout 2> /probe/work/194.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t194\n" > /probe/work/phase
printf "ASWR_STEP_END 194 "; cat /probe/work/194.json
printf "running\t195\n" > /probe/work/phase
printf "ASWR_STEP_START 195\n"
/probe/tool_timer /probe/input/195.sh /probe/work/195.json /app 900 > /probe/work/195.stdout 2> /probe/work/195.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t195\n" > /probe/work/phase
printf "ASWR_STEP_END 195 "; cat /probe/work/195.json
printf "running\t196\n" > /probe/work/phase
printf "ASWR_STEP_START 196\n"
/probe/tool_timer /probe/input/196.sh /probe/work/196.json /app 900 > /probe/work/196.stdout 2> /probe/work/196.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t196\n" > /probe/work/phase
printf "ASWR_STEP_END 196 "; cat /probe/work/196.json
printf "running\t197\n" > /probe/work/phase
printf "ASWR_STEP_START 197\n"
/probe/tool_timer /probe/input/197.sh /probe/work/197.json /app 900 > /probe/work/197.stdout 2> /probe/work/197.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t197\n" > /probe/work/phase
printf "ASWR_STEP_END 197 "; cat /probe/work/197.json
printf "running\t198\n" > /probe/work/phase
printf "ASWR_STEP_START 198\n"
/probe/tool_timer /probe/input/198.sh /probe/work/198.json /app 900 > /probe/work/198.stdout 2> /probe/work/198.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t198\n" > /probe/work/phase
printf "ASWR_STEP_END 198 "; cat /probe/work/198.json
printf "running\t199\n" > /probe/work/phase
printf "ASWR_STEP_START 199\n"
/probe/tool_timer /probe/input/199.sh /probe/work/199.json /app 900 > /probe/work/199.stdout 2> /probe/work/199.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t199\n" > /probe/work/phase
printf "ASWR_STEP_END 199 "; cat /probe/work/199.json
printf "running\t200\n" > /probe/work/phase
printf "ASWR_STEP_START 200\n"
/probe/tool_timer /probe/input/200.sh /probe/work/200.json /app 900 > /probe/work/200.stdout 2> /probe/work/200.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t200\n" > /probe/work/phase
printf "ASWR_STEP_END 200 "; cat /probe/work/200.json
printf "running\t201\n" > /probe/work/phase
printf "ASWR_STEP_START 201\n"
/probe/tool_timer /probe/input/201.sh /probe/work/201.json /app 900 > /probe/work/201.stdout 2> /probe/work/201.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t201\n" > /probe/work/phase
printf "ASWR_STEP_END 201 "; cat /probe/work/201.json
printf "running\t202\n" > /probe/work/phase
printf "ASWR_STEP_START 202\n"
/probe/tool_timer /probe/input/202.sh /probe/work/202.json /app 900 > /probe/work/202.stdout 2> /probe/work/202.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t202\n" > /probe/work/phase
printf "ASWR_STEP_END 202 "; cat /probe/work/202.json
printf "running\t203\n" > /probe/work/phase
printf "ASWR_STEP_START 203\n"
/probe/tool_timer /probe/input/203.sh /probe/work/203.json /app 900 > /probe/work/203.stdout 2> /probe/work/203.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t203\n" > /probe/work/phase
printf "ASWR_STEP_END 203 "; cat /probe/work/203.json
printf "running\t204\n" > /probe/work/phase
printf "ASWR_STEP_START 204\n"
/probe/tool_timer /probe/input/204.sh /probe/work/204.json /app 900 > /probe/work/204.stdout 2> /probe/work/204.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t204\n" > /probe/work/phase
printf "ASWR_STEP_END 204 "; cat /probe/work/204.json
printf "running\t205\n" > /probe/work/phase
printf "ASWR_STEP_START 205\n"
/probe/tool_timer /probe/input/205.sh /probe/work/205.json /app 900 > /probe/work/205.stdout 2> /probe/work/205.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t205\n" > /probe/work/phase
printf "ASWR_STEP_END 205 "; cat /probe/work/205.json
printf "running\t206\n" > /probe/work/phase
printf "ASWR_STEP_START 206\n"
/probe/tool_timer /probe/input/206.sh /probe/work/206.json /app 900 > /probe/work/206.stdout 2> /probe/work/206.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t206\n" > /probe/work/phase
printf "ASWR_STEP_END 206 "; cat /probe/work/206.json
printf "running\t207\n" > /probe/work/phase
printf "ASWR_STEP_START 207\n"
/probe/tool_timer /probe/input/207.sh /probe/work/207.json /app 900 > /probe/work/207.stdout 2> /probe/work/207.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t207\n" > /probe/work/phase
printf "ASWR_STEP_END 207 "; cat /probe/work/207.json
printf "running\t208\n" > /probe/work/phase
printf "ASWR_STEP_START 208\n"
/probe/tool_timer /probe/input/208.sh /probe/work/208.json /app 900 > /probe/work/208.stdout 2> /probe/work/208.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t208\n" > /probe/work/phase
printf "ASWR_STEP_END 208 "; cat /probe/work/208.json
printf "running\t209\n" > /probe/work/phase
printf "ASWR_STEP_START 209\n"
/probe/tool_timer /probe/input/209.sh /probe/work/209.json /app 900 > /probe/work/209.stdout 2> /probe/work/209.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t209\n" > /probe/work/phase
printf "ASWR_STEP_END 209 "; cat /probe/work/209.json
printf "running\t210\n" > /probe/work/phase
printf "ASWR_STEP_START 210\n"
/probe/tool_timer /probe/input/210.sh /probe/work/210.json /app 900 > /probe/work/210.stdout 2> /probe/work/210.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t210\n" > /probe/work/phase
printf "ASWR_STEP_END 210 "; cat /probe/work/210.json
printf "running\t211\n" > /probe/work/phase
printf "ASWR_STEP_START 211\n"
/probe/tool_timer /probe/input/211.sh /probe/work/211.json /app 900 > /probe/work/211.stdout 2> /probe/work/211.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t211\n" > /probe/work/phase
printf "ASWR_STEP_END 211 "; cat /probe/work/211.json
printf "running\t212\n" > /probe/work/phase
printf "ASWR_STEP_START 212\n"
/probe/tool_timer /probe/input/212.sh /probe/work/212.json /app 900 > /probe/work/212.stdout 2> /probe/work/212.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t212\n" > /probe/work/phase
printf "ASWR_STEP_END 212 "; cat /probe/work/212.json
printf "running\t213\n" > /probe/work/phase
printf "ASWR_STEP_START 213\n"
/probe/tool_timer /probe/input/213.sh /probe/work/213.json /app 900 > /probe/work/213.stdout 2> /probe/work/213.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t213\n" > /probe/work/phase
printf "ASWR_STEP_END 213 "; cat /probe/work/213.json
printf "running\t214\n" > /probe/work/phase
printf "ASWR_STEP_START 214\n"
/probe/tool_timer /probe/input/214.sh /probe/work/214.json /app 900 > /probe/work/214.stdout 2> /probe/work/214.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t214\n" > /probe/work/phase
printf "ASWR_STEP_END 214 "; cat /probe/work/214.json
printf "running\t215\n" > /probe/work/phase
printf "ASWR_STEP_START 215\n"
/probe/tool_timer /probe/input/215.sh /probe/work/215.json /app 900 > /probe/work/215.stdout 2> /probe/work/215.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t215\n" > /probe/work/phase
printf "ASWR_STEP_END 215 "; cat /probe/work/215.json
printf "running\t216\n" > /probe/work/phase
printf "ASWR_STEP_START 216\n"
/probe/tool_timer /probe/input/216.sh /probe/work/216.json /app 900 > /probe/work/216.stdout 2> /probe/work/216.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t216\n" > /probe/work/phase
printf "ASWR_STEP_END 216 "; cat /probe/work/216.json
printf "running\t217\n" > /probe/work/phase
printf "ASWR_STEP_START 217\n"
/probe/tool_timer /probe/input/217.sh /probe/work/217.json /app 900 > /probe/work/217.stdout 2> /probe/work/217.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t217\n" > /probe/work/phase
printf "ASWR_STEP_END 217 "; cat /probe/work/217.json
printf "running\t218\n" > /probe/work/phase
printf "ASWR_STEP_START 218\n"
/probe/tool_timer /probe/input/218.sh /probe/work/218.json /app 900 > /probe/work/218.stdout 2> /probe/work/218.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t218\n" > /probe/work/phase
printf "ASWR_STEP_END 218 "; cat /probe/work/218.json
printf "running\t219\n" > /probe/work/phase
printf "ASWR_STEP_START 219\n"
/probe/tool_timer /probe/input/219.sh /probe/work/219.json /app 900 > /probe/work/219.stdout 2> /probe/work/219.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t219\n" > /probe/work/phase
printf "ASWR_STEP_END 219 "; cat /probe/work/219.json
printf "running\t220\n" > /probe/work/phase
printf "ASWR_STEP_START 220\n"
/probe/tool_timer /probe/input/220.sh /probe/work/220.json /app 900 > /probe/work/220.stdout 2> /probe/work/220.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t220\n" > /probe/work/phase
printf "ASWR_STEP_END 220 "; cat /probe/work/220.json
printf "running\t221\n" > /probe/work/phase
printf "ASWR_STEP_START 221\n"
/probe/tool_timer /probe/input/221.sh /probe/work/221.json /app 900 > /probe/work/221.stdout 2> /probe/work/221.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t221\n" > /probe/work/phase
printf "ASWR_STEP_END 221 "; cat /probe/work/221.json
printf "running\t222\n" > /probe/work/phase
printf "ASWR_STEP_START 222\n"
/probe/tool_timer /probe/input/222.sh /probe/work/222.json /app 900 > /probe/work/222.stdout 2> /probe/work/222.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t222\n" > /probe/work/phase
printf "ASWR_STEP_END 222 "; cat /probe/work/222.json
printf "running\t223\n" > /probe/work/phase
printf "ASWR_STEP_START 223\n"
/probe/tool_timer /probe/input/223.sh /probe/work/223.json /app 900 > /probe/work/223.stdout 2> /probe/work/223.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t223\n" > /probe/work/phase
printf "ASWR_STEP_END 223 "; cat /probe/work/223.json
printf "running\t224\n" > /probe/work/phase
printf "ASWR_STEP_START 224\n"
/probe/tool_timer /probe/input/224.sh /probe/work/224.json /app 900 > /probe/work/224.stdout 2> /probe/work/224.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t224\n" > /probe/work/phase
printf "ASWR_STEP_END 224 "; cat /probe/work/224.json
printf "running\t225\n" > /probe/work/phase
printf "ASWR_STEP_START 225\n"
/probe/tool_timer /probe/input/225.sh /probe/work/225.json /app 900 > /probe/work/225.stdout 2> /probe/work/225.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t225\n" > /probe/work/phase
printf "ASWR_STEP_END 225 "; cat /probe/work/225.json
printf "running\t226\n" > /probe/work/phase
printf "ASWR_STEP_START 226\n"
/probe/tool_timer /probe/input/226.sh /probe/work/226.json /app 900 > /probe/work/226.stdout 2> /probe/work/226.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t226\n" > /probe/work/phase
printf "ASWR_STEP_END 226 "; cat /probe/work/226.json
printf "running\t227\n" > /probe/work/phase
printf "ASWR_STEP_START 227\n"
/probe/tool_timer /probe/input/227.sh /probe/work/227.json /app 900 > /probe/work/227.stdout 2> /probe/work/227.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t227\n" > /probe/work/phase
printf "ASWR_STEP_END 227 "; cat /probe/work/227.json
printf "running\t228\n" > /probe/work/phase
printf "ASWR_STEP_START 228\n"
/probe/tool_timer /probe/input/228.sh /probe/work/228.json /app 900 > /probe/work/228.stdout 2> /probe/work/228.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t228\n" > /probe/work/phase
printf "ASWR_STEP_END 228 "; cat /probe/work/228.json
printf "running\t229\n" > /probe/work/phase
printf "ASWR_STEP_START 229\n"
/probe/tool_timer /probe/input/229.sh /probe/work/229.json /app 900 > /probe/work/229.stdout 2> /probe/work/229.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t229\n" > /probe/work/phase
printf "ASWR_STEP_END 229 "; cat /probe/work/229.json
printf "running\t230\n" > /probe/work/phase
printf "ASWR_STEP_START 230\n"
/probe/tool_timer /probe/input/230.sh /probe/work/230.json /app 900 > /probe/work/230.stdout 2> /probe/work/230.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t230\n" > /probe/work/phase
printf "ASWR_STEP_END 230 "; cat /probe/work/230.json
printf "running\t231\n" > /probe/work/phase
printf "ASWR_STEP_START 231\n"
/probe/tool_timer /probe/input/231.sh /probe/work/231.json /app 900 > /probe/work/231.stdout 2> /probe/work/231.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t231\n" > /probe/work/phase
printf "ASWR_STEP_END 231 "; cat /probe/work/231.json
printf "running\t232\n" > /probe/work/phase
printf "ASWR_STEP_START 232\n"
/probe/tool_timer /probe/input/232.sh /probe/work/232.json /app 900 > /probe/work/232.stdout 2> /probe/work/232.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t232\n" > /probe/work/phase
printf "ASWR_STEP_END 232 "; cat /probe/work/232.json
printf "running\t233\n" > /probe/work/phase
printf "ASWR_STEP_START 233\n"
/probe/tool_timer /probe/input/233.sh /probe/work/233.json /app 900 > /probe/work/233.stdout 2> /probe/work/233.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t233\n" > /probe/work/phase
printf "ASWR_STEP_END 233 "; cat /probe/work/233.json
printf "running\t234\n" > /probe/work/phase
printf "ASWR_STEP_START 234\n"
/probe/tool_timer /probe/input/234.sh /probe/work/234.json /app 900 > /probe/work/234.stdout 2> /probe/work/234.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t234\n" > /probe/work/phase
printf "ASWR_STEP_END 234 "; cat /probe/work/234.json
printf "running\t235\n" > /probe/work/phase
printf "ASWR_STEP_START 235\n"
/probe/tool_timer /probe/input/235.sh /probe/work/235.json /app 900 > /probe/work/235.stdout 2> /probe/work/235.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t235\n" > /probe/work/phase
printf "ASWR_STEP_END 235 "; cat /probe/work/235.json
printf "running\t236\n" > /probe/work/phase
printf "ASWR_STEP_START 236\n"
/probe/tool_timer /probe/input/236.sh /probe/work/236.json /app 900 > /probe/work/236.stdout 2> /probe/work/236.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t236\n" > /probe/work/phase
printf "ASWR_STEP_END 236 "; cat /probe/work/236.json
printf "running\t237\n" > /probe/work/phase
printf "ASWR_STEP_START 237\n"
/probe/tool_timer /probe/input/237.sh /probe/work/237.json /app 900 > /probe/work/237.stdout 2> /probe/work/237.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t237\n" > /probe/work/phase
printf "ASWR_STEP_END 237 "; cat /probe/work/237.json
printf "running\t238\n" > /probe/work/phase
printf "ASWR_STEP_START 238\n"
/probe/tool_timer /probe/input/238.sh /probe/work/238.json /app 900 > /probe/work/238.stdout 2> /probe/work/238.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t238\n" > /probe/work/phase
printf "ASWR_STEP_END 238 "; cat /probe/work/238.json
printf "running\t239\n" > /probe/work/phase
printf "ASWR_STEP_START 239\n"
/probe/tool_timer /probe/input/239.sh /probe/work/239.json /app 900 > /probe/work/239.stdout 2> /probe/work/239.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t239\n" > /probe/work/phase
printf "ASWR_STEP_END 239 "; cat /probe/work/239.json
printf "running\t240\n" > /probe/work/phase
printf "ASWR_STEP_START 240\n"
/probe/tool_timer /probe/input/240.sh /probe/work/240.json /app 900 > /probe/work/240.stdout 2> /probe/work/240.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t240\n" > /probe/work/phase
printf "ASWR_STEP_END 240 "; cat /probe/work/240.json
printf "running\t241\n" > /probe/work/phase
printf "ASWR_STEP_START 241\n"
/probe/tool_timer /probe/input/241.sh /probe/work/241.json /app 3600 > /probe/work/241.stdout 2> /probe/work/241.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t241\n" > /probe/work/phase
printf "ASWR_STEP_END 241 "; cat /probe/work/241.json
printf "running\t242\n" > /probe/work/phase
printf "ASWR_STEP_START 242\n"
/probe/tool_timer /probe/input/242.sh /probe/work/242.json /app 900 > /probe/work/242.stdout 2> /probe/work/242.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t242\n" > /probe/work/phase
printf "ASWR_STEP_END 242 "; cat /probe/work/242.json
printf "running\t243\n" > /probe/work/phase
printf "ASWR_STEP_START 243\n"
/probe/tool_timer /probe/input/243.sh /probe/work/243.json /app 900 > /probe/work/243.stdout 2> /probe/work/243.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t243\n" > /probe/work/phase
printf "ASWR_STEP_END 243 "; cat /probe/work/243.json
printf "running\t244\n" > /probe/work/phase
printf "ASWR_STEP_START 244\n"
/probe/tool_timer /probe/input/244.sh /probe/work/244.json /app 900 > /probe/work/244.stdout 2> /probe/work/244.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t244\n" > /probe/work/phase
printf "ASWR_STEP_END 244 "; cat /probe/work/244.json
printf "async_dependency_wait\t245\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-241.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":241,"before_tool_step":245,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-241.done)" >> /probe/work/async-barriers.jsonl
printf "running\t245\n" > /probe/work/phase
printf "ASWR_STEP_START 245\n"
/probe/tool_timer /probe/input/245.sh /probe/work/245.json /app 900 > /probe/work/245.stdout 2> /probe/work/245.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t245\n" > /probe/work/phase
printf "ASWR_STEP_END 245 "; cat /probe/work/245.json
printf "running\t246\n" > /probe/work/phase
printf "ASWR_STEP_START 246\n"
/probe/tool_timer /probe/input/246.sh /probe/work/246.json /app 900 > /probe/work/246.stdout 2> /probe/work/246.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t246\n" > /probe/work/phase
printf "ASWR_STEP_END 246 "; cat /probe/work/246.json
printf "running\t247\n" > /probe/work/phase
printf "ASWR_STEP_START 247\n"
/probe/tool_timer /probe/input/247.sh /probe/work/247.json /app 900 > /probe/work/247.stdout 2> /probe/work/247.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t247\n" > /probe/work/phase
printf "ASWR_STEP_END 247 "; cat /probe/work/247.json
printf "running\t248\n" > /probe/work/phase
printf "ASWR_STEP_START 248\n"
/probe/tool_timer /probe/input/248.sh /probe/work/248.json /app 900 > /probe/work/248.stdout 2> /probe/work/248.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t248\n" > /probe/work/phase
printf "ASWR_STEP_END 248 "; cat /probe/work/248.json
printf "running\t249\n" > /probe/work/phase
printf "ASWR_STEP_START 249\n"
/probe/tool_timer /probe/input/249.sh /probe/work/249.json /app 900 > /probe/work/249.stdout 2> /probe/work/249.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t249\n" > /probe/work/phase
printf "ASWR_STEP_END 249 "; cat /probe/work/249.json
printf "running\t250\n" > /probe/work/phase
printf "ASWR_STEP_START 250\n"
/probe/tool_timer /probe/input/250.sh /probe/work/250.json /app 900 > /probe/work/250.stdout 2> /probe/work/250.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t250\n" > /probe/work/phase
printf "ASWR_STEP_END 250 "; cat /probe/work/250.json
printf "running\t251\n" > /probe/work/phase
printf "ASWR_STEP_START 251\n"
/probe/tool_timer /probe/input/251.sh /probe/work/251.json /app 900 > /probe/work/251.stdout 2> /probe/work/251.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t251\n" > /probe/work/phase
printf "ASWR_STEP_END 251 "; cat /probe/work/251.json
printf "running\t252\n" > /probe/work/phase
printf "ASWR_STEP_START 252\n"
/probe/tool_timer /probe/input/252.sh /probe/work/252.json /app 900 > /probe/work/252.stdout 2> /probe/work/252.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t252\n" > /probe/work/phase
printf "ASWR_STEP_END 252 "; cat /probe/work/252.json
printf "running\t253\n" > /probe/work/phase
printf "ASWR_STEP_START 253\n"
/probe/tool_timer /probe/input/253.sh /probe/work/253.json /app 900 > /probe/work/253.stdout 2> /probe/work/253.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t253\n" > /probe/work/phase
printf "ASWR_STEP_END 253 "; cat /probe/work/253.json
printf "running\t254\n" > /probe/work/phase
printf "ASWR_STEP_START 254\n"
/probe/tool_timer /probe/input/254.sh /probe/work/254.json /app 900 > /probe/work/254.stdout 2> /probe/work/254.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t254\n" > /probe/work/phase
printf "ASWR_STEP_END 254 "; cat /probe/work/254.json
printf "running\t255\n" > /probe/work/phase
printf "ASWR_STEP_START 255\n"
/probe/tool_timer /probe/input/255.sh /probe/work/255.json /app 900 > /probe/work/255.stdout 2> /probe/work/255.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t255\n" > /probe/work/phase
printf "ASWR_STEP_END 255 "; cat /probe/work/255.json
printf "running\t256\n" > /probe/work/phase
printf "ASWR_STEP_START 256\n"
/probe/tool_timer /probe/input/256.sh /probe/work/256.json /app 900 > /probe/work/256.stdout 2> /probe/work/256.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t256\n" > /probe/work/phase
printf "ASWR_STEP_END 256 "; cat /probe/work/256.json
printf "running\t257\n" > /probe/work/phase
printf "ASWR_STEP_START 257\n"
/probe/tool_timer /probe/input/257.sh /probe/work/257.json /app 900 > /probe/work/257.stdout 2> /probe/work/257.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t257\n" > /probe/work/phase
printf "ASWR_STEP_END 257 "; cat /probe/work/257.json
printf "running\t258\n" > /probe/work/phase
printf "ASWR_STEP_START 258\n"
/probe/tool_timer /probe/input/258.sh /probe/work/258.json /app 3600 > /probe/work/258.stdout 2> /probe/work/258.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t258\n" > /probe/work/phase
printf "ASWR_STEP_END 258 "; cat /probe/work/258.json
printf "running\t259\n" > /probe/work/phase
printf "ASWR_STEP_START 259\n"
/probe/tool_timer /probe/input/259.sh /probe/work/259.json /app 900 > /probe/work/259.stdout 2> /probe/work/259.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t259\n" > /probe/work/phase
printf "ASWR_STEP_END 259 "; cat /probe/work/259.json
printf "async_dependency_wait\t260\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-258.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":258,"before_tool_step":260,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-258.done)" >> /probe/work/async-barriers.jsonl
printf "running\t260\n" > /probe/work/phase
printf "ASWR_STEP_START 260\n"
/probe/tool_timer /probe/input/260.sh /probe/work/260.json /app 900 > /probe/work/260.stdout 2> /probe/work/260.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t260\n" > /probe/work/phase
printf "ASWR_STEP_END 260 "; cat /probe/work/260.json
printf "running\t261\n" > /probe/work/phase
printf "ASWR_STEP_START 261\n"
/probe/tool_timer /probe/input/261.sh /probe/work/261.json /app 900 > /probe/work/261.stdout 2> /probe/work/261.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t261\n" > /probe/work/phase
printf "ASWR_STEP_END 261 "; cat /probe/work/261.json
printf "running\t262\n" > /probe/work/phase
printf "ASWR_STEP_START 262\n"
/probe/tool_timer /probe/input/262.sh /probe/work/262.json /app 900 > /probe/work/262.stdout 2> /probe/work/262.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t262\n" > /probe/work/phase
printf "ASWR_STEP_END 262 "; cat /probe/work/262.json
printf "running\t263\n" > /probe/work/phase
printf "ASWR_STEP_START 263\n"
/probe/tool_timer /probe/input/263.sh /probe/work/263.json /app 900 > /probe/work/263.stdout 2> /probe/work/263.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t263\n" > /probe/work/phase
printf "ASWR_STEP_END 263 "; cat /probe/work/263.json
printf "running\t264\n" > /probe/work/phase
printf "ASWR_STEP_START 264\n"
/probe/tool_timer /probe/input/264.sh /probe/work/264.json /app 900 > /probe/work/264.stdout 2> /probe/work/264.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t264\n" > /probe/work/phase
printf "ASWR_STEP_END 264 "; cat /probe/work/264.json
printf "running\t265\n" > /probe/work/phase
printf "ASWR_STEP_START 265\n"
/probe/tool_timer /probe/input/265.sh /probe/work/265.json /app 900 > /probe/work/265.stdout 2> /probe/work/265.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t265\n" > /probe/work/phase
printf "ASWR_STEP_END 265 "; cat /probe/work/265.json
printf "running\t266\n" > /probe/work/phase
printf "ASWR_STEP_START 266\n"
/probe/tool_timer /probe/input/266.sh /probe/work/266.json /app 900 > /probe/work/266.stdout 2> /probe/work/266.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t266\n" > /probe/work/phase
printf "ASWR_STEP_END 266 "; cat /probe/work/266.json
printf "running\t267\n" > /probe/work/phase
printf "ASWR_STEP_START 267\n"
/probe/tool_timer /probe/input/267.sh /probe/work/267.json /app 900 > /probe/work/267.stdout 2> /probe/work/267.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t267\n" > /probe/work/phase
printf "ASWR_STEP_END 267 "; cat /probe/work/267.json
printf "running\t268\n" > /probe/work/phase
printf "ASWR_STEP_START 268\n"
/probe/tool_timer /probe/input/268.sh /probe/work/268.json /app 900 > /probe/work/268.stdout 2> /probe/work/268.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t268\n" > /probe/work/phase
printf "ASWR_STEP_END 268 "; cat /probe/work/268.json
printf "running\t269\n" > /probe/work/phase
printf "ASWR_STEP_START 269\n"
/probe/tool_timer /probe/input/269.sh /probe/work/269.json /app 900 > /probe/work/269.stdout 2> /probe/work/269.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t269\n" > /probe/work/phase
printf "ASWR_STEP_END 269 "; cat /probe/work/269.json
printf "running\t270\n" > /probe/work/phase
printf "ASWR_STEP_START 270\n"
/probe/tool_timer /probe/input/270.sh /probe/work/270.json /app 900 > /probe/work/270.stdout 2> /probe/work/270.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t270\n" > /probe/work/phase
printf "ASWR_STEP_END 270 "; cat /probe/work/270.json
printf "running\t271\n" > /probe/work/phase
printf "ASWR_STEP_START 271\n"
/probe/tool_timer /probe/input/271.sh /probe/work/271.json /app 900 > /probe/work/271.stdout 2> /probe/work/271.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t271\n" > /probe/work/phase
printf "ASWR_STEP_END 271 "; cat /probe/work/271.json
printf "running\t272\n" > /probe/work/phase
printf "ASWR_STEP_START 272\n"
/probe/tool_timer /probe/input/272.sh /probe/work/272.json /app 900 > /probe/work/272.stdout 2> /probe/work/272.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t272\n" > /probe/work/phase
printf "ASWR_STEP_END 272 "; cat /probe/work/272.json
printf "running\t273\n" > /probe/work/phase
printf "ASWR_STEP_START 273\n"
/probe/tool_timer /probe/input/273.sh /probe/work/273.json /app 3600 > /probe/work/273.stdout 2> /probe/work/273.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t273\n" > /probe/work/phase
printf "ASWR_STEP_END 273 "; cat /probe/work/273.json
printf "running\t274\n" > /probe/work/phase
printf "ASWR_STEP_START 274\n"
/probe/tool_timer /probe/input/274.sh /probe/work/274.json /app 900 > /probe/work/274.stdout 2> /probe/work/274.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t274\n" > /probe/work/phase
printf "ASWR_STEP_END 274 "; cat /probe/work/274.json
printf "running\t275\n" > /probe/work/phase
printf "ASWR_STEP_START 275\n"
/probe/tool_timer /probe/input/275.sh /probe/work/275.json /app 900 > /probe/work/275.stdout 2> /probe/work/275.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t275\n" > /probe/work/phase
printf "ASWR_STEP_END 275 "; cat /probe/work/275.json
printf "async_dependency_wait\t276\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-273.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":273,"before_tool_step":276,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-273.done)" >> /probe/work/async-barriers.jsonl
printf "running\t276\n" > /probe/work/phase
printf "ASWR_STEP_START 276\n"
/probe/tool_timer /probe/input/276.sh /probe/work/276.json /app 3600 > /probe/work/276.stdout 2> /probe/work/276.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t276\n" > /probe/work/phase
printf "ASWR_STEP_END 276 "; cat /probe/work/276.json
printf "running\t277\n" > /probe/work/phase
printf "ASWR_STEP_START 277\n"
/probe/tool_timer /probe/input/277.sh /probe/work/277.json /app 900 > /probe/work/277.stdout 2> /probe/work/277.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t277\n" > /probe/work/phase
printf "ASWR_STEP_END 277 "; cat /probe/work/277.json
printf "async_dependency_wait\t278\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-276.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":276,"before_tool_step":278,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-276.done)" >> /probe/work/async-barriers.jsonl
printf "running\t278\n" > /probe/work/phase
printf "ASWR_STEP_START 278\n"
/probe/tool_timer /probe/input/278.sh /probe/work/278.json /app 900 > /probe/work/278.stdout 2> /probe/work/278.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t278\n" > /probe/work/phase
printf "ASWR_STEP_END 278 "; cat /probe/work/278.json
printf "running\t279\n" > /probe/work/phase
printf "ASWR_STEP_START 279\n"
/probe/tool_timer /probe/input/279.sh /probe/work/279.json /app 900 > /probe/work/279.stdout 2> /probe/work/279.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t279\n" > /probe/work/phase
printf "ASWR_STEP_END 279 "; cat /probe/work/279.json
printf "running\t280\n" > /probe/work/phase
printf "ASWR_STEP_START 280\n"
/probe/tool_timer /probe/input/280.sh /probe/work/280.json /app 900 > /probe/work/280.stdout 2> /probe/work/280.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t280\n" > /probe/work/phase
printf "ASWR_STEP_END 280 "; cat /probe/work/280.json
printf "running\t281\n" > /probe/work/phase
printf "ASWR_STEP_START 281\n"
/probe/tool_timer /probe/input/281.sh /probe/work/281.json /app 900 > /probe/work/281.stdout 2> /probe/work/281.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t281\n" > /probe/work/phase
printf "ASWR_STEP_END 281 "; cat /probe/work/281.json
printf "running\t282\n" > /probe/work/phase
printf "ASWR_STEP_START 282\n"
/probe/tool_timer /probe/input/282.sh /probe/work/282.json /app 900 > /probe/work/282.stdout 2> /probe/work/282.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t282\n" > /probe/work/phase
printf "ASWR_STEP_END 282 "; cat /probe/work/282.json
printf "running\t283\n" > /probe/work/phase
printf "ASWR_STEP_START 283\n"
/probe/tool_timer /probe/input/283.sh /probe/work/283.json /app 900 > /probe/work/283.stdout 2> /probe/work/283.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t283\n" > /probe/work/phase
printf "ASWR_STEP_END 283 "; cat /probe/work/283.json
printf "running\t284\n" > /probe/work/phase
printf "ASWR_STEP_START 284\n"
/probe/tool_timer /probe/input/284.sh /probe/work/284.json /app 900 > /probe/work/284.stdout 2> /probe/work/284.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t284\n" > /probe/work/phase
printf "ASWR_STEP_END 284 "; cat /probe/work/284.json
printf "running\t285\n" > /probe/work/phase
printf "ASWR_STEP_START 285\n"
/probe/tool_timer /probe/input/285.sh /probe/work/285.json /app 900 > /probe/work/285.stdout 2> /probe/work/285.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t285\n" > /probe/work/phase
printf "ASWR_STEP_END 285 "; cat /probe/work/285.json
printf "running\t286\n" > /probe/work/phase
printf "ASWR_STEP_START 286\n"
/probe/tool_timer /probe/input/286.sh /probe/work/286.json /app 900 > /probe/work/286.stdout 2> /probe/work/286.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t286\n" > /probe/work/phase
printf "ASWR_STEP_END 286 "; cat /probe/work/286.json
printf "running\t287\n" > /probe/work/phase
printf "ASWR_STEP_START 287\n"
/probe/tool_timer /probe/input/287.sh /probe/work/287.json /app 900 > /probe/work/287.stdout 2> /probe/work/287.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t287\n" > /probe/work/phase
printf "ASWR_STEP_END 287 "; cat /probe/work/287.json
printf "running\t288\n" > /probe/work/phase
printf "ASWR_STEP_START 288\n"
/probe/tool_timer /probe/input/288.sh /probe/work/288.json /app 900 > /probe/work/288.stdout 2> /probe/work/288.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t288\n" > /probe/work/phase
printf "ASWR_STEP_END 288 "; cat /probe/work/288.json
printf "running\t289\n" > /probe/work/phase
printf "ASWR_STEP_START 289\n"
/probe/tool_timer /probe/input/289.sh /probe/work/289.json /app 900 > /probe/work/289.stdout 2> /probe/work/289.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t289\n" > /probe/work/phase
printf "ASWR_STEP_END 289 "; cat /probe/work/289.json
printf "running\t290\n" > /probe/work/phase
printf "ASWR_STEP_START 290\n"
/probe/tool_timer /probe/input/290.sh /probe/work/290.json /app 900 > /probe/work/290.stdout 2> /probe/work/290.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t290\n" > /probe/work/phase
printf "ASWR_STEP_END 290 "; cat /probe/work/290.json
printf "running\t291\n" > /probe/work/phase
printf "ASWR_STEP_START 291\n"
/probe/tool_timer /probe/input/291.sh /probe/work/291.json /app 900 > /probe/work/291.stdout 2> /probe/work/291.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t291\n" > /probe/work/phase
printf "ASWR_STEP_END 291 "; cat /probe/work/291.json
printf "running\t292\n" > /probe/work/phase
printf "ASWR_STEP_START 292\n"
/probe/tool_timer /probe/input/292.sh /probe/work/292.json /app 900 > /probe/work/292.stdout 2> /probe/work/292.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t292\n" > /probe/work/phase
printf "ASWR_STEP_END 292 "; cat /probe/work/292.json
printf "running\t293\n" > /probe/work/phase
printf "ASWR_STEP_START 293\n"
/probe/tool_timer /probe/input/293.sh /probe/work/293.json /app 900 > /probe/work/293.stdout 2> /probe/work/293.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t293\n" > /probe/work/phase
printf "ASWR_STEP_END 293 "; cat /probe/work/293.json
printf "running\t294\n" > /probe/work/phase
printf "ASWR_STEP_START 294\n"
/probe/tool_timer /probe/input/294.sh /probe/work/294.json /app 900 > /probe/work/294.stdout 2> /probe/work/294.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t294\n" > /probe/work/phase
printf "ASWR_STEP_END 294 "; cat /probe/work/294.json
printf "running\t295\n" > /probe/work/phase
printf "ASWR_STEP_START 295\n"
/probe/tool_timer /probe/input/295.sh /probe/work/295.json /app 900 > /probe/work/295.stdout 2> /probe/work/295.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t295\n" > /probe/work/phase
printf "ASWR_STEP_END 295 "; cat /probe/work/295.json
printf "running\t296\n" > /probe/work/phase
printf "ASWR_STEP_START 296\n"
/probe/tool_timer /probe/input/296.sh /probe/work/296.json /app 900 > /probe/work/296.stdout 2> /probe/work/296.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t296\n" > /probe/work/phase
printf "ASWR_STEP_END 296 "; cat /probe/work/296.json
printf "running\t297\n" > /probe/work/phase
printf "ASWR_STEP_START 297\n"
/probe/tool_timer /probe/input/297.sh /probe/work/297.json /app 900 > /probe/work/297.stdout 2> /probe/work/297.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t297\n" > /probe/work/phase
printf "ASWR_STEP_END 297 "; cat /probe/work/297.json
printf "running\t298\n" > /probe/work/phase
printf "ASWR_STEP_START 298\n"
/probe/tool_timer /probe/input/298.sh /probe/work/298.json /app 900 > /probe/work/298.stdout 2> /probe/work/298.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t298\n" > /probe/work/phase
printf "ASWR_STEP_END 298 "; cat /probe/work/298.json
printf "running\t299\n" > /probe/work/phase
printf "ASWR_STEP_START 299\n"
/probe/tool_timer /probe/input/299.sh /probe/work/299.json /app 3600 > /probe/work/299.stdout 2> /probe/work/299.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t299\n" > /probe/work/phase
printf "ASWR_STEP_END 299 "; cat /probe/work/299.json
printf "running\t300\n" > /probe/work/phase
printf "ASWR_STEP_START 300\n"
/probe/tool_timer /probe/input/300.sh /probe/work/300.json /app 900 > /probe/work/300.stdout 2> /probe/work/300.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t300\n" > /probe/work/phase
printf "ASWR_STEP_END 300 "; cat /probe/work/300.json
printf "running\t301\n" > /probe/work/phase
printf "ASWR_STEP_START 301\n"
/probe/tool_timer /probe/input/301.sh /probe/work/301.json /app 900 > /probe/work/301.stdout 2> /probe/work/301.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t301\n" > /probe/work/phase
printf "ASWR_STEP_END 301 "; cat /probe/work/301.json
printf "running\t302\n" > /probe/work/phase
printf "ASWR_STEP_START 302\n"
/probe/tool_timer /probe/input/302.sh /probe/work/302.json /app 900 > /probe/work/302.stdout 2> /probe/work/302.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t302\n" > /probe/work/phase
printf "ASWR_STEP_END 302 "; cat /probe/work/302.json
printf "running\t303\n" > /probe/work/phase
printf "ASWR_STEP_START 303\n"
/probe/tool_timer /probe/input/303.sh /probe/work/303.json /app 900 > /probe/work/303.stdout 2> /probe/work/303.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t303\n" > /probe/work/phase
printf "ASWR_STEP_END 303 "; cat /probe/work/303.json
printf "async_dependency_wait\t304\n" > /probe/work/phase
ASWR_WAIT_START=$(/probe/clock_ns)
while ! test -f /probe/work/async-299.done; do sleep .2; done
ASWR_WAIT_END=$(/probe/clock_ns)
printf '{"source_async_step":299,"before_tool_step":304,"started_ns":%s,"finished_ns":%s,"job_exit_code":%s}\n' "$ASWR_WAIT_START" "$ASWR_WAIT_END" "$(cat /probe/work/async-299.done)" >> /probe/work/async-barriers.jsonl
printf "running\t304\n" > /probe/work/phase
printf "ASWR_STEP_START 304\n"
/probe/tool_timer /probe/input/304.sh /probe/work/304.json /app 900 > /probe/work/304.stdout 2> /probe/work/304.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t304\n" > /probe/work/phase
printf "ASWR_STEP_END 304 "; cat /probe/work/304.json
printf "running\t305\n" > /probe/work/phase
printf "ASWR_STEP_START 305\n"
/probe/tool_timer /probe/input/305.sh /probe/work/305.json /app 900 > /probe/work/305.stdout 2> /probe/work/305.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t305\n" > /probe/work/phase
printf "ASWR_STEP_END 305 "; cat /probe/work/305.json
printf "running\t306\n" > /probe/work/phase
printf "ASWR_STEP_START 306\n"
/probe/tool_timer /probe/input/306.sh /probe/work/306.json /app 900 > /probe/work/306.stdout 2> /probe/work/306.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t306\n" > /probe/work/phase
printf "ASWR_STEP_END 306 "; cat /probe/work/306.json
printf "running\t307\n" > /probe/work/phase
printf "ASWR_STEP_START 307\n"
/probe/tool_timer /probe/input/307.sh /probe/work/307.json /app 900 > /probe/work/307.stdout 2> /probe/work/307.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t307\n" > /probe/work/phase
printf "ASWR_STEP_END 307 "; cat /probe/work/307.json
printf "running\t308\n" > /probe/work/phase
printf "ASWR_STEP_START 308\n"
/probe/tool_timer /probe/input/308.sh /probe/work/308.json /app 900 > /probe/work/308.stdout 2> /probe/work/308.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t308\n" > /probe/work/phase
printf "ASWR_STEP_END 308 "; cat /probe/work/308.json
printf "running\t309\n" > /probe/work/phase
printf "ASWR_STEP_START 309\n"
/probe/tool_timer /probe/input/309.sh /probe/work/309.json /app 900 > /probe/work/309.stdout 2> /probe/work/309.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t309\n" > /probe/work/phase
printf "ASWR_STEP_END 309 "; cat /probe/work/309.json
printf "running\t310\n" > /probe/work/phase
printf "ASWR_STEP_START 310\n"
/probe/tool_timer /probe/input/310.sh /probe/work/310.json /app 900 > /probe/work/310.stdout 2> /probe/work/310.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t310\n" > /probe/work/phase
printf "ASWR_STEP_END 310 "; cat /probe/work/310.json
printf "running\t311\n" > /probe/work/phase
printf "ASWR_STEP_START 311\n"
/probe/tool_timer /probe/input/311.sh /probe/work/311.json /app 900 > /probe/work/311.stdout 2> /probe/work/311.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t311\n" > /probe/work/phase
printf "ASWR_STEP_END 311 "; cat /probe/work/311.json
printf "running\t312\n" > /probe/work/phase
printf "ASWR_STEP_START 312\n"
/probe/tool_timer /probe/input/312.sh /probe/work/312.json /app 900 > /probe/work/312.stdout 2> /probe/work/312.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t312\n" > /probe/work/phase
printf "ASWR_STEP_END 312 "; cat /probe/work/312.json
printf "running\t313\n" > /probe/work/phase
printf "ASWR_STEP_START 313\n"
/probe/tool_timer /probe/input/313.sh /probe/work/313.json /app 900 > /probe/work/313.stdout 2> /probe/work/313.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t313\n" > /probe/work/phase
printf "ASWR_STEP_END 313 "; cat /probe/work/313.json
printf "running\t314\n" > /probe/work/phase
printf "ASWR_STEP_START 314\n"
/probe/tool_timer /probe/input/314.sh /probe/work/314.json /app 900 > /probe/work/314.stdout 2> /probe/work/314.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t314\n" > /probe/work/phase
printf "ASWR_STEP_END 314 "; cat /probe/work/314.json
printf "running\t315\n" > /probe/work/phase
printf "ASWR_STEP_START 315\n"
/probe/tool_timer /probe/input/315.sh /probe/work/315.json /app 900 > /probe/work/315.stdout 2> /probe/work/315.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t315\n" > /probe/work/phase
printf "ASWR_STEP_END 315 "; cat /probe/work/315.json
printf "running\t316\n" > /probe/work/phase
printf "ASWR_STEP_START 316\n"
/probe/tool_timer /probe/input/316.sh /probe/work/316.json /app 900 > /probe/work/316.stdout 2> /probe/work/316.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t316\n" > /probe/work/phase
printf "ASWR_STEP_END 316 "; cat /probe/work/316.json
printf "running\t317\n" > /probe/work/phase
printf "ASWR_STEP_START 317\n"
/probe/tool_timer /probe/input/317.sh /probe/work/317.json /app 900 > /probe/work/317.stdout 2> /probe/work/317.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t317\n" > /probe/work/phase
printf "ASWR_STEP_END 317 "; cat /probe/work/317.json
printf "running\t318\n" > /probe/work/phase
printf "ASWR_STEP_START 318\n"
/probe/tool_timer /probe/input/318.sh /probe/work/318.json /app 900 > /probe/work/318.stdout 2> /probe/work/318.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t318\n" > /probe/work/phase
printf "ASWR_STEP_END 318 "; cat /probe/work/318.json
printf "cache_scan\t318\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /tmp/CompCert /tmp/coq-8.16.1 /usr/local/lib /app > /probe/work/boundary-318.json
printf "complete\t318\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
