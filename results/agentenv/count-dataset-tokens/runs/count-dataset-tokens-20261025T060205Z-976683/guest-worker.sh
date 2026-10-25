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
*) exit 96 ;;
esac
done
exit 97
