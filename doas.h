/* $OpenBSD: doas.h,v 1.12 2016/10/05 17:40:25 tedu Exp $ */
/*
 * Copyright (c) 2015 Ted Unangst <tedu@openbsd.org>
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
extern int nrules;
extern int parse_errors;

struct passwd;
char **prepenv(struct rule *, struct passwd *original, struct passwd *target);
struct passwd *copyenvpw(struct passwd *original);

#ifndef GLOBAL_PATH 
#define GLOBAL_PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#endif

#define PERMIT	1
#define DENY	2

#define NOPASS		0x1
#define KEEPENV		0x2
#define PERSIST		0x4

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

#ifndef SAFE_PATH
#define SAFE_PATH "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
#endif

