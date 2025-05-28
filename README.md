# doas - doas for every system

A port of OpenBSD's `doas` which runs on FreeBSD, Linux, NetBSD, illumos,
macOS and MidnightBSD.

The `doas` utility is a program originally written for OpenBSD which allows
a user to run a command as though they were another user. Typically `doas`
is used to allow non-privileged users to run commands as though they were
the root user. The `doas` program acts as an alternative to sudo, which is
a popular method in the Linux community for granting admin access to
specific users.

The `doas` program offers two benefits over sudo: its configuration file
has a simple syntax and it is smaller, requiring less effort to audit the
code. This makes it harder for both admins and coders to make mistakes that
potentially open security holes in the system.

This port of `doas` has been made to work on FreeBSD 11.x and newer, most
distributions of Linux, NetBSD 8.x and newer, and most illumos
distributions (tested on OmniOS and SmartOS). It also works on macOS
Sonoma.

Installing `doas` is accomplished in three steps:

0. Optionally install the package/port for your operating system, OR
1. Installing build tools.
2. Compiling and installing the `doas` utility.
3. Creating a configuration file for `doas`.

## Getting Started

### 0. Installation via packages/repositories:

For Arch Linux users (and Arch-based distributions) there is [a package
available in the AUR](https://aur.archlinux.org/packages/doas/):
```sh
git clone https://aur.archlinux.org/doas.git
cd doas
makepkg -si
```

The `doas` command is in FreeBSD's ports collection and may be installed by
simply running the following command as the root user:

```sh
pkg install doas
```

Also from MidnightBSD's mports collection with:

```sh
mport install doas
```

Or from [Pacstall](https://github.com/pacstall/pacstall) (Debian/Ubuntu):

```sh
pacstall -I doas-git
```

### 1. Installing build tools

The `doas` program has virtually no dependencies. So long as you have a
compiler (such as the GNU Compiler or Clang) installed and GNU `make`
(`gmake` on NetBSD, FreeBSD, and illumos). On illumos, the build-essential
package will install all the necessary build tools.

#### Debian and Ubuntu-based distributions

```sh
sudo apt install build-essential make bison flex libpam0g-dev
```

#### Fedora

```sh
sudo dnf install gcc gcc-c++ make flex bison pam-devel byacc
```

#### CentOS 8 and Stream

```sh
sudo dnf install gcc gcc-c++ make flex bison pam-devel byacc git
```

#### CentOS 7.x

```sh
sudo yum install gcc gcc-c++ make flex bison pam-devel byacc git
```

#### openSUSE and SUSE Linux Enterprise

```sh
sudo zypper install gcc gcc-c++ make flex bison pam-devel byacc git
```

#### OmniOS (and possibly other illumos variants)

```sh
pfexec pkg install build-essentials
```

#### macOS

```sh
xcode-select --install
```

### 2. Compiling and installing

To install `doas`, download the source code and, in the source code's
directory, run one of the below commands:

#### Linux

```sh
make
```

#### FreeBSD, MidnightBSD, NetBSD

```sh
gmake
```

#### illumos

```sh
PREFIX=/opt/local gmake
```

Alternatively, bison can be used if yacc is not installed.

```sh
YACC="bison -y" PREFIX=/opt/local gmake
```

#### OmniOS

```sh
YACC="bison -y" CFLAGS+="-DOMNIOS_PAM" pfexec gmake
```

This builds the source code. Then, as the root user, run

#### Linux

```sh
make install
```

> [!NOTE]  
> Some Linux distributions, such as CentOS, will block `doas` from using
> PAM authentication by default. If this happens, it is usually possible to
> work around the issue by running the following command as the
> administrator:
> ```sh
> cp /etc/pam.d/sudo /etc/pam.d/doas
> ```

In situations where you do not have a `/etc/pam.d/sudo` file (perhaps due
to sudo not being installed) then create a new file with your preferred
text editor called `/etc/pam.d/doas` and insert the following lines:

```sh
#%PAM-1.0
@include common-auth
@include common-account
@include common-session-noninteractive
```

After you save this file you may need to reboot for the change to take
effect.

#### FreeBSD, MidnightBSD, NetBSD, and OmniOS

```sh
gmake install
```

#### macOS

To build `doas`, you'll need to have Xcode Command Line Tools, and use
`bison` instead of `byacc`:

```sh
YACC='bison -y' PREFIX=/opt/local make
```

Alternatively, if you have Xcode.app installed, you can just:

```sh
xcode-select --switch /Applications/Xcode.app/Contents/Developer
make
```

Lastly, run the following:

```sh
make install
cp /etc/pam.d/sudo /etc/pam.d/doas
```

> [!NOTE]
> By default macOS blocks `doas` from using PAM modules, causing `doas`
> authentication to fail. The cp command above copies the sudo PAM
> configuration into place for `doas` to use.

> [!WARNING]
> Former macOS systems have been reported to have their `/usr` and/or
> `/usr/local` directories set to be writable to regular user accounts when
> homebrew is installed. If this is the case, fix this before installing
> `doas`. Having these directories, like `/usr/local/bin` and
> `/usr/local/etc`, writable to your user means anyone can remove and
> replace your `doas.conf` file or the `doas` binary, allowing anyone or
> any program to run commands as root on your system or harvest your
> password. This is a large security hole and outside the scope of `doas`.

#### illumos

```sh
PREFIX=/opt/local gmake install
```

## 3. Creating a configuration file

The `doas` configuration file is located at `/usr/local/etc/doas.conf` or
`/opt/local/etc/doas.conf` for illumos. To create a rule allowing a user to
perform admin actions, add a line to the configuration file. Details on how
to do this are covered on the `doas.conf` manual page. However, most of the
time a rule is as simple as

```sh
permit <user> as root
```

Where "user" is the username of the person who is being granted root
access. For instance:

```sh
permit jesse as root
```

Additional users can be added to the file, one per line.

> [!NOTE]
> A shell script, `vidoas`, is included with the `doas` program. The
> `vidoas` script must be run as the root user and will perform a syntax
> check on the `doas.conf` file before installing it on the system. This
> avoids breaking the `doas.conf` file. The `vidoas` script accepts no
> parameters and can be simply run as
>
> ```sh
> vidoas
> ```

## Desktop applications (GUI applications)

Please be aware that, by default, `doas` scrubs most environment variables.
In effect this means certain information about your environment will not be
passed to the target user and graphical desktop applications (GUI
applications) will not be able to run. To enable graphical applications to
run from `doas`, please use the `keepenv` keyword in the configuration file.
See the doas.conf manual page for details.

## Running commands using doas

To make use of `doas`, run it in front of any command. Here are some
examples:

Confirm `doas` is working by printing our effective user ID:
```sh
doas id
```

Create a new file in the root user's home:
```sh
doas touch /root/new-file
```

Edit a text file that requires admin access without running the text
editor as the root user:
```sh
doasedit /path/to/text/file
```

On Linux versions of `doas` prior to `6.3p1` required commands with
arguments to be prefixed by a double-dash (--). From `6.3p1` and onward the
double-dash is no longer required. Here we remove a directory owned by
root:
```sh
doas -- rm -rf old-directory
```

## Uninstalling `doas`

To remove `doas` and its helper programs, you can pass the "uninstall"
parameter to the `Makefile`. On most Linux distributions, you can run the
following from the `doas` source directory:

```sh
make uninstall
```

While on most other platforms, such as FreeBSD, you can run:
```sh
gmake uninstall
```

## Contributing

Contributions, in various forms, are always welcome. If you run into a
problem or have an improvement you'd like to see included, please use
GitHub's tools to submit an issue ticket or a pull request. Should you
encounter a bug  you feel is a security concern, please contact the
developer privately at jessefrgsmith AT yahoo DOT ca.

Financial donations are always welcome and can be submitted via PayPal to
jessefrgsmith AT yahoo DOT ca or through Patreon at
https://www.patreon.com/sysvinit. Thank you for your support.
