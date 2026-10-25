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
6)
/probe/tool_timer /probe/input/006.sh /probe/work/006.json /testbed 900 > /probe/work/006.stdout 2> /probe/work/006.stderr
test "$?" -eq 0 || exit 92
printf "6\n" >&199
;;
7)
/probe/tool_timer /probe/input/007.sh /probe/work/007.json /testbed 900 > /probe/work/007.stdout 2> /probe/work/007.stderr
test "$?" -eq 0 || exit 92
printf "7\n" >&199
;;
8)
/probe/tool_timer /probe/input/008.sh /probe/work/008.json /testbed 900 > /probe/work/008.stdout 2> /probe/work/008.stderr
test "$?" -eq 0 || exit 92
printf "8\n" >&199
;;
9)
/probe/tool_timer /probe/input/009.sh /probe/work/009.json /testbed 900 > /probe/work/009.stdout 2> /probe/work/009.stderr
test "$?" -eq 0 || exit 92
printf "9\n" >&199
;;
10)
/probe/tool_timer /probe/input/010.sh /probe/work/010.json /testbed 900 > /probe/work/010.stdout 2> /probe/work/010.stderr
test "$?" -eq 0 || exit 92
printf "10\n" >&199
;;
11)
/probe/tool_timer /probe/input/011.sh /probe/work/011.json /testbed 900 > /probe/work/011.stdout 2> /probe/work/011.stderr
test "$?" -eq 0 || exit 92
printf "11\n" >&199
;;
12)
/probe/tool_timer /probe/input/012.sh /probe/work/012.json /testbed 900 > /probe/work/012.stdout 2> /probe/work/012.stderr
test "$?" -eq 0 || exit 92
printf "12\n" >&199
;;
13)
/probe/tool_timer /probe/input/013.sh /probe/work/013.json /testbed 900 > /probe/work/013.stdout 2> /probe/work/013.stderr
test "$?" -eq 0 || exit 92
printf "13\n" >&199
;;
14)
/probe/tool_timer /probe/input/014.sh /probe/work/014.json /testbed 900 > /probe/work/014.stdout 2> /probe/work/014.stderr
test "$?" -eq 0 || exit 92
printf "14\n" >&199
;;
15)
/probe/tool_timer /probe/input/015.sh /probe/work/015.json /testbed 900 > /probe/work/015.stdout 2> /probe/work/015.stderr
test "$?" -eq 0 || exit 92
printf "15\n" >&199
;;
16)
/probe/tool_timer /probe/input/016.sh /probe/work/016.json /testbed 900 > /probe/work/016.stdout 2> /probe/work/016.stderr
test "$?" -eq 0 || exit 92
printf "16\n" >&199
;;
17)
/probe/tool_timer /probe/input/017.sh /probe/work/017.json /testbed 900 > /probe/work/017.stdout 2> /probe/work/017.stderr
test "$?" -eq 0 || exit 92
printf "17\n" >&199
;;
18)
/probe/tool_timer /probe/input/018.sh /probe/work/018.json /testbed 900 > /probe/work/018.stdout 2> /probe/work/018.stderr
test "$?" -eq 0 || exit 92
printf "18\n" >&199
;;
19)
/probe/tool_timer /probe/input/019.sh /probe/work/019.json /testbed 900 > /probe/work/019.stdout 2> /probe/work/019.stderr
test "$?" -eq 0 || exit 92
printf "19\n" >&199
;;
20)
/probe/tool_timer /probe/input/020.sh /probe/work/020.json /testbed 900 > /probe/work/020.stdout 2> /probe/work/020.stderr
test "$?" -eq 0 || exit 92
printf "20\n" >&199
;;
21)
/probe/tool_timer /probe/input/021.sh /probe/work/021.json /testbed 900 > /probe/work/021.stdout 2> /probe/work/021.stderr
test "$?" -eq 0 || exit 92
printf "21\n" >&199
;;
22)
/probe/tool_timer /probe/input/022.sh /probe/work/022.json /testbed 900 > /probe/work/022.stdout 2> /probe/work/022.stderr
test "$?" -eq 0 || exit 92
printf "22\n" >&199
;;
23)
/probe/tool_timer /probe/input/023.sh /probe/work/023.json /testbed 900 > /probe/work/023.stdout 2> /probe/work/023.stderr
test "$?" -eq 0 || exit 92
printf "23\n" >&199
;;
24)
/probe/tool_timer /probe/input/024.sh /probe/work/024.json /testbed 900 > /probe/work/024.stdout 2> /probe/work/024.stderr
test "$?" -eq 0 || exit 92
printf "24\n" >&199
;;
25)
/probe/tool_timer /probe/input/025.sh /probe/work/025.json /testbed 900 > /probe/work/025.stdout 2> /probe/work/025.stderr
test "$?" -eq 0 || exit 92
printf "25\n" >&199
;;
26)
/probe/tool_timer /probe/input/026.sh /probe/work/026.json /testbed 900 > /probe/work/026.stdout 2> /probe/work/026.stderr
test "$?" -eq 0 || exit 92
printf "26\n" >&199
;;
27)
/probe/tool_timer /probe/input/027.sh /probe/work/027.json /testbed 900 > /probe/work/027.stdout 2> /probe/work/027.stderr
test "$?" -eq 0 || exit 92
printf "27\n" >&199
;;
28)
/probe/tool_timer /probe/input/028.sh /probe/work/028.json /testbed 900 > /probe/work/028.stdout 2> /probe/work/028.stderr
test "$?" -eq 0 || exit 92
printf "28\n" >&199
;;
29)
/probe/tool_timer /probe/input/029.sh /probe/work/029.json /testbed 900 > /probe/work/029.stdout 2> /probe/work/029.stderr
test "$?" -eq 0 || exit 92
printf "29\n" >&199
;;
30)
/probe/tool_timer /probe/input/030.sh /probe/work/030.json /testbed 900 > /probe/work/030.stdout 2> /probe/work/030.stderr
test "$?" -eq 0 || exit 92
printf "30\n" >&199
;;
31)
/probe/tool_timer /probe/input/031.sh /probe/work/031.json /testbed 900 > /probe/work/031.stdout 2> /probe/work/031.stderr
test "$?" -eq 0 || exit 92
printf "31\n" >&199
;;
32)
/probe/tool_timer /probe/input/032.sh /probe/work/032.json /testbed 900 > /probe/work/032.stdout 2> /probe/work/032.stderr
test "$?" -eq 0 || exit 92
printf "32\n" >&199
;;
33)
/probe/tool_timer /probe/input/033.sh /probe/work/033.json /testbed 900 > /probe/work/033.stdout 2> /probe/work/033.stderr
test "$?" -eq 0 || exit 92
printf "33\n" >&199
;;
34)
/probe/tool_timer /probe/input/034.sh /probe/work/034.json /testbed 900 > /probe/work/034.stdout 2> /probe/work/034.stderr
test "$?" -eq 0 || exit 92
printf "34\n" >&199
;;
35)
/probe/tool_timer /probe/input/035.sh /probe/work/035.json /testbed 900 > /probe/work/035.stdout 2> /probe/work/035.stderr
test "$?" -eq 0 || exit 92
printf "35\n" >&199
;;
36)
/probe/tool_timer /probe/input/036.sh /probe/work/036.json /testbed 900 > /probe/work/036.stdout 2> /probe/work/036.stderr
test "$?" -eq 0 || exit 92
printf "36\n" >&199
;;
37)
/probe/tool_timer /probe/input/037.sh /probe/work/037.json /testbed 900 > /probe/work/037.stdout 2> /probe/work/037.stderr
test "$?" -eq 0 || exit 92
printf "37\n" >&199
;;
38)
/probe/tool_timer /probe/input/038.sh /probe/work/038.json /testbed 900 > /probe/work/038.stdout 2> /probe/work/038.stderr
test "$?" -eq 0 || exit 92
printf "38\n" >&199
;;
39)
/probe/tool_timer /probe/input/039.sh /probe/work/039.json /testbed 900 > /probe/work/039.stdout 2> /probe/work/039.stderr
test "$?" -eq 0 || exit 92
printf "39\n" >&199
;;
40)
/probe/tool_timer /probe/input/040.sh /probe/work/040.json /testbed 900 > /probe/work/040.stdout 2> /probe/work/040.stderr
test "$?" -eq 0 || exit 92
printf "40\n" >&199
;;
41)
/probe/tool_timer /probe/input/041.sh /probe/work/041.json /testbed 900 > /probe/work/041.stdout 2> /probe/work/041.stderr
test "$?" -eq 0 || exit 92
printf "41\n" >&199
;;
42)
/probe/tool_timer /probe/input/042.sh /probe/work/042.json /testbed 900 > /probe/work/042.stdout 2> /probe/work/042.stderr
test "$?" -eq 0 || exit 92
printf "42\n" >&199
;;
43)
/probe/tool_timer /probe/input/043.sh /probe/work/043.json /testbed 900 > /probe/work/043.stdout 2> /probe/work/043.stderr
test "$?" -eq 0 || exit 92
printf "43\n" >&199
;;
44)
/probe/tool_timer /probe/input/044.sh /probe/work/044.json /testbed 900 > /probe/work/044.stdout 2> /probe/work/044.stderr
test "$?" -eq 0 || exit 92
printf "44\n" >&199
;;
45)
/probe/tool_timer /probe/input/045.sh /probe/work/045.json /testbed 900 > /probe/work/045.stdout 2> /probe/work/045.stderr
test "$?" -eq 0 || exit 92
printf "45\n" >&199
;;
46)
/probe/tool_timer /probe/input/046.sh /probe/work/046.json /testbed 900 > /probe/work/046.stdout 2> /probe/work/046.stderr
test "$?" -eq 0 || exit 92
printf "46\n" >&199
;;
47)
/probe/tool_timer /probe/input/047.sh /probe/work/047.json /testbed 900 > /probe/work/047.stdout 2> /probe/work/047.stderr
test "$?" -eq 0 || exit 92
printf "47\n" >&199
;;
48)
/probe/tool_timer /probe/input/048.sh /probe/work/048.json /testbed 900 > /probe/work/048.stdout 2> /probe/work/048.stderr
test "$?" -eq 0 || exit 92
printf "48\n" >&199
;;
49)
/probe/tool_timer /probe/input/049.sh /probe/work/049.json /testbed 900 > /probe/work/049.stdout 2> /probe/work/049.stderr
test "$?" -eq 0 || exit 92
printf "49\n" >&199
;;
50)
/probe/tool_timer /probe/input/050.sh /probe/work/050.json /testbed 900 > /probe/work/050.stdout 2> /probe/work/050.stderr
test "$?" -eq 0 || exit 92
printf "50\n" >&199
;;
51)
/probe/tool_timer /probe/input/051.sh /probe/work/051.json /testbed 900 > /probe/work/051.stdout 2> /probe/work/051.stderr
test "$?" -eq 0 || exit 92
printf "51\n" >&199
;;
52)
/probe/tool_timer /probe/input/052.sh /probe/work/052.json /testbed 900 > /probe/work/052.stdout 2> /probe/work/052.stderr
test "$?" -eq 0 || exit 92
printf "52\n" >&199
;;
53)
/probe/tool_timer /probe/input/053.sh /probe/work/053.json /testbed 900 > /probe/work/053.stdout 2> /probe/work/053.stderr
test "$?" -eq 0 || exit 92
printf "53\n" >&199
;;
54)
/probe/tool_timer /probe/input/054.sh /probe/work/054.json /testbed 900 > /probe/work/054.stdout 2> /probe/work/054.stderr
test "$?" -eq 0 || exit 92
printf "54\n" >&199
;;
55)
/probe/tool_timer /probe/input/055.sh /probe/work/055.json /testbed 900 > /probe/work/055.stdout 2> /probe/work/055.stderr
test "$?" -eq 0 || exit 92
printf "55\n" >&199
;;
56)
/probe/tool_timer /probe/input/056.sh /probe/work/056.json /testbed 900 > /probe/work/056.stdout 2> /probe/work/056.stderr
test "$?" -eq 0 || exit 92
printf "56\n" >&199
;;
57)
/probe/tool_timer /probe/input/057.sh /probe/work/057.json /testbed 900 > /probe/work/057.stdout 2> /probe/work/057.stderr
test "$?" -eq 0 || exit 92
printf "57\n" >&199
;;
58)
/probe/tool_timer /probe/input/058.sh /probe/work/058.json /testbed 900 > /probe/work/058.stdout 2> /probe/work/058.stderr
test "$?" -eq 0 || exit 92
printf "58\n" >&199
;;
59)
/probe/tool_timer /probe/input/059.sh /probe/work/059.json /testbed 900 > /probe/work/059.stdout 2> /probe/work/059.stderr
test "$?" -eq 0 || exit 92
printf "59\n" >&199
;;
60)
/probe/tool_timer /probe/input/060.sh /probe/work/060.json /testbed 900 > /probe/work/060.stdout 2> /probe/work/060.stderr
test "$?" -eq 0 || exit 92
printf "60\n" >&199
;;
61)
/probe/tool_timer /probe/input/061.sh /probe/work/061.json /testbed 900 > /probe/work/061.stdout 2> /probe/work/061.stderr
test "$?" -eq 0 || exit 92
printf "61\n" >&199
;;
62)
/probe/tool_timer /probe/input/062.sh /probe/work/062.json /testbed 900 > /probe/work/062.stdout 2> /probe/work/062.stderr
test "$?" -eq 0 || exit 92
printf "62\n" >&199
;;
63)
/probe/tool_timer /probe/input/063.sh /probe/work/063.json /testbed 900 > /probe/work/063.stdout 2> /probe/work/063.stderr
test "$?" -eq 0 || exit 92
printf "63\n" >&199
;;
64)
/probe/tool_timer /probe/input/064.sh /probe/work/064.json /testbed 900 > /probe/work/064.stdout 2> /probe/work/064.stderr
test "$?" -eq 0 || exit 92
printf "64\n" >&199
;;
65)
/probe/tool_timer /probe/input/065.sh /probe/work/065.json /testbed 900 > /probe/work/065.stdout 2> /probe/work/065.stderr
test "$?" -eq 0 || exit 92
printf "65\n" >&199
;;
66)
/probe/tool_timer /probe/input/066.sh /probe/work/066.json /testbed 900 > /probe/work/066.stdout 2> /probe/work/066.stderr
test "$?" -eq 0 || exit 92
printf "66\n" >&199
;;
67)
/probe/tool_timer /probe/input/067.sh /probe/work/067.json /testbed 900 > /probe/work/067.stdout 2> /probe/work/067.stderr
test "$?" -eq 0 || exit 92
printf "67\n" >&199
;;
68)
/probe/tool_timer /probe/input/068.sh /probe/work/068.json /testbed 900 > /probe/work/068.stdout 2> /probe/work/068.stderr
test "$?" -eq 0 || exit 92
printf "68\n" >&199
;;
69)
/probe/tool_timer /probe/input/069.sh /probe/work/069.json /testbed 900 > /probe/work/069.stdout 2> /probe/work/069.stderr
test "$?" -eq 0 || exit 92
printf "69\n" >&199
;;
70)
/probe/tool_timer /probe/input/070.sh /probe/work/070.json /testbed 900 > /probe/work/070.stdout 2> /probe/work/070.stderr
test "$?" -eq 0 || exit 92
printf "70\n" >&199
;;
71)
/probe/tool_timer /probe/input/071.sh /probe/work/071.json /testbed 900 > /probe/work/071.stdout 2> /probe/work/071.stderr
test "$?" -eq 0 || exit 92
printf "71\n" >&199
;;
72)
/probe/tool_timer /probe/input/072.sh /probe/work/072.json /testbed 900 > /probe/work/072.stdout 2> /probe/work/072.stderr
test "$?" -eq 0 || exit 92
printf "72\n" >&199
;;
73)
/probe/tool_timer /probe/input/073.sh /probe/work/073.json /testbed 900 > /probe/work/073.stdout 2> /probe/work/073.stderr
test "$?" -eq 0 || exit 92
printf "73\n" >&199
;;
74)
/probe/tool_timer /probe/input/074.sh /probe/work/074.json /testbed 900 > /probe/work/074.stdout 2> /probe/work/074.stderr
test "$?" -eq 0 || exit 92
printf "74\n" >&199
;;
75)
/probe/tool_timer /probe/input/075.sh /probe/work/075.json /testbed 900 > /probe/work/075.stdout 2> /probe/work/075.stderr
test "$?" -eq 0 || exit 92
printf "75\n" >&199
;;
76)
/probe/tool_timer /probe/input/076.sh /probe/work/076.json /testbed 900 > /probe/work/076.stdout 2> /probe/work/076.stderr
test "$?" -eq 0 || exit 92
printf "76\n" >&199
;;
77)
/probe/tool_timer /probe/input/077.sh /probe/work/077.json /testbed 900 > /probe/work/077.stdout 2> /probe/work/077.stderr
test "$?" -eq 0 || exit 92
printf "77\n" >&199
;;
78)
/probe/tool_timer /probe/input/078.sh /probe/work/078.json /testbed 900 > /probe/work/078.stdout 2> /probe/work/078.stderr
test "$?" -eq 0 || exit 92
printf "78\n" >&199
;;
79)
/probe/tool_timer /probe/input/079.sh /probe/work/079.json /testbed 900 > /probe/work/079.stdout 2> /probe/work/079.stderr
test "$?" -eq 0 || exit 92
printf "79\n" >&199
;;
80)
/probe/tool_timer /probe/input/080.sh /probe/work/080.json /testbed 900 > /probe/work/080.stdout 2> /probe/work/080.stderr
test "$?" -eq 0 || exit 92
printf "80\n" >&199
;;
81)
/probe/tool_timer /probe/input/081.sh /probe/work/081.json /testbed 900 > /probe/work/081.stdout 2> /probe/work/081.stderr
test "$?" -eq 0 || exit 92
printf "81\n" >&199
;;
82)
/probe/tool_timer /probe/input/082.sh /probe/work/082.json /testbed 900 > /probe/work/082.stdout 2> /probe/work/082.stderr
test "$?" -eq 0 || exit 92
printf "82\n" >&199
;;
83)
/probe/tool_timer /probe/input/083.sh /probe/work/083.json /testbed 900 > /probe/work/083.stdout 2> /probe/work/083.stderr
test "$?" -eq 0 || exit 92
printf "83\n" >&199
;;
84)
/probe/tool_timer /probe/input/084.sh /probe/work/084.json /testbed 900 > /probe/work/084.stdout 2> /probe/work/084.stderr
test "$?" -eq 0 || exit 92
printf "84\n" >&199
;;
85)
/probe/tool_timer /probe/input/085.sh /probe/work/085.json /testbed 900 > /probe/work/085.stdout 2> /probe/work/085.stderr
test "$?" -eq 0 || exit 92
printf "85\n" >&199
;;
86)
/probe/tool_timer /probe/input/086.sh /probe/work/086.json /testbed 900 > /probe/work/086.stdout 2> /probe/work/086.stderr
test "$?" -eq 0 || exit 92
printf "86\n" >&199
;;
87)
/probe/tool_timer /probe/input/087.sh /probe/work/087.json /testbed 900 > /probe/work/087.stdout 2> /probe/work/087.stderr
test "$?" -eq 0 || exit 92
printf "87\n" >&199
;;
88)
/probe/tool_timer /probe/input/088.sh /probe/work/088.json /testbed 900 > /probe/work/088.stdout 2> /probe/work/088.stderr
test "$?" -eq 0 || exit 92
printf "88\n" >&199
;;
89)
/probe/tool_timer /probe/input/089.sh /probe/work/089.json /testbed 900 > /probe/work/089.stdout 2> /probe/work/089.stderr
test "$?" -eq 0 || exit 92
printf "89\n" >&199
;;
90)
/probe/tool_timer /probe/input/090.sh /probe/work/090.json /testbed 900 > /probe/work/090.stdout 2> /probe/work/090.stderr
test "$?" -eq 0 || exit 92
printf "90\n" >&199
;;
91)
/probe/tool_timer /probe/input/091.sh /probe/work/091.json /testbed 900 > /probe/work/091.stdout 2> /probe/work/091.stderr
test "$?" -eq 0 || exit 92
printf "91\n" >&199
;;
92)
/probe/tool_timer /probe/input/092.sh /probe/work/092.json /testbed 900 > /probe/work/092.stdout 2> /probe/work/092.stderr
test "$?" -eq 0 || exit 92
printf "92\n" >&199
;;
93)
/probe/tool_timer /probe/input/093.sh /probe/work/093.json /testbed 900 > /probe/work/093.stdout 2> /probe/work/093.stderr
test "$?" -eq 0 || exit 92
printf "93\n" >&199
;;
94)
/probe/tool_timer /probe/input/094.sh /probe/work/094.json /testbed 900 > /probe/work/094.stdout 2> /probe/work/094.stderr
test "$?" -eq 0 || exit 92
printf "94\n" >&199
;;
95)
/probe/tool_timer /probe/input/095.sh /probe/work/095.json /testbed 900 > /probe/work/095.stdout 2> /probe/work/095.stderr
test "$?" -eq 0 || exit 92
printf "95\n" >&199
;;
*) exit 96 ;;
esac
done
exit 97
