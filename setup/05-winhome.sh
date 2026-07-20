#!/bin/bash

source "$(dirname "$0")/functions.sh"

set -eu

args="$(find "$PWD/winhome" -type f -printf " -path %P")"

if [ $# -eq 0 ]; then
  set -- -batch -auto
  pp "winhome"
  unison "$@" -root "$PWD/winhome" -root "$USERPROFILE" $args 2>&1 | pcat
else
  args="$(find "$PWD/winhome" -type f -printf " -path %P")"
  unison "$@" -root "$PWD/winhome" -root "$USERPROFILE" $args
fi
