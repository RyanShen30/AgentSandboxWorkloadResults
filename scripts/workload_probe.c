#define _GNU_SOURCE
#include "workload_memory.h"
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <sys/mount.h>
#include <sys/vfs.h>

static long pagesize;
static void quote(FILE *out,const char *s);

static int write_control(const char *path,const char *value) {
    int fd=open(path,O_WRONLY|O_CLOEXEC);if(fd<0)return -1;
    size_t length=strlen(value);ssize_t wrote=write(fd,value,length);int saved=errno;close(fd);errno=saved;
    return wrote==(ssize_t)length?0:-1;
}
static int cgroup_init(const char *group) {
    struct statfs fs;
    if(statfs("/sys/fs/cgroup",&fs)||fs.f_type!=0x63677270) {
        if(mount("none","/sys/fs/cgroup","cgroup2",0,NULL))return 1;
    }
    if(strncmp(group,"/sys/fs/cgroup/aswr-",20)||strchr(group+15,'/'))return 64;
    if(mkdir(group,0700))return 1;
    char path[PATH_MAX];snprintf(path,sizeof(path),"%s/cgroup.freeze",group);
    if(access(path,W_OK))return 1;
    printf("{\"status\":\"PASS\",\"group\":");quote(stdout,group);
    puts(",\"scope\":\"owned guest business cgroup; observer and kernel stay runnable\"}");return 0;
}
static int cgroup_enter(const char *group,char **command) {
    char path[PATH_MAX];snprintf(path,sizeof(path),"%s/cgroup.procs",group);
    if(write_control(path,"0"))return 1;
    execvp(command[0],command);return 127;
}
static int cgroup_frozen(const char *group,int *populated) {
    char path[PATH_MAX],key[80];int value,frozen=-1;
    snprintf(path,sizeof(path),"%s/cgroup.events",group);FILE *f=fopen(path,"r");if(!f)return -1;
    while(fscanf(f,"%79s %d",key,&value)==2){if(!strcmp(key,"frozen"))frozen=value;if(!strcmp(key,"populated"))*populated=value;}
    fclose(f);return frozen;
}
static unsigned long long cgroup_cpu(const char *group) {
    char path[PATH_MAX],key[80];unsigned long long value,result=0;
    snprintf(path,sizeof(path),"%s/cpu.stat",group);FILE *f=fopen(path,"r");if(!f)return 0;
    while(fscanf(f,"%79s %llu",key,&value)==2)if(!strcmp(key,"usage_usec"))result=value;
    fclose(f);return result;
}
static int cgroup_set(const char *group,int freeze) {
    long long started=aswr_ns(CLOCK_MONOTONIC);char path[PATH_MAX];
    snprintf(path,sizeof(path),"%s/cgroup.freeze",group);if(write_control(path,freeze?"1":"0"))return 1;
    int populated=0;
    while(cgroup_frozen(group,&populated)!=freeze){
        if(aswr_ns(CLOCK_MONOTONIC)-started>10000000000LL)return 1;
        struct timespec delay={0,1000000};nanosleep(&delay,NULL);
    }
    unsigned long long before=cgroup_cpu(group),after=before;
    if(freeze){struct timespec delay={0,10000000};nanosleep(&delay,NULL);after=cgroup_cpu(group);}
    printf("{\"status\":\"%s\",\"frozen\":%s,\"populated\":%s,\"started_ns\":%lld,\"finished_ns\":%lld,\"elapsed_seconds\":%.9f,\"cpu_usage_before_usec\":%llu,\"cpu_usage_after_usec\":%llu,\"cpu_stable\":%s,\"members\":[",
        before==after?"PASS":"FAIL",freeze?"true":"false",populated?"true":"false",started,aswr_ns(CLOCK_MONOTONIC),(aswr_ns(CLOCK_MONOTONIC)-started)/1e9,before,after,before==after?"true":"false");
    snprintf(path,sizeof(path),"%s/cgroup.procs",group);FILE *f=fopen(path,"r");int pid,first=1;
    if(f){while(fscanf(f,"%d",&pid)==1){printf("%s%d",first?"":",",pid);first=0;}fclose(f);}
    puts("],\"scope\":\"business subtree frozen; not whole-VM or kernel freeze\"}");return before==after?0:1;
}
static void quote(FILE *out,const char *s) {
    fputc('"',out);for(;*s;s++){unsigned char c=*s;if(c=='"'||c=='\\'){fputc('\\',out);fputc(c,out);}else if(c<32)fprintf(out,"\\u%04x",c);else fputc(c,out);}fputc('"',out);
}
static int snapshot(void) {aswr_memory m;if(aswr_mem(&m))return 1;printf("{\"monotonic_ns\":%lld,\"timestamp_ns\":%lld,\"memory\":",aswr_ns(CLOCK_MONOTONIC),aswr_ns(CLOCK_REALTIME));aswr_json_mem(stdout,&m);puts("}");return 0;}
static int monitor(const char *dir) {
    char path[PATH_MAX],phasepath[PATH_MAX],stoppath[PATH_MAX];
    snprintf(path,sizeof(path),"%s/samples.jsonl",dir);FILE *out=fopen(path,"wx");if(!out)return 1;setvbuf(out,NULL,_IOLBF,0);
    snprintf(phasepath,sizeof(phasepath),"%s/phase",dir);snprintf(stoppath,sizeof(stoppath),"%s/monitor-stop",dir);
    unsigned long count=0;int failed=0;long long started=aswr_ns(CLOCK_MONOTONIC);
    snprintf(path,sizeof(path),"%s/monitor-ready",dir);FILE *ready=fopen(path,"wx");if(!ready){fclose(out);return 1;}fprintf(ready,"%d\n",getpid());fclose(ready);
    for(;;) {
        aswr_memory m;if(aswr_mem(&m)){failed=1;break;}char phase[64]="unknown";int step=0;FILE *p=fopen(phasepath,"r");if(p){if(fscanf(p,"%63s %d",phase,&step)!=2){strcpy(phase,"unknown");step=0;}fclose(p);}
        fprintf(out,"{\"monotonic_ns\":%lld,\"timestamp_ns\":%lld,\"phase\":",aswr_ns(CLOCK_MONOTONIC),aswr_ns(CLOCK_REALTIME));quote(out,phase);fprintf(out,",\"step\":%d,\"memory\":",step);aswr_json_mem(out,&m);fputs("}\n",out);count++;
        if(!access(stoppath,F_OK))break;
        if(aswr_ns(CLOCK_MONOTONIC)-started>14400LL*1000000000){failed=1;break;}
        struct timespec delay={0,200000000};nanosleep(&delay,NULL);
    }
    fclose(out);struct rusage usage;getrusage(RUSAGE_SELF,&usage);
    snprintf(path,sizeof(path),"%s/monitor-status.json",dir);out=fopen(path,"wx");if(!out)return 1;
    fprintf(out,"{\"status\":\"%s\",\"samples\":%lu,\"interval_seconds\":0.2,\"elapsed_seconds\":%.9f,\"user_cpu_seconds\":%.6f,\"system_cpu_seconds\":%.6f,\"maxrss_kib\":%ld}\n",failed?"FAIL":"PASS",count,(aswr_ns(CLOCK_MONOTONIC)-started)/1e9,usage.ru_utime.tv_sec+usage.ru_utime.tv_usec/1e6,usage.ru_stime.tv_sec+usage.ru_stime.tv_usec/1e6,usage.ru_maxrss);fclose(out);return failed;
}

typedef struct {uint64_t dev,ino;} identity;
static identity seen[1048576];static unsigned int files,errors,changed,excluded;
static unsigned int skipped_controls,skipped_symlinks,skipped_mounts,skipped_special;
typedef struct {const char *path;unsigned long long resident,logical;unsigned int count;} category;
static category categories[]={{"/app",0,0,0},{"/testbed",0,0,0},{"/tmp",0,0,0},{"/usr",0,0,0},{"/opt",0,0,0},{"/root",0,0,0},{"/data",0,0,0},{"/var",0,0,0},{"other",0,0,0}};
static category *file_category(const char *path) {
    for(size_t i=0;i<sizeof(categories)/sizeof(categories[0])-1;i++){
        size_t n=strlen(categories[i].path);
        if(!strncmp(path,categories[i].path,n)&&(path[n]=='/'||!path[n]))return &categories[i];
    }
    return &categories[sizeof(categories)/sizeof(categories[0])-1];
}
static long long deadline;
static unsigned long long resident_total,logical_total,stable_total;
static int visited(dev_t dev,ino_t ino) {
    size_t h=(((uint64_t)dev*11400714819323198485ull)^(uint64_t)ino)&1048575;
    for(unsigned n=0;n<1048576;n++,h=(h+1)&1048575){if(!seen[h].ino){seen[h]=(identity){dev,ino};return 0;}if(seen[h].dev==(uint64_t)dev&&seen[h].ino==(uint64_t)ino)return 1;}return 1;
}
static int file_pages(int fd,off_t size,unsigned long long *resident,unsigned long long *stable,unsigned long long *unstable) {
    const size_t chunk=64*1024*1024;unsigned char first[16384],second[16384];
    for(off_t offset=0;offset<size;offset+=chunk){size_t length=(size-offset)<(off_t)chunk?(size_t)(size-offset):chunk;
        size_t pages=(length+pagesize-1)/pagesize;void *address=mmap(NULL,length,PROT_NONE,MAP_SHARED,fd,offset);if(address==MAP_FAILED)return -1;
        if(mincore(address,length,first)||mincore(address,length,second)){munmap(address,length);return -1;}
        for(size_t p=0;p<pages;p++){*resident+=(second[p]&1)*pagesize;*stable+=((first[p]&second[p])&1)*pagesize;*unstable+=((first[p]^second[p])&1);}
        munmap(address,length);
    }return 0;
}
static void walk(const char *path,dev_t device,unsigned depth) {
    if(!strcmp(path,"/proc")||!strcmp(path,"/sys")||!strcmp(path,"/dev")||!strcmp(path,"/probe")||!strcmp(path,"/tmp/aswr-input.tar")){
        excluded++;skipped_controls++;return;
    }
    if(depth>80||files>=500000||aswr_ns(CLOCK_MONOTONIC)>deadline){errors++;return;}
    struct stat st;if(lstat(path,&st)){errors++;return;}
    if(st.st_dev!=device){excluded++;skipped_mounts++;return;}
    if(S_ISLNK(st.st_mode)){excluded++;skipped_symlinks++;return;}
    if(S_ISDIR(st.st_mode)){DIR *d=opendir(path);if(!d){errors++;return;}struct dirent *entry;while((entry=readdir(d))){if(!strcmp(entry->d_name,".")||!strcmp(entry->d_name,".."))continue;char sub[PATH_MAX];if(snprintf(sub,sizeof(sub),"%s%s%s",path,!strcmp(path,"/")?"":"/",entry->d_name)>=(int)sizeof(sub)){errors++;continue;}walk(sub,device,depth+1);if(aswr_ns(CLOCK_MONOTONIC)>deadline)break;}closedir(d);return;}
    if(!S_ISREG(st.st_mode)){excluded++;skipped_special++;return;}if(visited(st.st_dev,st.st_ino))return;files++;logical_total+=st.st_size;
    category *bucket=file_category(path);bucket->count++;bucket->logical+=st.st_size;if(!st.st_size)return;
    int fd=open(path,O_RDONLY|O_CLOEXEC|O_NOFOLLOW);if(fd<0){errors++;return;}struct stat before,after;
    if(fstat(fd,&before)||before.st_ino!=st.st_ino||before.st_size!=st.st_size){errors++;close(fd);return;}
    unsigned long long resident=0,stable=0,unstable=0;
    if(file_pages(fd,st.st_size,&resident,&stable,&unstable)){errors++;close(fd);return;}
    if(fstat(fd,&after)||after.st_size!=before.st_size||after.st_mtim.tv_sec!=before.st_mtim.tv_sec||after.st_mtim.tv_nsec!=before.st_mtim.tv_nsec){changed++;close(fd);return;}
    resident_total+=resident;stable_total+=stable;changed+=unstable;bucket->resident+=resident;close(fd);
}
static int scan(int argc,char **argv) {
    const char *group=NULL;int populated=0;
    if(argc>=2&&!strcmp(argv[0],"--frozen-cgroup")){group=argv[1];argc-=2;argv+=2;}
    if(group&&cgroup_frozen(group,&populated)!=1)return 1;
    unsigned long long cpu_before=group?cgroup_cpu(group):0;
    long long started=aswr_ns(CLOCK_MONOTONIC);deadline=started+90000000000LL;
    printf("{\"scan_path_policy\":\"canonical_absolute_v2\",\"started_ns\":%lld,\"page_size\":%ld,\"roots\":[",started,pagesize);
    for(int i=0;i<argc;i++){struct stat st;unsigned long long previous=resident_total,previous_logical=logical_total;unsigned previous_files=files;
        if(i)putchar(',');
        printf("{\"path\":");quote(stdout,argv[i]);
        if(lstat(argv[i],&st)){printf(",\"status\":\"MISSING\",\"resident_bytes\":null}");continue;}
        walk(argv[i],st.st_dev,0);printf(",\"status\":\"SCANNED\",\"resident_bytes\":%llu,\"logical_bytes\":%llu,\"files\":%u}",resident_total-previous,logical_total-previous_logical,files-previous_files);
    }
    int frozen=group?cgroup_frozen(group,&populated):0;
    unsigned long long cpu_after=group?cgroup_cpu(group):0;
    int freeze_ok=!group||(frozen==1&&cpu_before==cpu_after);
    printf("],\"by_top_level\":[");
    for(size_t i=0;i<sizeof(categories)/sizeof(categories[0]);i++){
        if(i){putchar(',');}
        printf("{\"path\":");quote(stdout,categories[i].path);
        printf(",\"resident_bytes\":%llu,\"logical_bytes\":%llu,\"files\":%u}",categories[i].resident,categories[i].logical,categories[i].count);
    }
    printf("],\"resident_bytes\":%llu,\"stable_resident_bytes\":%llu,\"logical_bytes\":%llu,\"files\":%u,\"errors\":%u,\"changed_pages_or_files\":%u,\"excluded_entries\":%u,\"exclusions\":{\"observer_and_virtual_paths\":%u,\"symlinks\":%u,\"other_filesystems\":%u,\"special_files\":%u},\"finished_ns\":%lld,\"scan_seconds\":%.9f,\"status\":\"%s\",\"business_frozen_verified\":%s,\"business_cpu_before_usec\":%llu,\"business_cpu_after_usec\":%llu,\"scope\":\"guest regular-file inode/offset residency; business cgroup frozen when requested; kernel reclaim remains active; not PFN deduplication\"}\n",resident_total,stable_total,logical_total,files,errors,changed,excluded,skipped_controls,skipped_symlinks,skipped_mounts,skipped_special,aswr_ns(CLOCK_MONOTONIC),(aswr_ns(CLOCK_MONOTONIC)-started)/1e9,!freeze_ok?"FAIL":errors||changed?"PARTIAL":"PASS",group?(freeze_ok?"true":"false"):"null",cpu_before,cpu_after);return freeze_ok&&(!group||errors==0)?0:1;
}
static int calibrate(const char *path) {
    const off_t size=16*1024*1024;int fd=open(path,O_CREAT|O_EXCL|O_RDWR,0600);if(fd<0)return 1;unsigned char block[4096];for(int i=0;i<4096;i++)block[i]=(i%251)+1;
    for(off_t n=0;n<size;n+=sizeof(block))if(write(fd,block,sizeof(block))!=(ssize_t)sizeof(block)){close(fd);return 1;}
    if(fsync(fd)||posix_fadvise(fd,0,0,POSIX_FADV_DONTNEED)){close(fd);return 1;}
    unsigned long long cold=0,stable=0,changed_local=0,again=0,hot=0;int bad=file_pages(fd,size,&cold,&stable,&changed_local);stable=0;bad|=file_pages(fd,size,&again,&stable,&changed_local);lseek(fd,0,SEEK_SET);off_t total=0;ssize_t n;while((n=read(fd,block,sizeof(block)))>0)total+=n;stable=0;bad|=file_pages(fd,size,&hot,&stable,&changed_local);
    close(fd);unlink(path);int good=!bad&&cold==0&&again==0&&hot==(unsigned long long)size&&total==size&&!changed_local;
    printf("{\"status\":\"%s\",\"bytes\":%lld,\"page_size\":%ld,\"cold_resident_bytes\":%llu,\"second_cold_resident_bytes\":%llu,\"warm_resident_bytes\":%llu,\"changed_pages\":%llu,\"scope\":\"one newly created private 16 MiB guest file; no global cache drop\"}\n",good?"PASS":"FAIL",(long long)size,pagesize,cold,again,hot,changed_local);return good?0:1;
}
int main(int argc,char **argv) {pagesize=sysconf(_SC_PAGESIZE);if(argc<2||pagesize<4096)return 64;if(!strcmp(argv[1],"snapshot"))return snapshot();if(!strcmp(argv[1],"monitor")&&argc==3)return monitor(argv[2]);if(!strcmp(argv[1],"scan"))return scan(argc-2,argv+2);if(!strcmp(argv[1],"calibrate")&&argc==3)return calibrate(argv[2]);if(!strcmp(argv[1],"cgroup-init")&&argc==3)return cgroup_init(argv[2]);if(!strcmp(argv[1],"enter")&&argc>=4)return cgroup_enter(argv[2],argv+3);if(!strcmp(argv[1],"freeze")&&argc==3)return cgroup_set(argv[2],1);if(!strcmp(argv[1],"thaw")&&argc==3)return cgroup_set(argv[2],0);return 64;}
