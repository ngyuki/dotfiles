# dotfiles

## Setup for Linux

### Download public keys

```console
mkdir -p ~/.ssh/
wget https://github.com/ngyuki.keys -O ~/.ssh/authorized_keys
chmod 700 ~/.ssh/
chmod 600 ~/.ssh/authorized_keys
```

### Install Git (optional)

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

## Setup for Windows

DoubleClick dotfiles/setup.wsf
