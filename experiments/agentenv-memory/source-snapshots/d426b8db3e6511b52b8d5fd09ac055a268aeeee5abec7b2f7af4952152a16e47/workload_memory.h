#ifndef ASWR_MEMORY_H
#define ASWR_MEMORY_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
static const char *aswr_keys[] = {"MemTotal", "MemFree", "MemAvailable", "Cached", "Buffers", "Shmem", "AnonPages", "Slab", "SReclaimable", "SUnreclaim", "Active(file)", "Inactive(file)", "Dirty", "Writeback", "PageTables", "KernelStack"};
#define ASWR_FIELDS (sizeof(aswr_keys)/sizeof(aswr_keys[0]))
typedef struct { unsigned long long value[ASWR_FIELDS]; unsigned int seen; } aswr_memory;
static long long aswr_ns(clockid_t clock) { struct timespec t; if (clock_gettime(clock,&t)) abort(); return (long long)t.tv_sec*1000000000LL+t.tv_nsec; }
static int aswr_mem(aswr_memory *out) {
    memset(out,0,sizeof(*out)); FILE *f=fopen("/proc/meminfo","r"); if(!f)return -1;
    char line[256],key[128],unit[16]; unsigned long long n;
    while(fgets(line,sizeof(line),f)) {
        if(sscanf(line,"%127[^:]: %llu %15s",key,&n,unit)!=3)continue;
        for(size_t i=0;i<ASWR_FIELDS;i++)if(!strcmp(key,aswr_keys[i])) {
            if(strcmp(unit,"kB")){fclose(f);return -1;}
            out->value[i]=n*1024;out->seen|=1u<<i;
        }
    }
    fclose(f); return out->seen==((1u<<ASWR_FIELDS)-1)?0:-1;
}
static void aswr_json_mem(FILE *f,const aswr_memory *m) {
    fprintf(f,"{");for(size_t i=0;i<ASWR_FIELDS;i++)fprintf(f,"%s\"%s\":%llu",i?",":"",aswr_keys[i],m->value[i]);
    unsigned long long cached=m->value[3]>m->value[5]?m->value[3]-m->value[5]:0;
    fprintf(f,",\"disk_file_cache_bytes\":%llu,\"nonfree_bytes\":%llu}",cached,m->value[0]-m->value[1]);
}
#endif
