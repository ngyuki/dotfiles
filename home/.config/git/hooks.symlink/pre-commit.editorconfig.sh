#!/bin/bash

if type editorconfig-checker 1>/dev/null 2>&1; then
  if ! git diff -z --cached --name-only --diff-filter=d --no-renames --ignore-submodules=all | xargs --null --no-run-if-empty editorconfig-checker; then
    exit 1
  fi
fi
