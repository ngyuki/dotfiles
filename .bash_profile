################################################################################
### bash_profile

dotfiles=${BASH_SOURCE[0]%/*}

if [ -z "$WINDIR" ]; then

    # POSIX
    export PS1='\n\e[0;31m\u@\h \e[0;33m\w\e[0m\n\$ '
    export EDITOR=vim

    # grep options for colors
    export GREP_OPTIONS="--color=auto"

    # autocd
    shopt -s autocd
else

    # Windows
    export PS1='\n\e[0;32m\u@\h \e[0;33m\w\e[0m\n\$ '
    export TERM=msys
    export EDITOR='sakura.exe -CODE=4 -GROUP=9'

    if [ -n "$PhpStorm" ]; then
        export ConEmuANSI=ON
        export ANSICON=1
    fi

    if [ -n "$CONEMUANSI" ]; then
        export ConEmuANSI=$CONEMUANSI
        export ANSICON=1
    fi

    alias vi='start sakura'
    alias ls='ls -F --color=auto --show-control-chars'
    alias ll='ls -l'
    alias ps='ps -Wael'

    # dotfiles/win
    export PATH="$dotfiles/win:$PATH"
fi

# dotfiles/bin
export PATH="$dotfiles/bin:$PATH"

# man enable prompt, raw
export MANPAGER='less -MR'

# automatically correct mistyped directory names on cd
shopt -s cdspell

# history append for multi terminal
shopt -s histappend

# less enable line number, prompt, raw
alias less='less -NMR'

# less colors
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

# history
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTTIMEFORMAT='[%y/%m/%d %H:%M:%S] '
export HISTCONTROL=ignoredups
export HISTIGNORE='ls:cd:cd -:pwd:history*:exit:date'

# golang
export GOPATH=$HOME/.golang
export PATH=$GOPATH/bin:$PATH

# rbenv
if [ -d "$HOME/.rbenv/bin" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# pyenv
if [ -d "$HOME/.pyenv/bin" ]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
fi

# phpenv
if [ -d "$HOME/.phpenv/bin" ]; then
    export PATH="$HOME/.phpenv/bin:$PATH"
    eval "$(phpenv init -)"
fi

# function
eval "$(
    for fn in "$dotfiles"/function/*.sh; do
        echo source \"$fn\"
    done
)"

# cleanup
unset dotfiles
