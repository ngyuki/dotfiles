#!/bin/bash

set -e
cd "$(dirname "$0")/setup"

bash --norc --noprofile link.sh
bash --norc --noprofile fix.sh
