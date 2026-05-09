#!/bin/bash

source "$(dirname "$0")/functions.sh"

set -eu

pp "winhome"
args="$(find "$PWD/winhome" -type f -printf " -path %P")"
unison -batch -auto -root "$USERPROFILE" -root "$PWD/winhome" $args 2>&1 | pcat
