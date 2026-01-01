#!/bin/bash

source "$(dirname "$0")/functions.sh"

set -eu

pp "win-activate-process"
make -C packages/go-win-activate-process install | pcat
