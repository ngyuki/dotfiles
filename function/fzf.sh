#!/bin/bash

fcd() {
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

o() {
  local line
  line=$(
    find -L "${1:-.}" -path '*/\.*' -prune -o -type f -print 2> /dev/null | fzf --reverse +m
  ) && open "$line"
}
