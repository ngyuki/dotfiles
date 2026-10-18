#!/bin/bash

set -eu

src=$1
dst=$2
shift 2

readarray -d '' paths < <(
  find "$src" -type d -exec test -f "{}/.dotsync" \; -prune -printf '%P\0' -o \( -type f -o -type l \) -printf '%P\0' \
)
args=(
  -root "$src"
  -root "$dst"
  -ignore 'Name .dotsync'
  -backupcurr 'Name *'
  -backuploc central
  #-merge 'Name * -> git merge-file -p CURRENT1 CURRENTARCH CURRENT2 > NEW'
  #-merge 'Name * -> diff3 -m CURRENT1 CURRENTARCH CURRENT2 > NEW'
  -merge 'Name * -> touch NEW && code --wait --merge CURRENT1 CURRENT2 CURRENTARCH NEW'
)
for x in "${paths[@]}"; do
  args+=( -path "$x" )
done

unison "${args[@]}" "$@"
