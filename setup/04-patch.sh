#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "patch files"

move_with_trash() {
  local src=$1
  local dst=$2
  if type gtrash > /dev/null; then
    gtrash put "$dst"
  else
    rm -f "$dst"
  fi
  mv -Tf "$src" "$dst"
}

(
  cd -- "$PWD/patch"

  find -type f \
  | while read -r f; do
    f=${f#./}
    case "$f" in
      *.jsonnet)
        src=$f
        dst=$HOME/${f%.jsonnet}
        echo "patting ${src} -> ${dst}"
        jsonnet "$src" --ext-code-file "base=$dst" > "$dst.tmp" && move_with_trash "$dst.tmp" "$dst"
        ;;
      *)
        echo "unknown file type: $f" >&2
        ;;
    esac
  done
) | pcat
