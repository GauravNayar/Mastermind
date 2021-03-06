
all: mmt

run: mmt
	./mmt -d

mmt: master-mind-terminal.c
	gcc -o mmt  master-mind-terminal.c
