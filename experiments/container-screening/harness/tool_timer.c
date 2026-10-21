#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
static pid_t child=-1;
static volatile sig_atomic_t expired=0;
static long long ns(void){struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return (long long)t.tv_sec*1000000000LL+t.tv_nsec;}
static void timeout_handler(int sig){(void)sig;expired=1;if(child>0)kill(-child,SIGKILL);}
int main(int argc,char **argv){
 if(argc!=5){fprintf(stderr,"timer SCRIPT RESULT CWD TIMEOUT_SECONDS\n");return 64;}
 if(chdir(argv[3])){perror("chdir");return 65;}
 long long start=ns();child=fork();
 if(child<0){perror("fork");return 66;}
 if(child==0){setpgid(0,0);execl("/bin/bash","bash",argv[1],(char*)NULL);perror("exec bash");_exit(127);}
 setpgid(child,child);signal(SIGALRM,timeout_handler);alarm((unsigned)atoi(argv[4]));
 int status=0;struct rusage usage;
 while(wait4(child,&status,0,&usage)<0){if(errno==EINTR)continue;perror("wait4");return 67;}
 alarm(0);long long end=ns();int code=expired?124:WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);
 FILE *f=fopen(argv[2],"w");if(!f){perror("result");return 68;}
 fprintf(f,"{\"started_ns\":%lld,\"finished_ns\":%lld,\"tool_seconds\":%.9f,\"exit_code\":%d,\"timed_out\":%s,\"maxrss_kib\":%ld,\"user_cpu_seconds\":%.6f,\"system_cpu_seconds\":%.6f}\n",start,end,(end-start)/1e9,code,expired?"true":"false",usage.ru_maxrss,usage.ru_utime.tv_sec+usage.ru_utime.tv_usec/1e6,usage.ru_stime.tv_sec+usage.ru_stime.tv_usec/1e6);
 fclose(f);return 0;
}
