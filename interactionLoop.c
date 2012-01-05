#include <stdio.h>   /* printf, stderr, fprintf */
#include <sys/types.h> /* pid_t */
#include <unistd.h>  /* _exit, fork */
#include <stdlib.h>  /* exit */
#include <errno.h>   /* errno */
#include <string.h> /* strcpy */

const char * USAGE = "Usage: $0 fileToWatch commandToRun";

int main(int argc, char *argv[])
{
  char commandToRun[1000];
  if (argc < 2)
    {
      printf("%s", USAGE);
    }
  else
    {
      char fileToWatch[1000];
      char commandRequest[1000];
      strcpy(fileToWatch, argv[1]);
      strcpy(commandToRun, argv[2]);
      sprintf(commandRequest, "./watch.sh %s %d %s ", fileToWatch, getpid(), commandToRun);
      system(commandRequest);
    }
  pid_t pid;
  while(1)
    {
      pid = fork();
      if (pid == -1)
	{
	  fprintf(stderr, "can't fork, error %d\n", errno);
	  exit(EXIT_FAILURE);
	}
      if (pid == 0)
	{
	  sleep(1000000);
	  _exit(0);
	}
      else
	{
	  char fileLocation[1000];
	  sprintf(fileLocation, "/tmp/macWatch.%d", getpid());
	  FILE * pidFile;
	  pidFile = fopen(fileLocation, "w+");
	  fprintf(pidFile, "%d", pid);
	  fclose(pidFile);
	  waitpid(pid, NULL, 0);
	  system(commandToRun);
	}
    }
}
