################################################################################
### bind-find

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  return
fi

if [ ! -t 1 ]; then
  return
fi

function __bind_command_find() {

  local input=$(
    find -L "${1:-.}" -path '*/\.*' -prune -o -print 2> /dev/null |
    fzf -m
  )

  if [ -z "$input" ]; then
    return 1
  fi

  local arr=()
  local line
  IFS=$'\n' eval '
  for line in $input; do
    if [ -n "$line" ]; then
      arr+=($(printf "%q" "$line"))
    fi
  done'

  local input="${arr[@]}"

  local pos=$READLINE_POINT
  local len=${#READLINE_LINE}

  READLINE_LINE="${READLINE_LINE:0:$pos}${input}${READLINE_LINE:$pos:$len}"
  READLINE_POINT=$(($pos + ${#input}))
}

bind -r '"\C-f\C-f"'
bind -x '"\C-f\C-f":__bind_command_find'
