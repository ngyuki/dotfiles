#!/bin/bash

source "$(dirname "$0")/functions.sh"

if [[ -e "$HOME/.config/fish/conf.d"/ ]]; then
  pp "fish/dotfiles.fish"
  ln -sfnv "$PWD/fish/dotfiles.fish" "$HOME/.config/fish/conf.d/dotfiles.fish" | pcat
fi
