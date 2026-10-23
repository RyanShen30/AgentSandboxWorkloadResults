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
/probe/workload_probe scan /app/pyknotid /usr/local/lib /usr/include /root/.cache > /probe/work/boundary-000.json
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
/probe/tool_timer /probe/input/044.sh /probe/work/044.json /app 900 > /probe/work/044.stdout 2> /probe/work/044.stderr
ASWR_TRANSPORT=$?
test "$ASWR_TRANSPORT" -eq 0 || exit 92
printf "after\t44\n" > /probe/work/phase
printf "ASWR_STEP_END 44 "; cat /probe/work/044.json
printf "running\t45\n" > /probe/work/phase
printf "ASWR_STEP_START 45\n"
/probe/tool_timer /probe/input/045.sh /probe/work/045.json /app 900 > /probe/work/045.stdout 2> /probe/work/045.stderr
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
/probe/tool_timer /probe/input/070.sh /probe/work/070.json /app 900 > /probe/work/070.stdout 2> /probe/work/070.stderr
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
printf "cache_scan\t83\n" > /probe/work/phase
/probe/workload_probe snapshot > /probe/work/final.json
/probe/workload_probe scan /app/pyknotid /usr/local/lib /usr/include /root/.cache > /probe/work/boundary-083.json
printf "complete\t83\n" > /probe/work/phase
touch /probe/work/monitor-stop
wait "$ASWR_MONITOR_PID" || exit 93
printf "ASWR_MEASUREMENT_COMPLETE\n"
exit 0
