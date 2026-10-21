#include <time.h>
#include <stdio.h>
int main(void){struct timespec t;if(clock_gettime(CLOCK_MONOTONIC,&t))return 1;printf("%lld\n",(long long)t.tv_sec*1000000000LL+t.tv_nsec);return 0;}
