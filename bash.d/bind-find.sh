################################################################################
### bind-find

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  return
fi

if [ ! -t 1 ]; then
  return
fi

function __bind_command_find() {

  local left=${READLINE_LINE:0:${READLINE_POINT}}
  local right=${READLINE_LINE:${READLINE_POINT}}
  local left=${left##* }
  local right=${right%% *}
  local word=${left}${right}

  local input=$(
    find -L . -path '*/\.*' -prune -o -print 2> /dev/null |
    fzf -m --query "${word:-}"
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

  local left=$(($READLINE_POINT - ${#left}))
  local right=$(($READLINE_POINT + ${#right}))

  READLINE_LINE="${READLINE_LINE:0:$left}${input}${READLINE_LINE:$right}"
  READLINE_POINT=$(($left + ${#input}))
}

bind -r '"\C-f\C-f"'
bind -x '"\C-f\C-f":__bind_command_find'
