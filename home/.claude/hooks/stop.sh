#!/bin/bash

stop_hook_active="$(jq -r .stop_hook_active)"
if [[ "$stop_hook_active" != "false" ]]; then
  exit 0
fi

echo "/wsl-toast" >&2
exit 2

###

input="$(cat -)"
transcript_path="$(jq -r .transcript_path <<<"$input")"
stop_hook_active="$(jq -r .stop_hook_active <<<"$input")"

message="$(
  cat "$transcript_path" \
  | jq -sr 'map(select(.message.role=="assistant"))[-1].message.content[0].text|split("\n")[0]'
)"

jq -nc \
  --arg app "Claude Code" \
  --arg title "Stop" \
  --arg message "$message" \
  '{app:$app,title:$title,message:$message}' \
| nc -U "$XDG_RUNTIME_DIR/wsl-toast.sock"
