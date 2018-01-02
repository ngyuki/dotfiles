#!/bin/bash

o() {
  local line
  line=$(
    if [ $# -eq 0 ]; then
      find -L . -path '*/\.*' -prune -o -type f -print 2> /dev/null | fzf --reverse +m
    else
      IFS=$'\n'
      echo "$*" | fzf --reverse +m
    fi
  ) && open "$line"
}

d() {
  local dir
  dir=$(
    find -L "${1:-.}" -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf --reverse +m
  ) && cd -- "$dir"
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --reverse -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo "$pid" | xargs kill -${1:-9}
  fi
}
