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
  cd -- "$PWD/home/link"
  find -type f | while read -r f; do
    ln -vsfn "$PWD/$f"     "$HOME/$f"
  done
) | pcat
