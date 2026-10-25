#!/bin/bash
set +e
umask 077
cd /app || exit 91
touch /probe/work/worker-ready
while IFS= read -r ASWR_STEP <&198; do
case "$ASWR_STEP" in
QUIT) exit 0 ;;
1)
/probe/tool_timer /probe/input/001.sh /probe/work/001.json /app 900 > /probe/work/001.stdout 2> /probe/work/001.stderr
test "$?" -eq 0 || exit 92
printf "1\n" >&199
;;
2)
/probe/tool_timer /probe/input/002.sh /probe/work/002.json /app 900 > /probe/work/002.stdout 2> /probe/work/002.stderr
test "$?" -eq 0 || exit 92
printf "2\n" >&199
;;
3)
/probe/tool_timer /probe/input/003.sh /probe/work/003.json /app 900 > /probe/work/003.stdout 2> /probe/work/003.stderr
test "$?" -eq 0 || exit 92
printf "3\n" >&199
;;
4)
/probe/tool_timer /probe/input/004.sh /probe/work/004.json /app 900 > /probe/work/004.stdout 2> /probe/work/004.stderr
test "$?" -eq 0 || exit 92
printf "4\n" >&199
;;
5)
/probe/tool_timer /probe/input/005.sh /probe/work/005.json /app 900 > /probe/work/005.stdout 2> /probe/work/005.stderr
test "$?" -eq 0 || exit 92
printf "5\n" >&199
;;
6)
/probe/tool_timer /probe/input/006.sh /probe/work/006.json /app 900 > /probe/work/006.stdout 2> /probe/work/006.stderr
test "$?" -eq 0 || exit 92
printf "6\n" >&199
;;
7)
/probe/tool_timer /probe/input/007.sh /probe/work/007.json /app 900 > /probe/work/007.stdout 2> /probe/work/007.stderr
test "$?" -eq 0 || exit 92
printf "7\n" >&199
;;
8)
/probe/tool_timer /probe/input/008.sh /probe/work/008.json /app 900 > /probe/work/008.stdout 2> /probe/work/008.stderr
test "$?" -eq 0 || exit 92
printf "8\n" >&199
;;
9)
/probe/tool_timer /probe/input/009.sh /probe/work/009.json /app 900 > /probe/work/009.stdout 2> /probe/work/009.stderr
test "$?" -eq 0 || exit 92
printf "9\n" >&199
;;
10)
/probe/tool_timer /probe/input/010.sh /probe/work/010.json /app 900 > /probe/work/010.stdout 2> /probe/work/010.stderr
test "$?" -eq 0 || exit 92
printf "10\n" >&199
;;
11)
/probe/tool_timer /probe/input/011.sh /probe/work/011.json /app 900 > /probe/work/011.stdout 2> /probe/work/011.stderr
test "$?" -eq 0 || exit 92
printf "11\n" >&199
;;
12)
/probe/tool_timer /probe/input/012.sh /probe/work/012.json /app 900 > /probe/work/012.stdout 2> /probe/work/012.stderr
test "$?" -eq 0 || exit 92
printf "12\n" >&199
;;
13)
/probe/tool_timer /probe/input/013.sh /probe/work/013.json /app 900 > /probe/work/013.stdout 2> /probe/work/013.stderr
test "$?" -eq 0 || exit 92
printf "13\n" >&199
;;
14)
/probe/tool_timer /probe/input/014.sh /probe/work/014.json /app 900 > /probe/work/014.stdout 2> /probe/work/014.stderr
test "$?" -eq 0 || exit 92
printf "14\n" >&199
;;
15)
/probe/tool_timer /probe/input/015.sh /probe/work/015.json /app 900 > /probe/work/015.stdout 2> /probe/work/015.stderr
test "$?" -eq 0 || exit 92
printf "15\n" >&199
;;
16)
/probe/tool_timer /probe/input/016.sh /probe/work/016.json /app 900 > /probe/work/016.stdout 2> /probe/work/016.stderr
test "$?" -eq 0 || exit 92
printf "16\n" >&199
;;
17)
/probe/tool_timer /probe/input/017.sh /probe/work/017.json /app 900 > /probe/work/017.stdout 2> /probe/work/017.stderr
test "$?" -eq 0 || exit 92
printf "17\n" >&199
;;
18)
/probe/tool_timer /probe/input/018.sh /probe/work/018.json /app 900 > /probe/work/018.stdout 2> /probe/work/018.stderr
test "$?" -eq 0 || exit 92
printf "18\n" >&199
;;
19)
/probe/tool_timer /probe/input/019.sh /probe/work/019.json /app 900 > /probe/work/019.stdout 2> /probe/work/019.stderr
test "$?" -eq 0 || exit 92
printf "19\n" >&199
;;
20)
/probe/tool_timer /probe/input/020.sh /probe/work/020.json /app 900 > /probe/work/020.stdout 2> /probe/work/020.stderr
test "$?" -eq 0 || exit 92
printf "20\n" >&199
;;
21)
/probe/tool_timer /probe/input/021.sh /probe/work/021.json /app 900 > /probe/work/021.stdout 2> /probe/work/021.stderr
test "$?" -eq 0 || exit 92
printf "21\n" >&199
;;
22)
/probe/tool_timer /probe/input/022.sh /probe/work/022.json /app 900 > /probe/work/022.stdout 2> /probe/work/022.stderr
test "$?" -eq 0 || exit 92
printf "22\n" >&199
;;
23)
/probe/tool_timer /probe/input/023.sh /probe/work/023.json /app 900 > /probe/work/023.stdout 2> /probe/work/023.stderr
test "$?" -eq 0 || exit 92
printf "23\n" >&199
;;
24)
/probe/tool_timer /probe/input/024.sh /probe/work/024.json /app 900 > /probe/work/024.stdout 2> /probe/work/024.stderr
test "$?" -eq 0 || exit 92
printf "24\n" >&199
;;
25)
/probe/tool_timer /probe/input/025.sh /probe/work/025.json /app 900 > /probe/work/025.stdout 2> /probe/work/025.stderr
test "$?" -eq 0 || exit 92
printf "25\n" >&199
;;
26)
/probe/tool_timer /probe/input/026.sh /probe/work/026.json /app 900 > /probe/work/026.stdout 2> /probe/work/026.stderr
test "$?" -eq 0 || exit 92
printf "26\n" >&199
;;
27)
/probe/tool_timer /probe/input/027.sh /probe/work/027.json /app 900 > /probe/work/027.stdout 2> /probe/work/027.stderr
test "$?" -eq 0 || exit 92
printf "27\n" >&199
;;
28)
/probe/tool_timer /probe/input/028.sh /probe/work/028.json /app 900 > /probe/work/028.stdout 2> /probe/work/028.stderr
test "$?" -eq 0 || exit 92
printf "28\n" >&199
;;
29)
/probe/tool_timer /probe/input/029.sh /probe/work/029.json /app 900 > /probe/work/029.stdout 2> /probe/work/029.stderr
test "$?" -eq 0 || exit 92
printf "29\n" >&199
;;
30)
/probe/tool_timer /probe/input/030.sh /probe/work/030.json /app 900 > /probe/work/030.stdout 2> /probe/work/030.stderr
test "$?" -eq 0 || exit 92
printf "30\n" >&199
;;
31)
/probe/tool_timer /probe/input/031.sh /probe/work/031.json /app 900 > /probe/work/031.stdout 2> /probe/work/031.stderr
test "$?" -eq 0 || exit 92
printf "31\n" >&199
;;
32)
/probe/tool_timer /probe/input/032.sh /probe/work/032.json /app 900 > /probe/work/032.stdout 2> /probe/work/032.stderr
test "$?" -eq 0 || exit 92
printf "32\n" >&199
;;
33)
/probe/tool_timer /probe/input/033.sh /probe/work/033.json /app 900 > /probe/work/033.stdout 2> /probe/work/033.stderr
test "$?" -eq 0 || exit 92
printf "33\n" >&199
;;
34)
/probe/tool_timer /probe/input/034.sh /probe/work/034.json /app 900 > /probe/work/034.stdout 2> /probe/work/034.stderr
test "$?" -eq 0 || exit 92
printf "34\n" >&199
;;
35)
/probe/tool_timer /probe/input/035.sh /probe/work/035.json /app 900 > /probe/work/035.stdout 2> /probe/work/035.stderr
test "$?" -eq 0 || exit 92
printf "35\n" >&199
;;
36)
/probe/tool_timer /probe/input/036.sh /probe/work/036.json /app 900 > /probe/work/036.stdout 2> /probe/work/036.stderr
test "$?" -eq 0 || exit 92
printf "36\n" >&199
;;
*) exit 96 ;;
esac
done
exit 97
