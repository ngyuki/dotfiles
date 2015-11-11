################################################################################
### .bash_profile

dotfiles=${BASH_SOURCE[0]%/*}

case ${OSTYPE} in
  linux*)
    # POSIX
    export PS1=$"\n\e[4$(( $(uname -n | sum | cut -f1 -d' ' | sed 's/^0*//') % 7 + 1 ));30m \e[m \e[0;36m\u@\h \e[0;33m\w\e[0m\n\\$ "

    # $dotfiles/bin.linux, $HOME/bin
    export PATH=$HOME/bin:$dotfiles/bin.linux:$PATH
    ;;

  darwin*)
    # MAC
    export PS1='\n\e[0;32m\u@\h \e[0;33m\w\e[0m\n\$ '

    # $dotfiles/bin.mac, $HOME/bin
    export PATH=$HOME/bin:$dotfiles/bin.mac:$PATH
    ;;

  msys)
    # Windows
    export PS1='\n\e[0;32m\u@\h \e[0;33m\w\e[0m\n\$ '

    if [ -n "$PhpStorm" ]; then
        export ConEmuANSI=ON
        export ANSICON=1
    fi

    if [ -n "$CONEMUANSI" ]; then
        export ConEmuANSI=$CONEMUANSI
        export ANSICON=1
    fi

    # dotfiles/win
    export PATH="$dotfiles/win:$PATH"
    ;;
esac

# dotfiles/bin
export PATH="$dotfiles/bin:$PATH"

# editor
export EDITOR=vim

# grep options for colors
export GREP_OPTIONS="--color=auto"

# man enable prompt, raw
export MANPAGER='less -MR'

# less colors
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

# history
export HISTSIZE=9999
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT='[%y/%m/%d %H:%M:%S] '
export HISTCONTROL=ignoredups
export HISTIGNORE='ls:cd:cd -:pwd:history*:exit:date'

# packer
if [ -z "$PACKER_CACHE_DIR" ]; then
    export PACKER_CACHE_DIR=$HOME/.packer/
fi

# phpenv
if [ -d "$HOME/.phpenv/bin" ]; then
    export PATH="$HOME/.phpenv/bin:$PATH"
fi

# rbenv
if [ -d "$HOME/.rbenv/bin" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
fi

# pyenv
if [ -d "$HOME/.pyenv/bin" ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
fi

# golang
export GOPATH=$HOME/.golang
export PATH=$GOPATH/bin:$PATH

# vagrant
export VAGRANT_DOTFILE_PATH=".vagrant-$(uname -n | tr '[A-Z]' '[a-z]')"

# check last update
if [ "$(find "$dotfiles/.git/" -maxdepth 0 -mtime +60 | wc -l)" -ne 0 ]; then
    printf "\e[0;33m%s\e[m\n" "Warning: dotfiles is over 60 days old." 1>&2
    printf "\e[0;33m%s\e[m\n" "Warning: Please try \"cd $dotfiles; git pull --rebase\"" 1>&2
fi

# .bashrc
source "$dotfiles/.bashrc"

# cleanup
unset dotfiles
