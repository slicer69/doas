CC?=clang
YC?=yacc
BIN=doas
PREFIX?=/usr/local
OBJECTS=doas.o env.o execvpe.o reallocarr.o y.tab.o
CFLAG+= -DUSE_PAM
LFLAG+= -lpam

all: $(OBJECTS)
	$(CC) -o $(BIN) $(LFLAG) $(OBJECTS)

env.o: doas.h env.c 
	$(CC) -c env.c 

execvpe.o: doas.h execvpe.c
	$(CC) -c execvpe.c

doas.o: doas.h doas.c parse.y
	$(CC) $(CFLAG) -c doas.c

reallocarr.o: reallocarr.c doas.h
	$(CC) -c reallocarr.c

y.tab.o: parse.y
	$(YC) parse.y
	$(CC) -c y.tab.c

install: all
	cp $(BIN) $(PREFIX)/bin/
	chmod 4755 $(PREFIX)/bin/$(BIN)
	cp doas.1 $(PREFIX)/man/man1/
	cp doas.conf.5 $(PREFIX)/man/man5/

clean:
	rm -f $(BIN) $(OBJECTS) y.tab.c

