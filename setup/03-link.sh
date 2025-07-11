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
  find -type f | while read -r f; do
    src="$PWD/${f#./}"
    dst="$HOME/${f#./}"
    dir="${dst%/*}"
    mkdir -pv "$dir"
    ln -vsfn "$src"  "$dst"
  done
) | pcat
