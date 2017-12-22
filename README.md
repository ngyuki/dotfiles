# dotfiles

## Support

- Windows subsystem for Linux
    - Ubuntu 16.04.3 LTS (Xenial Xerus)
    - bash 4.3.48
    - git 2.7.4
- Windows 10 (Git bash)
    - bash 4.4.12
    - git 2.15.1
- CentOS 7
    - CentOS 7.4.1708
    - bash 4.2.46
    - git 2.15.0

## Setup for Linux

### Download public keys

```console
mkdir -p ~/.ssh/
wget https://github.com/ngyuki.keys -O ~/.ssh/authorized_keys
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/authorized_keys
```

### Install Git

[https://code.google.com/p/git-core/downloads/list](https://code.google.com/p/git-core/downloads/list)

```console
$ sudo yum install gcc make zlib-devel perl-devel gettext curl-devel
$ mkdir -p ~/src
$ cd ~/src
$ wget https://git-core.googlecode.com/files/git-1.8.3.4.tar.gz
$ tar xzvf git-1.8.3.4.tar.gz
$ cd git-1.8.3.4
$ ./configure
$ make
$ sudo make install
$ git --version
```

### Checkout and run setup

```console
$ cd
$ git clone git@github.com:ngyuki/dotfiles.git
$ dotfiles/setup.sh
$ exec bash --login
```

## Setup for Linux (without git)

### Download and setup dotfiles

```console
$ cd
$ wget --no-check-certificate https://github.com/ngyuki/dotfiles/archive/master.tar.gz -O - | tar xvzf -
$ mv dotfiles-master dotfiles
$ dotfiles/setup.sh
$ exec bash --login
```

## Setup for Windows

DoubleClick dotfiles/setup-win.bat
