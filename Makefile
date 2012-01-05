all: macWatch

macWatch: macWatch.o
	cc -o macWatch macWatch.o

macWatch.o : macWatch.c
	cc -c macWatch.c

clean:
	rm macWatch.o macWatch

install: clean macWatch
	cp macWatch /usr/local/bin/
	cp killer.sh /usr/local/bin/
	cp watch.sh /usr/local/bin/
