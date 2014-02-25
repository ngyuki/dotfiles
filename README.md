# dotfiles

## setup linux

> ref. https://code.google.com/p/git-core/downloads/list

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

```console
$ cd
$ git clone git@bitbucket.org:ngyuki/dotfiles.git
$ dotfiles/setup.sh
```

## setup windows

*DoubleClick* dotfiles/setup.wsf
