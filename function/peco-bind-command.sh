if [ "${BASH_VERSINFO[0]}" -ge 4 -a -t 1 ]; then

  function __peco_bind_command_replace()
  {
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
      eval "$cmd" | peco
    )

    if [ -z "$line" ]; then
      return 1
    fi

    local pos=$READLINE_POINT
    local len=${#READLINE_LINE}

    READLINE_LINE="${READLINE_LINE:0:$pos}${line}${READLINE_LINE:$pos:$len}"
    READLINE_POINT=$(($pos + ${#line}))
  }

  bind -r '"\C-x\C-v"'
  bind -x '"\C-x\C-v":__peco_bind_command_replace'
fi
