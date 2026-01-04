#!/bin/bash

source "$(dirname "$0")/functions.sh"
pp "systemd services"

arr=(
  "systemctl --user enable systemd-tmpfiles-clean.timer"
)
for cmd in "${arr[@]}"; do
  printf "%s\n" "$cmd"
  eval "$cmd"
done | pcat
