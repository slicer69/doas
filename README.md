# doas
A port of OpenBSD's doas which runs on FreeBSD, Linux, NetBSD, illumos, macOS and MidnightBSD.

The doas utility is a program originally written for OpenBSD which allows a user to run a command as though they were another user. Typically doas is used to allow non-privileged users to run commands as though they were the root user. The doas program acts as an alternative to sudo, which is a popular method in the Linux community for granting admin access to specific users.

The doas program offers two benefits over sudo: its configuration file has a simple syntax and it is smaller, requiring less effort to audit the code. This makes it harder for both admins and coders to make mistakes that potentially open security holes in the system.

This port of doas has been made to work on FreeBSD 11.x and newer, most distributions of Linux, NetBSD 8.x and newer, and most illumos distributions (tested on OmniOS and SmartOS). It also works on macOS Catalina.

Installing doas is accomplished in three steps:

0. Optionally install the package/port for your operating system, OR
1. Installing build tools.
2. Compiling and installing the doas utility.
3. Creating a configuration file for doas.

## Installation via packages/repositories:

[For Arch Linux users (and Arch-based distributions) there is a package available in the AUR:](https://aur.archlinux.org/packages/doas/)
```
 ~ git clone https://aur.archlinux.org/doas.git
 ~ cd doas
 ~ makepkg -si
```

The doas command is in FreeBSD's ports collection and may be installed by simply running the following command as the root user:

      pkg install doas

The doas command may be installed from MidnightBSD's mports collection with: 

      mport install doas
      
The doas command may be installed from [Pacstall](https://github.com/pacstall/pacstall) (Debian/Ubuntu) with: 

      pacstall -I doas-git
      
## Installing build tools

1 - The doas program has virtually no dependencies. So long as you have a compiler (such as the GNU Compiler or Clang) installed and GNU make (gmake on NetBSD, FreeBSD, and illumos). On illumos, the build-essential package will install all the necessary build tools. 

#### Debian and Ubuntu based distributions

     sudo apt install build-essential make bison flex libpam0g-dev 

#### Fedora

      sudo dnf install gcc gcc-c++ make flex bison pam-devel byacc

#### CentOS 8 and Stream

      sudo dnf install gcc gcc-c++ make flex bison pam-devel byacc git

#### CentOS 7.x

      sudo yum install gcc gcc-c++ make flex bison pam-devel byacc git

#### openSUSE and SUSE Linux Enterprise

      sudo zypper install gcc gcc-c++ make flex bison pam-devel byacc git

#### macOS

     xcode-select --install

## Compiling and installing

2 - To install doas, download the source code and, in the source code's directory, run the command

#### Linux

     make
    
#### FreeBSD, MidnightBSD, NetBSD and macOS

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

In situations where you do not have a /etc/pam.d/sudo file (perhaps due to sudo not being installed)
then create a new file with your preferred text editor called /etc/pam.d/doas and insert the
following lines:

      #%PAM-1.0
      @include common-auth
      @include common-account
      @include common-session-noninteractive

After you save this file you may need to reboot in order for the change to take effect.


#### FreeBSD, MidnightBSD and NetBSD 

     gmake install

#### macOS

     gmake install
     cp /etc/pam.d/sudo /etc/pam.d/doas

Note: By default macOS blocks doas from using PAM modules, causing doas authentication to fail. The cp command above copies the sudo PAM configuration into place for doas to use.

Please also note that macOS systems have been reported to have their /usr and/or /usr/local
directories set to be writable to regular user accounts when homebrew is installed. If this is the case, fix this before
installing doas. Having these directories, like /usr/local/bin and /usr/local/etc, writable
to your user means anyone can remove and replace your doas.conf file or the doas binary,
allowing anyone or any program to run commands as root on your system or harvest your password.
This is a large security hole and outside the scope of doas.


#### illumos

     PREFIX=/opt/local gmake install


## Creating a configuration file

3 - The doas configuration file is located at /usr/local/etc/doas.conf or /opt/local/etc/doas.conf for illumos. To create a rule allowing a user to perform admin actions, add a line to the configuration file. Details on how to do this are covered in the doas.conf manual page. However, most of the time a rule is as simple as

      permit <user> as root

Where "user" is the username of the person who is being granted root access. For instance:

      permit jesse as root

Additional users can be added to the file, one per line.

Please note that a shell script, vidoas, is included with the doas program. The vidoas
script must be run as the root user and will perform a syntax check on the doas.conf
file before installing it on the system. This avoids breaking the doas.conf file. The
vidoas script accepts no parameters and can be simply run as

      vidoas

## Desktop applications (GUI applications)

Please be aware that, by default, doas scrubs most environment variables. In effect 
this means certain information about your environment will not be passed to the target
user and graphical desktop applications (GUI applications) will not be able to run.
To enable graphical applications to run from doas, please use the keepenv keyword
in the configuration file. See the doas.conf manual page for details.

## Running commands using doas

To make use of doas, run it in front of any command. Here are some examples:

Confirm doas is working by printing our effective user ID:

     doas id

Create a new file in the root user's home:

     doas touch /root/new-file

Edit a text file which requires admin access without running the text editor
as the root user:

     doasedit /path/to/text/file

On Linux versions of doas prior to 6.3p1 required commands with arguments to be prefixed by a double-dash (--). From 6.3p1 and onward the double-dash is no longer required. Here we remove a directory owned by root:

     doas -- rm -rf old-directory

## Removing doas

To remove the doas program and its helper programs, you can pass the Makefile the
"uninstall" parameter. On most Linux distributions you can run the following from the
doas source directory:

     make uninstall

while on most other platforms, such as FreeBSD, you can run

     gmake uninstall


## Contributing

Contributions, in various forms, are always welcome. If you run into a problem or have an improvement you'd like to see included, please use GitHub's tools to submit an issue ticket or a pull request. Should you encounter a bug  you feel is a security concern, please contact the developer privately at jessefrgsmith AT yahoo DOT ca.

Financial donations are always welcome and can be submitted via PayPal to jessefrgsmith AT yahoo DOT ca or through Patreon at https://www.patreon.com/sysvinit . Thank you for your support.
