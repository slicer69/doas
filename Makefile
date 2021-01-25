CAT?=cat
SED?=sed
CC?=clang
YACC?=yacc
BIN=doas
PREFIX?=/usr/local
MANDIR?=$(DESTDIR)$(PREFIX)/man
SYSCONFDIR?=$(DESTDIR)$(PREFIX)/etc
DOAS_CONF=$(SYSCONFDIR)/doas.conf
OBJECTS=doas.o env.o compat/execvpe.o compat/reallocarray.o y.tab.o 
OPT?=-O2
# Can set GLOBAL_PATH here to set PATH for target user.
# TARGETPATH=-DGLOBAL_PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\"
CFLAGS+=-Wall $(OPT) -DUSE_PAM -DDOAS_CONF=\"$(DOAS_CONF)\" $(TARGETPATH)
CPPFLAGS+=-include compat/compat.h
LDFLAGS+=-lpam
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LDFLAGS+=-lpam_misc
    CPPFLAGS+=-Icompat
    CFLAGS+=-D_GNU_SOURCE
    COMPAT+=closefrom.o errc.o getprogname.o setprogname.o strlcat.o strlcpy.o strtonum.o verrc.o
    OBJECTS+=$(COMPAT:%.o=compat/%.o)
endif
ifeq ($(UNAME_S),FreeBSD)
    CFLAGS+=-DHAVE_LOGIN_CAP_H
    LDFLAGS+=-lutil
endif
ifeq ($(UNAME_S),NetBSD)
    CFLAGS+=-DHAVE_LOGIN_CAP_H -D_OPENBSD_SOURCE
    OBJECTS=doas.o env.o y.tab.o
    LDFLAGS+=-lutil
endif
ifeq ($(UNAME_S),SunOS)
    SAFE_PATH?=/bin:/sbin:/usr/bin:/usr/sbin:$(PREFIX)/bin:$(PREFIX)/sbin
    GLOBAL_PATH?=/bin:/sbin:/usr/bin:/usr/sbin:$(PREFIX)/bin:$(PREFIX)/sbin
    CPPFLAGS+=-Icompat
    CFLAGS+=-DSOLARIS_PAM -DSAFE_PATH=\"$(SAFE_PATH)\" -DGLOBAL_PATH=\"$(GLOBAL_PATH)\"
    COMPAT=errc.o pm_pam_conv.o setresuid.o verrc.o
    OBJECTS+=$(COMPAT:%.o=compat/%.o)
endif
ifeq ($(UNAME_S),Darwin)
    CPPFLAGS+=-Icompat
    COMPAT+=bsd-closefrom.o
    OBJECTS+=$(COMPAT:%.o=compat/%.o)
    # On MacOS the default man page path is /usr/local/share/man
    MANDIR=$(DESTDIR)$(PREFIX)/share/man
endif

FINALS=doas.1.final doas.conf.5.final vidoas.final vidoas.8.final

all: $(BIN) $(FINALS)

$(BIN): $(OBJECTS)
	$(CC) -o $(BIN) $(OBJECTS) $(LDFLAGS)

env.o: doas.h env.c

execvpe.o: doas.h execvpe.c

doas.o: doas.h doas.c parse.y

reallocarray.o: doas.h reallocarray.c

y.tab.o: parse.y
	$(YACC) parse.y
	$(CC) $(CPPFLAGS) $(CFLAGS) -c y.tab.c

install: $(BIN) $(FINALS)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp $(BIN) $(DESTDIR)$(PREFIX)/bin/
	chmod 4755 $(DESTDIR)$(PREFIX)/bin/$(BIN)
	cp vidoas.final $(DESTDIR)$(PREFIX)/bin/vidoas
	chmod 755 $(DESTDIR)$(PREFIX)/bin/vidoas
	mkdir -p $(MANDIR)/man1
	cp doas.1.final $(MANDIR)/man1/doas.1
	mkdir -p $(MANDIR)/man5
	cp doas.conf.5.final $(MANDIR)/man5/doas.conf.5
	mkdir -p $(MANDIR)/man8
	cp vidoas.8.final $(MANDIR)/man8/vidoas.8

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/doas
	rm -f $(DESTDIR)$(PREFIX)/bin/vidoas
	rm -f $(MANDIR)/man1/doas.1
	rm -f $(MANDIR)/man5/doas.conf.5
	rm -f $(MANDIR)/man8/vidoas.8

clean:
	rm -f $(BIN) $(OBJECTS) y.tab.c
	rm -f *.final parse.o

# Doing it this way allows to change the original files
# only partially instead of renaming them.
doas.1.final: doas.1
doas.conf.5.final: doas.conf.5
vidoas.final: vidoas
vidoas.8.final: vidoas.8
$(FINALS):
	$(CAT) $^ | $(SED) 's,@DOAS_CONF@,$(DOAS_CONF),g' > $@
