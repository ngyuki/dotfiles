#!/bin/bash

source "$(dirname "$0")/functions.sh"

set -eu

pp "winhome"
unison -batch -auto "$USERPROFILE/dotfiles/winhome/" "$PWD/winhome/" 2>&1 | pcat
