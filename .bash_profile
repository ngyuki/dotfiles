################################################################################
### .bash_profile

dotfiles=${BASH_SOURCE[0]%/*}

case ${OSTYPE} in
  linux*)
    if uname -r | grep Microsoft >/dev/null 2>&1; then
      # PATH $dotfiles/bin.win
      export PATH=$dotfiles/bin.wsl:$PATH

      # ssh-agent
      if [[ -e ~/.ssh/wsl-ssh-agent-gui.sock ]]; then
        # wsl-ssh-agent-gui
        export SSH_AUTH_SOCK=$(readlink -f ~/.ssh/wsl-ssh-agent-gui.sock)
        ssh-add </dev/null >/dev/null 2>/dev/null
      elif [[ -e "/c/Users/$USER/.ssh/.ssh-agent" ]]; then
        # pageant+
        export SSH_AUTH_SOCK="/c/Users/$USER/.ssh/.ssh-agent"
      else
        # openssh
        if [ -f ~/.ssh/ssh-agent.env ] ; then
          source ~/.ssh/ssh-agent.env > /dev/null
        fi
        ssh-add -l > /dev/null 2>&1
        if [ $? -gt 1 ]; then
          install -m0700 -d ~/.ssh/
          rm -rf /tmp/ssh-*
          ssh-agent > ~/.ssh/ssh-agent.env
          source ~/.ssh/ssh-agent.env > /dev/null
          ssh-add 2> /dev/null
        fi
      fi

      # vagrant
      export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
      export VAGRANT_WSL_DISABLE_VAGRANT_HOME=1
      export VAGRANT_HOME=$HOME/.vagrant.d

      # editor
      export EDITOR='code -w'

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

# PATH $dotfiles/bin.local
if [[ ":$PATH:" != *":$dotfiles/bin.local:"* ]]; then
  export PATH=$dotfiles/bin.local:$PATH
fi

# PATH ~/bin
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  export PATH=$HOME/bin:$PATH
fi

# editor
if [[ -z $EDITOR ]]; then
  export EDITOR=vim
fi

# editor
if [[ -z $PAGER ]]; then
  export PAGER=less
fi

# ls time-style
export TIME_STYLE=long-iso

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
  export FZF_DEFAULT_OPTS='--ansi --color=16 --inline-info'
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

# golang
if [[ -d $HOME/go/bin ]]; then
  export PATH=$HOME/go/bin:$PATH
fi

# vagrant
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
  if [[ -z $VAGRANT_DOTFILE_PATH ]]; then
    export VAGRANT_DOTFILE_PATH=.vagrant-${HOSTNAME,,}
  fi
fi

# ansible
export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_GATHERING=explicit
export ANSIBLE_PIPELINING=true
export ANSIBLE_RETRY_FILES_ENABLED=false

# docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# mdlive
export MDLIVE_BROWSER='open'

# homebrew
export HOMEBREW_NO_AUTO_UPDATE=1

# terraform
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

# cleanup
unset dotfiles

# bash_profile.d
if [[ -d "$HOME"/.bash_profile.d ]]; then
  for _ in "$HOME"/.bash_profile.d/*.sh; do
    source "$_"
  done
  unset _
fi

# fish
if hash fish 2>/dev/null; then
  exec fish
fi
