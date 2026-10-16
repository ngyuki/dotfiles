#!/bin/bash

json="$(cat -)"
jq -c <<<"$json" >> "/tmp/gemini-hook-notification-$(date +%Y%m%d).log"
env | grep GEMINI_ >> "/tmp/gemini-hook-notification-$(date +%Y%m%d).env"

notification_type="$(jq -r .notification_type <<<"$json")"
message="$(jq -r .message <<<"$json")"
command="$(jq -r .details?.command <<<"$json")"
project=${GEMINI_PROJECT_DIR##*/}
toast -a "Gemini CLI" -t "$project" "$message

$command"

echo '{}'
