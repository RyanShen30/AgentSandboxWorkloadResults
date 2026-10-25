#!/bin/bash
set +e
umask 077
cd /testbed || exit 91
touch /probe/work/worker-ready
while IFS= read -r ASWR_STEP <&198; do
case "$ASWR_STEP" in
QUIT) exit 0 ;;
1)
/probe/tool_timer /probe/input/001.sh /probe/work/001.json /testbed 900 > /probe/work/001.stdout 2> /probe/work/001.stderr
test "$?" -eq 0 || exit 92
printf "1\n" >&199
;;
2)
/probe/tool_timer /probe/input/002.sh /probe/work/002.json /testbed 900 > /probe/work/002.stdout 2> /probe/work/002.stderr
test "$?" -eq 0 || exit 92
printf "2\n" >&199
;;
3)
/probe/tool_timer /probe/input/003.sh /probe/work/003.json /testbed 900 > /probe/work/003.stdout 2> /probe/work/003.stderr
test "$?" -eq 0 || exit 92
printf "3\n" >&199
;;
4)
/probe/tool_timer /probe/input/004.sh /probe/work/004.json /testbed 900 > /probe/work/004.stdout 2> /probe/work/004.stderr
test "$?" -eq 0 || exit 92
printf "4\n" >&199
;;
5)
/probe/tool_timer /probe/input/005.sh /probe/work/005.json /testbed 900 > /probe/work/005.stdout 2> /probe/work/005.stderr
test "$?" -eq 0 || exit 92
printf "5\n" >&199
;;
*) exit 96 ;;
esac
done
exit 97
