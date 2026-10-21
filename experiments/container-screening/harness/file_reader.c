#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
int main(int argc,char **argv){
 if(argc<2||argc>3)return 64;
 FILE *in=fopen(argv[1],"rb");if(!in){perror(argv[1]);return 1;}
 size_t begin[64],end[64],ranges=0;
 if(argc==3&&*argv[2]){char *spec=strdup(argv[2]);if(!spec)return 2;
  for(char *tok=strtok(spec,",");tok;tok=strtok(NULL,",")){
   if(ranges>=64)return 64;
   int n=sscanf(tok,"%zu-%zu",&begin[ranges],&end[ranges]);
   if(n<1||begin[ranges]<1)return 64;
   if(n==1)end[ranges]=begin[ranges];
   if(end[ranges]<begin[ranges])return 64;
   ranges++;
  }free(spec);
 }
 char *line=NULL;size_t cap=0,number=0;ssize_t bytes;
 while((bytes=getline(&line,&cap,in))!=-1){number++;int output=!ranges;
  for(size_t i=0;i<ranges;i++)if(begin[i]<=number&&number<=end[i]){output=1;break;}
  if(output&&fwrite(line,1,(size_t)bytes,stdout)!=(size_t)bytes){perror("stdout");return 1;}
 }
 int failed=ferror(in);free(line);fclose(in);if(fflush(stdout))failed=1;return failed?1:0;
}
