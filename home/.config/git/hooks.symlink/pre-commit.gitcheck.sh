#!/bin/bash

if ! git diff --check --cached >/dev/null; then
  printf "\e[1;31m%s\e[m\n" "git diff --check --cached"
  printf "\e[0;31m"
  git diff --check --cached | sed 's/^/  /'
  printf "\e[m"
  exit 1
fi
