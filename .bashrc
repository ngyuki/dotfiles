################################################################################
### .bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

case ${OSTYPE} in
  linux*)
    # alias
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias l.='ls -d .*'
    alias vi='vim'
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

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# @ から始まる単語の保管を無効にする
shopt -u hostcomplete

# share_history
function _share_history {
    history -a
}
if [[ ";$PROMPT_COMMAND;" != *";_share_history;"* ]]; then
    PROMPT_COMMAND="_share_history;$PROMPT_COMMAND";
fi

# grep options
if hash grep 2>/dev/null; then
    grep_options=()
    if echo | grep '--color=auto' '' >/dev/null '' 2>&1; then
        grep_options+=('--color=auto')
    fi
    if echo | grep '--exclude-dir=.svn,.git' '' >/dev/null 2>&1; then
        grep_options+=('--exclude-dir=.svn,.git')
    elif echo | grep '--exclude=.svn,.git' '' >/dev/null 2>&1; then
        grep_options+=('--exclude=.svn,.git')
    fi
    alias grep="grep ${grep_options[@]}"
    unset grep_options
fi

# phpenv
if hash phpenv 2>/dev/null; then
    eval "$(phpenv init - --no-rehash)"
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

# bash.d
for fn in "${BASH_SOURCE[0]%/*}"/bash.d/*.sh; do
    source "$fn"
done
