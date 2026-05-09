#!/bin/bash

if type typos 1>/dev/null 2>&1; then
  # if ! git diff -z --cached --name-only --diff-filter=d --no-renames --ignore-submodules=all | xargs --null --no-run-if-empty typos; then
  #   exit 1
  # fi
  if ! git diff --cached --name-only --diff-filter=d --no-renames --ignore-submodules=all | typos --force-exclude --file-list=-; then
    exit 1
  fi
fi
