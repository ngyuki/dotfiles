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

(
  cd -- "$PWD/home"

  find -type d -name '*.symlink' -prune -print -o -type f -print \
  | while read -r f; do
    src="$PWD/${f#./}"
    dst="$HOME/${f#./}"
    dir="${dst%/*}"
    dst="${dst%.symlink}"
    # mkdir -pv "$dir"
    # ln -vsfn "$src" "$dst"
    if [ -h "$dst" ]; then
      unlink "$dst"
    fi
    if [ -d "$src" ]; then
      rsync -a "$src/" "$dst/"
    else
      rsync -a "$src" "$dst"
    fi
  done
) | pcat
