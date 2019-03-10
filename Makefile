CC?=clang
YACC?=yacc
BIN=doas
PREFIX?=/usr/local
OBJECTS=doas.o env.o execvpe.o reallocarray.o y.tab.o
CFLAGS+=-DUSE_PAM -DDOAS_CONF=\"${PREFIX}/etc/doas.conf\" 
LDFLAGS+=-lpam
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LDFLAGS+=-lpam_misc
    OBJECTS+=strlcat.o strlcpy.o
    CFLAGS+=-D_GNU_SOURCE
endif
ifeq ($(UNAME_S),FreeBSD)
    CFLAGS+=-DHAVE_LOGIN_CAP_H
    LDFLAGS+=-lutil
endif

all: $(OBJECTS)
	$(CC) -o $(BIN) $(OBJECTS) $(LDFLAGS)

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
	mkdir -p $(PREFIX)/man/man1
	cp doas.1 $(PREFIX)/man/man1/
	mkdir -p $(PREFIX)/man/man5
	cp doas.conf.5 $(PREFIX)/man/man5/

clean:
	rm -f $(BIN) $(OBJECTS) y.tab.c

