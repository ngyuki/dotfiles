#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "git config"

PATH=/usr/bin:/bin:$PATH

(
  cmd=(git config --global include.path "$PWD/.gitconfig")
  echo "${cmd[@]}"
  "${cmd[@]}"

  cmd=(git config --global core.hooksPath "$PWD/git-hooks")
  echo "${cmd[@]}"
  "${cmd[@]}"
) | pcat
