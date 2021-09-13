/*
 * Copyright (c) 2004-2005, 2007, 2010, 2012-2014
 *	Todd C. Miller <Todd.Miller@courtesan.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/* closefrom.c original: libbsd/src/closefrom.c */

#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <limits.h>
#include <dirent.h>

static inline void
closefrom_close(int fd)
{
#ifdef __APPLE__
	/* Avoid potential libdispatch crash when we close its fds. */
	(void)fcntl(fd, F_SETFD, FD_CLOEXEC);
#else
	(void)close(fd);
#endif
}

void
closefrom(int lowfd)
{
	const char *path;
	DIR *dirp;
	struct dirent *dent;
	int *fd_array = NULL;
	int fd_array_used = 0;
	int fd_array_size = 0;
	int i;

	/* Use /proc/self/fd (or /dev/fd on FreeBSD) if it exists. */
# if defined(__FreeBSD__) || defined(__FreeBSD_kernel__) || defined(__APPLE__) || defined(__MidnightBSD__)
	path = "/dev/fd";
# else
	path = "/proc/self/fd";
# endif
	dirp = opendir(path);
	if (dirp == NULL)
		return; 

	while ((dent = readdir(dirp)) != NULL) {
		const char *errstr;
		int fd;

		fd = strtonum(dent->d_name, lowfd, INT_MAX, &errstr);
		if (errstr != NULL || fd == dirfd(dirp))
			continue;

		if (fd_array_used >= fd_array_size) {
			int *ptr;

			if (fd_array_size > 0)
				fd_array_size *= 2;
			else
				fd_array_size = 32;

			ptr = reallocarray(fd_array, fd_array_size, sizeof(int));
			if (ptr == NULL) {
				break;
			}
			fd_array = ptr;
		}

		fd_array[fd_array_used++] = fd;
	}

	for (i = 0; i < fd_array_used; i++)
		closefrom_close(fd_array[i]);

	free(fd_array);
	(void)closedir(dirp);
}
