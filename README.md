# doas
A port of OpenBSD's doas which runs on FreeBSD, Linux and NetBSD

The doas utility is a program originally written for OpenBSD which allows a user to run a command as though they were another user. Typically doas is used to allow non-privleged users to run commands as though they were the root user. The doas program acts as an alternative to sudo, which is a popular method in the Linux community for granting admin access to specific users.

The doas program offers two benefits over sudo: its configuration file has a simple syntax and it is smaller, requiring less effort to audit the code. This makes it harder for both admins and coders to make mistakes that potentially open security holes in the system.

This port of doas has been made to work on FreeBSD 11.x and newer, most distributions of Linux, and NetBSD 8.x and newer.

Installing doas is accomplished in three steps:
1. Installing build tools.
2. Compiling and installing the doas utility.
3. Creating a configuration file for doas.

1 - The doas program has virtually no dependencies. So long as you have a compiler (such as the GNU Compiler or Clang) installed and GNU make (gmake on NetBSD and FreeBSD).

2 - To install doas, download the source code and, in the source code's directory, run the command

     make (on Linux)
or
     gmake (on FreeBSD and NetBSD).
   
This builds the source code. Then, as the root user, run

     make install (on Linux)
or

     gmake install (on FreeBSD and NetBSD).

Note: The doas command is in FreeBSD's ports collection and may be installed by simply running the following command as the root user:

      pkg install doas 

Note: The doas command is in the pkgsrc collection and can be installed either via:

      cd /usr/pkgsrc/security/doas
      make clean; make install

or via binary package if available for your Operating System and architecture or port.

3 - The doas configuration file is located at /usr/local/etc/doas.conf. To create a rule allowing a user to perform admin actions, add a line to the configuration file. Details on how to do this are covered in the doas.conf manual page. However, most of the time a rule is as simple as

      permit <user> as root

Where <user> is the username of the person who is being granted root access. For instance:

      permit jesse as root

Additional users can be added to the file, one per line.

To make use of doas, run it in front of any command. Here are some examples:

Confirm doas is working by printing our effective user ID:

     doas id

Create a new file in the root user's home:

     doas touch /root/new-file

On Linux commands with arguments should be prefixed by a double-dash (--). Here we remove a directory owned by root:

     doas -- rm -rf old-directory
