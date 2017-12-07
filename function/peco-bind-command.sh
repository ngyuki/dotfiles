if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    return
fi

function __peco_bind_command_find() {

  local line
  line=$(
    find -L "${1:-.}" -path '*/\.*' -prune -o -print 2> /dev/null | __peco
  )

  if [ -z "$line" ]; then
    return 1
  fi

  local pos=$READLINE_POINT
  local len=${#READLINE_LINE}

  READLINE_LINE="${READLINE_LINE:0:$pos}${line}${READLINE_LINE:$pos:$len}"
  READLINE_POINT=$(($pos + ${#line}))
}

function __peco_bind_command_replace() {
  local cmd

  cmd=$(
    local orig="$(stty -g)"
    trap "stty \"${orig}\"" EXIT
    stty cooked echo
    read -p 'replacing with command: ' -r input
    echo "$input"
  )

  if [ -z "$cmd" ]; then
    return 1
  fi


  local line

  line=$(
    eval "$cmd" | __peco
  )

  if [ -z "$line" ]; then
    return 1
  fi

  local pos=$READLINE_POINT
  local len=${#READLINE_LINE}

  READLINE_LINE="${READLINE_LINE:0:$pos}${line}${READLINE_LINE:$pos:$len}"
  READLINE_POINT=$(($pos + ${#line}))
}

bind -r '"\C-x\C-f"'
bind -x '"\C-x\C-f":__peco_bind_command_find'
