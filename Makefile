all: interactionLoop

interactionLoop: interactionLoop.o
	cc -o interactionLoop interactionLoop.o

interactionLoop.o : interactionLoop.c
	cc -c interactionLoop.c

clean:
	rm interactionLoop.o interactionLoop

install:
	cp killer.sh /usr/local/bin/
