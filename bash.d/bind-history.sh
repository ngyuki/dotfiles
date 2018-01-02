################################################################################
### bind-history

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
  return
fi

if [ ! -t 1 ]; then
  return
fi

function __bind_history() {

  local input=$(
    HISTTIMEFORMAT= builtin history |
    sed 's/ *[0-9][0-9]* *//' |
    awk '!a[$0]++' |
    fzf +m --tac --tiebreak=begin --height=40% --query "$READLINE_LINE"
  )

  if [ -z "$input" ]; then
    return 1
  fi

  READLINE_LINE="$input"
  READLINE_POINT=${#READLINE_LINE}
}

bind -r '"\C-r"'
bind -x '"\C-r":__bind_history'
