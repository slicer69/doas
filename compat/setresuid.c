#include <sys/types.h>

#include <unistd.h>
#include <errno.h>

int
setresuid(uid_t ruid, uid_t euid, uid_t suid)
{
	int ret = 0;

	if (ruid != suid) {
		errno = ENOSYS;
		return -1;
	}
	
	if (setreuid(ruid, euid) < 0) {
		ret = -1;
	}
	
	return ret;
}
