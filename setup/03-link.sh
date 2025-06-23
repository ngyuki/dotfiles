#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "create symbolic links"

if [ -n "${WINDIR-}" ]; then
  {
    echo "skipped, because windows"
    echo "please use ... wscript setup.wsf"
  } | pcat
  exit 0
fi

files=(
  .gitignore_global
  .inputrc
  .tigrc
  .config/starship.toml
  .config/ripgreprc
)

(
  for fn in "${files[@]}"; do
    src="$PWD/${fn}"
    dst="$HOME/${fn}"
    ln -vsf "$src" "$dst"
  done
  ln -vsfn "$PWD/.editorconfig.global" "$HOME/.editorconfig"
  ln -vsfn "$PWD/claude/settings.json" "$HOME/.claude/settings.json"
) | pcat
