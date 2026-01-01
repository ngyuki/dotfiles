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
    mkdir -pv "$dir"
    dst="${dst%.symlink}"
    ln -vsfnr "$src"  "$dst"
  done
) | pcat
