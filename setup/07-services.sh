#!/bin/bash

source "$(dirname "$0")/functions.sh"
pp "systemd services"

arr=(
  "systemctl --user enable --now systemd-tmpfiles-clean.timer"
  "systemctl --user enable --now ssh-agent.socket"
  "sudo systemd-tmpfiles --create"
)
for cmd in "${arr[@]}"; do
  printf "%s\n" "$cmd"
  eval "$cmd"
done | pcat
