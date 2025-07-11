#!/bin/bash

input="$(cat -)"
title="$(jq -r .message <<<"$input")"
transcript_path="$(jq -r .transcript_path <<<"$input")"

message="$(
  cat "$transcript_path" \
  | jq -sr '.[-1].message.content[].input|[.command,.description]|join("\n")'
)"

jq -nc \
  --arg app "Claude Code" \
  --arg title "$title" \
  --arg message "$message" \
  '{app:$app,title:$title,message:$message}' \
| nc -U "$XDG_RUNTIME_DIR/wsl-toast.sock"
