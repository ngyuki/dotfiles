################################################################################
### .bash_profile

dotfiles=${BASH_SOURCE[0]%/*}

case ${OSTYPE} in
  linux*)
    if type wsl.exe >/dev/null 2>&1; then
      # PATH $dotfiles/bin.win
      export PATH=$dotfiles/bin.wsl:$PATH

      # ssh-agent
      [ ! -d ~/.ssh/ ] && install -m0700 -d ~/.ssh/
      export DOTFILES_SSH_AGENT_FILE=~/.ssh/ssh-agent

      # vagrant
      export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

    elif type temoto >/dev/null 2>&1; then
      # PATH $dotfiles/bin.temoto
      export PATH=$dotfiles/bin.temoto:$PATH
    fi
    ;;

  msys)
    if [ -n "$PhpStorm" ]; then
      export ConEmuANSI=ON
      export ANSICON=1
    fi
    if [ -n "$CONEMUANSI" ]; then
      export ConEmuANSI=$CONEMUANSI
      export ANSICON=1
    fi
    ;;
esac

# PATH $dotfiles/bin
if [[ ":$PATH:" != *":$dotfiles/bin:"* ]]; then
  export PATH=$dotfiles/bin:$PATH
fi

# PATH ~/bin
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  export PATH=$HOME/bin:$PATH
fi

# editor
export EDITOR=vim

# man enable prompt, raw
export MANPAGER='less -MR'

# ignore dll for WSL
export FIGNORE=".dll:.DLL"

# less colors
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

# fzf
if type fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--reverse --ansi --color=16 --inline-info'
fi

# ssh-agent
if [ -n "$DOTFILES_SSH_AGENT_FILE" ]; then
  if [ -f "$DOTFILES_SSH_AGENT_FILE" ] ; then
    source "$DOTFILES_SSH_AGENT_FILE" > /dev/null
  fi
  ssh-add -l > /dev/null 2>&1
  if [ $? -gt 1 ]; then
    rm -rf /tmp/ssh-*
    ssh-agent > "$DOTFILES_SSH_AGENT_FILE"
    source "$DOTFILES_SSH_AGENT_FILE" > /dev/null
    ssh-add 2> /dev/null
  fi
fi

# packer
if [[ -z $PACKER_CACHE_DIR ]]; then
  export PACKER_CACHE_DIR=$HOME/.packer/
fi

# phpenv
if [[ -x $HOME/.phpenv/bin/phpenv ]]; then
  export PATH=$HOME/.phpenv/bin:$PATH
fi

# rbenv
if [[ -x $HOME/.rbenv/bin/rbenv ]]; then
  export PATH=$HOME/.rbenv/bin:$PATH
fi

# pyenv
if [[ -x $HOME/.pyenv/bin/pyenv ]]; then
  export PATH=$HOME/.pyenv/bin:$PATH
fi

# nvm
if [[ -s $HOME/.nvm/nvm.sh ]]; then
  export NVM_DIR=$HOME/.nvm
fi

# vagrant
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
  if [[ -z $VAGRANT_DOTFILE_PATH ]]; then
    export VAGRANT_DOTFILE_PATH=.vagrant-${HOSTNAME,,}
  fi
fi

# hman (man2html)
if hash temoto 2>/dev/null && hash hman 2>/dev/null; then
  export MANHTMLHOST=$HOSTNAME
  export MANHTMLPAGER='temoto open'
fi

# cleanup
unset dotfiles
