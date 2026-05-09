#!/bin/bash

json="$(cat -)"

notification_type="$(jq -r .notification_type <<<"$json")"
message="$(jq -r .message <<<"$json")"

~/.claude/wsl-toast.sh "Gemini CLI" "$notification_type" "$message"

echo '{}'
