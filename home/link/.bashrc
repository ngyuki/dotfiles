################################################################################
### .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# 非対話モードではスキップ (ssh <host> <command> など)
if [[ ! $- =~ i ]]; then
  return
fi

case ${OSTYPE} in
  linux*)
    if type wsl.exe >/dev/null 2>&1; then
      function __bash_prompt_command(){
        if [ $? -eq 0 ]; then
          local status='\[\e[0;37m\]\$'
        else
          local status='\[\e[0;31m\]\$'
        fi
        if hash __git_ps1 2>/dev/null; then
          local git=$(__git_ps1 " \\e[0;36m(%s)")
        else
          local git=
        fi
        PS1="\e]0;\u\007\n\e[0;35m\u@\h \e[0;33m\w$git\n$status \[\e[0m\]"
      }
      if [[ ";$PROMPT_COMMAND;" != *";__bash_prompt_command;"* ]]; then
        PROMPT_COMMAND="__bash_prompt_command;$PROMPT_COMMAND";
      fi
    else
      # POSIX
      PS1=$"\n\e[4$(( $(uname -n | sum | cut -f1 -d' ' | sed 's/^0*//') % 7 + 1 ));30m \e[m \e[0;36m\u@\h \e[0;33m\w\e[0m\n\\$ "
    fi
    ;;

  darwin*)
    PS1='\n\e[0;32m\u@\h \e[0;33m\w\e[0m\n\$ '
    ;;

  msys)
    PS1='\n\e[0;32m\u@\h \e[0;33m\w\e[0m\n\$ '
    ;;
esac

# umask
umask 0022

# alias
alias ls='ls --color=auto'
alias la='ls -A'
alias ll='ls -alF'
alias l.='ls -d .*'
alias l='ls -CF'
alias vi='vim'

case ${OSTYPE} in
  msys)
    alias ls='ls --color=auto --show-control-chars'
    alias ps='ps -Wael'
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

# history
HISTSIZE=9999
HISTFILESIZE=$HISTSIZE
HISTTIMEFORMAT='[%y/%m/%d %H:%M:%S] '
HISTCONTROL=ignoreboth
HISTIGNORE='halt *:shutdown *:reboot *:poweroff *'

# grep options
if hash grep 2>/dev/null; then
    grep_options=()
    if echo | grep '--color=auto' '' >/dev/null 2>&1; then
        grep_options+=('--color=auto')
    fi
    if echo | grep '--exclude-dir=.svn,.git' '' >/dev/null 2>&1; then
        grep_options+=('--exclude-dir=.svn,.git')
    elif echo | grep '--exclude=.svn,.git' '' >/dev/null 2>&1; then
        grep_options+=('--exclude=.svn,.git')
    fi
    alias grep="grep ${grep_options[@]}"
    alias egrep="egrep ${grep_options[@]}"
    alias fgrep="fgrep ${grep_options[@]}"

    unset grep_options
fi

# delay
PROMPT_COMMAND="__bash_delay;$PROMPT_COMMAND";__bash_delay(){ __bash_delay(){ :; }

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

  # nvm
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
  fi

  # direnv
  if hash direnv 2>/dev/null; then
    eval "$(direnv hook bash)"
  fi

  # awscli
  if hash aws 2>/dev/null; then
    complete -C aws_completer aws
  fi

  # bash.d
  local dotfiles fn
  dotfiles="$(realpath -- "${BASH_SOURCE[0]}")"
  dotfiles="$(realpath -- ${dotfiles%/*}/../../)"
  for fn in "$dotfiles"/bash.d/*.sh; do
    source "$fn"
  done
}
