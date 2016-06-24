CC?=clang
YACC?=yacc
BIN=doas
PREFIX?=/usr/local
OBJECTS=doas.o env.o execvpe.o reallocarray.o y.tab.o
CFLAGS+=-DUSE_PAM -DDOAS_CONF=\"${PREFIX}/etc/doas.conf\"
LDFLAGS+=-lpam

all: $(OBJECTS)
	$(CC) -o $(BIN) $(LDFLAGS) $(OBJECTS)

env.o: doas.h env.c

execvpe.o: doas.h execvpe.c

doas.o: doas.h doas.c parse.y

reallocarray.o: doas.h reallocarray.c

y.tab.o: parse.y
	$(YACC) parse.y
	$(CC) $(CFLAGS) -c y.tab.c

install: all
	cp $(BIN) $(PREFIX)/bin/
	chmod 4755 $(PREFIX)/bin/$(BIN)
	cp doas.1 $(PREFIX)/man/man1/
	cp doas.conf.5 $(PREFIX)/man/man5/

clean:
	rm -f $(BIN) $(OBJECTS) y.tab.c

