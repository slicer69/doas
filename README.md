# doas
A port of OpenBSD's doas which runs on FreeBSD, Linux, NetBSD, illumos and macOS.

The doas utility is a program originally written for OpenBSD which allows a user to run a command as though they were another user. Typically doas is used to allow non-privleged users to run commands as though they were the root user. The doas program acts as an alternative to sudo, which is a popular method in the Linux community for granting admin access to specific users.

The doas program offers two benefits over sudo: its configuration file has a simple syntax and it is smaller, requiring less effort to audit the code. This makes it harder for both admins and coders to make mistakes that potentially open security holes in the system.

This port of doas has been made to work on FreeBSD 11.x and newer, most distributions of Linux, NetBSD 8.x and newer, and most illumos distributions (tested on OmniOS and SmartOS). It also works on macOS Catalina.

Installing doas is accomplished in three steps:
1. Installing build tools.
2. Compiling and installing the doas utility.
3. Creating a configuration file for doas.

## Installing build tools

1 - The doas program has virtually no dependencies. So long as you have a compiler (such as the GNU Compiler or Clang) installed and GNU make (gmake on NetBSD, FreeBSD, and illumos). On illumos, the build-essential package will install all the necessary build tools. Linux may need libpam headers to compile which can be added with the libpam0g-dev package on Debian/Ubuntu. On macOS an installation of XCode is necessary, due to the missing cli development tools in the default installation.

## Compiling and installing

2 - To install doas, download the source code and, in the source code's directory, run the command

#### Linux

     make
    
#### FreeBSD, NetBSD and macOS

     gmake

#### illumos

     PREFIX=/opt/local gmake

Alternatively, bison can be used if yacc is not installed.

     YACC="bison -y" PREFIX=/opt/local gmake
   
This builds the source code. Then, as the root user, run

#### Linux

     make install
     
Note to Linux users: Some Linux distributions, such as CentOS, will block doas from using PAM authentication by default. If this happens, it is usually possible to work around the issue by running the following command as the administrator:

      cp /etc/pam.d/sudo /etc/pam.d/doas


#### FreeBSD and NetBSD 

     gmake install

#### macOS

     gmake install
     cp /etc/pam.d/sudo /etc/pam.d/doas

Note: By default macOS blocks doas from using PAM modules, causing doas authentication to fail. The cp command above copies the sudo PAM configuration into place for doas to use.


#### illumos

     PREFIX=/opt/local gmake install

Note: The doas command is in FreeBSD's ports collection and may be installed by simply running the following command as the root user:

      pkg install doas

## Creating a configuration file

3 - The doas configuration file is located at /usr/local/etc/doas.conf or /opt/local/etc/doas.conf for illumos. To create a rule allowing a user to perform admin actions, add a line to the configuration file. Details on how to do this are covered in the doas.conf manual page. However, most of the time a rule is as simple as

      permit <user> as root

Where <user> is the username of the person who is being granted root access. For instance:

      permit jesse as root

Additional users can be added to the file, one per line.

To make use of doas, run it in front of any command. Here are some examples:

Confirm doas is working by printing our effective user ID:

     doas id

Create a new file in the root user's home:

     doas touch /root/new-file

On Linux versions of doas prior to 6.3p1 required commands with arguments to be prefixed by a double-dash (--). From 6.3p1 and onward the double-dash is no longer required. Here we remove a directory owned by root:

     doas -- rm -rf old-directory
