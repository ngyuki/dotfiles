################################################################################
### .bash_profile

if [ $CLAUDECODE ]; then
  return
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

dotfiles="$(realpath -- "${BASH_SOURCE[0]}")"
dotfiles="$(realpath -- ${dotfiles%/*}/../)"

# PATH $dotfiles/bin.wsl
if [[ ":$PATH:" != *":$dotfiles/bin.wsl:"* ]]; then
  export PATH=$dotfiles/bin.wsl:$PATH
fi

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

# PATH ~/.local/bin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH=$HOME/.local/bin:$PATH
fi

# EDITOR
if [[ -z $EDITOR ]]; then
  export EDITOR='code -w'
fi

# PAGER
if [[ -z $PAGER ]]; then
  export PAGER=less
fi

# ls time-style
export TIME_STYLE=long-iso

# man enable prompt, raw
export MANPAGER='less -MR'

# ignore dll for WSL
export FIGNORE=".dll:.DLL"

# less
export LESS="-#4 -FXMR"
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

# fzf
if type fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--ansi --inline-info --bind ctrl-s:toggle-sort'
fi

# vagrant
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1
export VAGRANT_WSL_DISABLE_VAGRANT_HOME=1
export VAGRANT_HOME=$HOME/.vagrant.d

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

# gpg ... aws-vault から pass 経由で呼ばれるときはプロンプトが tty でなければならない
export GPG_TTY="$(tty)"

# deno
if [ -d "$HOME/.deno/bin" ]; then
  export PATH=$HOME/.deno/bin:$PATH
fi

# ssh-agent
eval "$(SHELL=/bin/bash keychain --eval --quiet --quick)"
ssh-add 2>/dev/null

# aws-vault
export AWS_VAULT_BACKEND=pass
export AWS_VAULT_PASS_PREFIX=aws-vault/
export AWS_SESSION_TOKEN_TTL=12h
export AWS_FEDERATION_TOKEN_TTL=12h

# ripgrep
export RIPGREP_CONFIG_PATH=~/.config/ripgreprc

# cleanup
unset dotfiles

# bash_profile.d
if [[ -d "$HOME"/.bash_profile.d ]]; then
  for _ in "$HOME"/.bash_profile.d/*.sh; do
    source "$_"
  done
  unset _
fi

# fish ... vscode で remote container で docker-compose を使うときに fish だとダメっぽいので
# https://github.com/microsoft/vscode-remote-release/issues/6111
if [ -v REMOTE_CONTAINERS_IPC -a -v REMOTE_CONTAINERS_SOCKETS ]; then
  return
fi

if [ "$0" == "-bash" ]; then
  return
fi

case "$BASH_EXECUTION_STRING" in
  fish)
    exec fish
    ;;
  tmux)
    if tmux has-session 2>/dev/null; then
      exec tmux attach-session
    else
      # SHELL 環境変数を設定すれば tmux の new-window で fish が直接起動する
      # .bash_profile は tmux サーバ起動時の初回のみロードされるため変更時は tmux サーバのリスタートが必要です
      export SHELL=/bin/fish
      exec tmux new-session
    fi
    ;;
esac
