#include <sys/types.h>
#include <stdarg.h>

#if !defined(__NetBSD__)
void closefrom(int lowfd);
#endif

void errc(int eval, int code, const char *fmt, ...);

int execvpe(const char *file, char * const *argv, char * const *envp);

extern const char *__progname;

const char *getprogname(void);

#if !defined(__NetBSD__)
void *reallocarray(void *optr, size_t nmemb, size_t size);
#endif

void setprogname(const char *progname);

int setresuid(uid_t ruid, uid_t euid, uid_t suid);

size_t strlcat(char *dst, const char *src, size_t dsize);

size_t strlcpy(char *dst, const char *src, size_t dsize);

long long strtonum(const char *numstr, long long minval, long long maxval,
	const char **errstrp);

void verrc(int eval, int code, const char *fmt, va_list ap);

