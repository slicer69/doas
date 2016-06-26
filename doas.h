/* $OpenBSD: doas.h,v 1.8 2016/06/19 19:29:43 martijn Exp $ */
struct rule {
	int action;
	int options;
	const char *ident;
	const char *target;
	const char *cmd;
	const char **cmdargs;
	const char **envlist;
};

extern struct rule **rules;
extern int nrules, maxrules;
extern int parse_errors;

size_t arraylen(const char **);

char **prepenv(struct rule *);

#define PERMIT	1
#define DENY	2

#define NOPASS		0x1
#define KEEPENV		0x2

#ifndef UID_MAX
#define UID_MAX 65535
#endif

#ifndef GID_MAX
#define GID_MAX 65535
#endif

#ifndef ROOT_UID
#define ROOT_UID 0
#endif

#ifndef _PW_NAME_LEN
#define _PW_NAME_LEN 32
#endif

void *reallocarray(void *ptr, size_t nmemb, size_t size);

#if !defined(HAVE_EXECVPE)
int execvpe(const char *file, char * const *argv, char * const *envp);
#endif	/* !HAVE_EXECVPE */

#ifdef linux
void errc(int eval, int code, const char *format);
#endif
