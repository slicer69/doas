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

#ifndef _PW_NAME_LEN
#define _PW_NAME_LEN 32
#endif

#if !defined(HAVE_REALLOCARRAY) && !defined(HAVE_REALLOCARR)
int reallocarr(void *ptr, size_t num, size_t size);
#endif	/* !HAVE_REALLOCARRAY && !HAVE_REALLOCARR */



#if !defined(HAVE_EXECVPE)
int execvpe(const char *file, char * const *argv, char * const *envp);
#endif	/* !HAVE_EXECVPE */

