#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "fish/dotfiles.fish"
ln -sfnv "$PWD/fish/dotfiles.fish" "$HOME/.config/fish/conf.d/dotfiles.fish" | pcat
