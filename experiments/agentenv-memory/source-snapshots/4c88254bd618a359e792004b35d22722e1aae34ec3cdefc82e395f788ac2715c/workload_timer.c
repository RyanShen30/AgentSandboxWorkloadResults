#define _GNU_SOURCE
#include "workload_memory.h"
#include <sys/wait.h>
#include <sys/resource.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
static pid_t child=-1;static volatile sig_atomic_t expired=0;
static void timeout_handler(int sig){(void)sig;expired=1;if(child>0)kill(-child,SIGKILL);}
int main(int argc,char **argv){
 if(argc!=5)return 64;
 if(chdir(argv[3]))return 65;
 aswr_memory before,after;if(aswr_mem(&before))return 69;
 long long start=aswr_ns(CLOCK_MONOTONIC);child=fork();if(child<0)return 66;
 if(child==0){setpgid(0,0);execl("/bin/bash","bash",argv[1],(char*)NULL);_exit(127);}
 setpgid(child,child);signal(SIGALRM,timeout_handler);alarm((unsigned)atoi(argv[4]));int status=0;struct rusage usage;
 while(wait4(child,&status,0,&usage)<0){if(errno==EINTR)continue;return 67;}
 alarm(0);long long end=aswr_ns(CLOCK_MONOTONIC);if(aswr_mem(&after))return 69;
 int code=expired?124:WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);FILE *out=fopen(argv[2],"wx");if(!out)return 68;
 fprintf(out,"{\"started_ns\":%lld,\"finished_ns\":%lld,\"tool_seconds\":%.9f,\"exit_code\":%d,\"timed_out\":%s,\"maxrss_kib\":%ld,\"user_cpu_seconds\":%.6f,\"system_cpu_seconds\":%.6f,\"memory_before\":",start,end,(end-start)/1e9,code,expired?"true":"false",usage.ru_maxrss,usage.ru_utime.tv_sec+usage.ru_utime.tv_usec/1e6,usage.ru_stime.tv_sec+usage.ru_stime.tv_usec/1e6);aswr_json_mem(out,&before);fputs(",\"memory_after\":",out);aswr_json_mem(out,&after);fputs("}\n",out);fclose(out);return 0;
}
