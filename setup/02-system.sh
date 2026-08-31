#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "copy system files"

(
  cd -- "$PWD/system"
  find -type f | while read -r f; do
    src="$PWD/${f#./}"
    dst="${f#.}"
    dir="${dst%/*}"
    sudo mkdir -pv -- "$dir"
    sudo rsync -ai --chown=root:root -- "$src" "$dst"
  done
) | pcat
