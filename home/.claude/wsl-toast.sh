#!/bin/bash

if [ ! -S "$XDG_RUNTIME_DIR/wsl-toast.sock" ]; then
  echo "Error: WSL Toast socket not found at $XDG_RUNTIME_DIR/wsl-toast.sock"
  exit 1
fi

jq -n --arg app "$1" --arg title "$2" --arg message "$3" '{app:$app,title:$title,message:$message}' -c \
| nc -U "$XDG_RUNTIME_DIR/wsl-toast.sock"
