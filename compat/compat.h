#include <sys/types.h>
#include <stdarg.h>

void errc(int eval, int code, const char *fmt, ...);

int setresuid(uid_t ruid, uid_t euid, uid_t suid);

void verrc(int eval, int code, const char *fmt, va_list ap);

