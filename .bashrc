################################################################################
### .bashrc

dotfiles=${BASH_SOURCE[0]%/*}

case ${OSTYPE} in
  linux*)
    ;;

  darwin*)
    # alias
    alias l.='ls -d .*'
    alias ll='ls -l -G'
    alias ls='ls -G'
    alias vi='vim'
    ;;

  msys)
    # alias
    alias ls='ls -F --color=auto --show-control-chars'
    alias ll='ls -l'
    alias ps='ps -Wael'
    alias vi='vim'
    alias vim='sakura.exe -CODE=4 -GROUP=9'
    ;;
esac

if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
    # autocd/globstar
    shopt -s autocd
    shopt -s globstar
fi

# less enable line number, prompt, raw
alias less='less -NMR'

# automatically correct mistyped directory names on cd
shopt -s cdspell

# histappend
shopt -s histappend

# share_history
function _share_history {
    history -a
}
if [[ ";$PROMPT_COMMAND;" != *";_share_history;"* ]]; then
    PROMPT_COMMAND="_share_history;$PROMPT_COMMAND";
fi

# grep options
{
    GREP_OPTIONS=()

    if echo | grep "--color=auto" >/dev/null 2>&1; then
        GREP_OPTIONS+=("--color=auto")
    fi

    if echo | grep "--exclude-dir=.svn,.git" >/dev/null 2>&1; then
        GREP_OPTIONS+=("--exclude-dir=.svn,.git")
    elif echo | grep "--exclude=.svn,.git" >/dev/null 2>&1; then
        GREP_OPTIONS+=("--exclude=.svn,.git")
    fi

    alias grep="grep $GREP_OPTIONS"
    unset GREP_OPTIONS
}

# phpenv
if hash phpenv 2>/dev/null; then
    eval "$(phpenv init -)"
fi

# rbenv
if hash rbenv 2>/dev/null; then
    eval "$(rbenv init -)"
fi

# pyenv
if hash pyenv 2>/dev/null; then
    eval "$(pyenv init -)"
fi

# direnv
if hash direnv 2>/dev/null; then
    eval "$(direnv hook bash)"
fi

# function
eval "$(
    for fn in "$dotfiles"/function/*.sh; do
        echo source \"$fn\"
    done
)"

# cleanup
unset dotfiles
