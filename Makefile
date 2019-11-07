PREFIX     ?= /usr/local
MANDIR     ?= $(DESTDIR)$(PREFIX)/man
SYSCONFDIR ?= $(PREFIX)/etc

# Can set GLOBAL_PATH here to set PATH for target user.
# TARGETPATH = -DGLOBAL_PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\"
CPPFLAGS   += -include compat/compat.h
CFLAGS     += -Wall \
	      -DUSE_PAM \
	      -DDOAS_CONF=\"$(SYSCONFDIR)/doas.conf\" \
	      $(TARGETPATH)
LDFLAGS    := -lpam $(LDFLAGS)

UNAME_S    := $(shell uname -s)

OBJS       = compat/execvpe.o \
	     compat/reallocarray.o \
	     doas.o \
	     env.o \
	     parse.o

ifeq ($(UNAME_S),Linux)
    CPPFLAGS += -Icompat
    CFLAGS   += -D_GNU_SOURCE
    LDFLAGS  := -lpam_misc $(LDFLAGS)

    OBJS     += compat/closefrom.o \
		compat/errc.o \
		compat/getprogname.o \
		compat/setprogname.o \
		compat/strlcat.o \
		compat/strlcpy.o \
		compat/strtonum.o \
		compat/verrc.o

else ifeq ($(UNAME_S),FreeBSD)
    CFLAGS  += -DHAVE_LOGIN_CAP_H
    LDFLAGS := -lutil $(LDFLAGS)

else ifeq ($(UNAME_S),SunOS)
    SAFE_PATH   ?= /bin:/sbin:/usr/bin:/usr/sbin:$(PREFIX)/bin:$(PREFIX)/sbin
    GLOBAL_PATH ?= /bin:/sbin:/usr/bin:/usr/sbin:$(PREFIX)/bin:$(PREFIX)/sbin
    CPPFLAGS    += -Icompat
    CFLAGS      += -DSOLARIS_PAM -DSAFE_PATH=\"$(SAFE_PATH)\" -DGLOBAL_PATH=\"$(GLOBAL_PATH)\"

    OBJS += compat/errc.o \
	    compat/pm_pam_conv.o \
	    compat/setresuid.o \
	    compat/verrc.o

else ifeq ($(UNAME_S),Darwin)
    CPPFLAGS += -Icompat
    OBJS     += compat/bsd-closefrom.o
    # On MacOS the default man page path is /usr/local/share/man
    MANDIR=$(DESTDIR)$(PREFIX)/share/man

endif

doas: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

env.o: doas.h
execvpe.o: doas.h
doas.o: doas.h
reallocarray.o: doas.h

install: doas
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(MANDIR)/man1
	mkdir -p $(MANDIR)/man5
	install -m 4755 doas $(DESTDIR)$(PREFIX)/bin/doas
	install -m 0444 doas.1 $(DESTDIR)$(MANDIR)/man1/doas.1
	install -m 0444 doas.conf.5 $(DESTDIR)$(MANDIR)/man5/doas.conf.5

clean:
	$(RM) doas $(OBJS)
