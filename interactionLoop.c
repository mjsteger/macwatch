#include <stdio.h>   /* printf, stderr, fprintf */
#include <sys/types.h> /* pid_t */
#include <unistd.h>  /* _exit, fork */
#include <stdlib.h>  /* exit */
#include <errno.h>   /* errno */
#include <string.h> /* strcpy */
#include <signal.h>

const char * USAGE = "Usage: $0 fileToWatch commandToRun";
int myPid;

void cleanup();

int main(int argc, char *argv[])
{
  myPid = getpid();
  char commandToRun[1000];
  if (argc < 2)
    {
      printf("%s", USAGE);
    }
  else
    {
      char fileToWatch[1000];
      char commandRequest[1000];

      // sprintf doesnt like arguments from argv(segfaulted on my machine), so I copy it out first
      strcpy(fileToWatch, argv[1]);
      strcpy(commandToRun, argv[2]);
      sprintf(commandRequest, "./watch.sh %s %d %s ", fileToWatch, myPid, commandToRun);
      system(commandRequest);
    }
  pid_t pid;
  while(1)
    {
      // Catch a C-c and clean everything up
      signal(SIGINT, cleanup);
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
	  sprintf(fileLocation, "/tmp/macWatch.%d", myPid);
	  FILE * pidFile;
	  pidFile = fopen(fileLocation, "w+");
	  fprintf(pidFile, "%d", pid);
	  fclose(pidFile);
	  waitpid(pid, NULL, 0);
	  system(commandToRun);
	}
    }
}

void cleanup(void)
{
  // Make sure that the child process we spawn with fork doesnt also try to cleanup
  if (getpid() == myPid){
    char unloadSystemCall[1000];
    sprintf(unloadSystemCall, "launchctl unload %s.%d ", "/tmp/macWatch.plist", myPid );
    system(unloadSystemCall);
    char removePlistSystemCall[1000];
    sprintf(removePlistSystemCall, "rm  %s.%d* ", "/tmp/macWatch.plist", myPid );
    system(removePlistSystemCall);
    char removePidFileSystemCall[1000];
    sprintf(removePidFileSystemCall, "rm %s.%d", "/tmp/macWatch", myPid);
    system(removePidFileSystemCall);
    exit(1);
  }
}
