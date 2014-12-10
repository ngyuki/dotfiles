#!/bin/bash

set -eu
cd "$(dirname "$0")"

for fn in setup/[0-9]*.sh; do
    "$fn"
done
