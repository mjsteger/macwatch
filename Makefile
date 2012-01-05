all: macWatch

macWatch: macWatch.o
	cc -o macWatch macWatch.o

macWatch.o : macWatch.c
	cc -c macWatch.c

clean:
	rm macWatch.o macWatch

install:
	cp killer.sh /usr/local/bin/
