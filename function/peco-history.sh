################################################################################
### peco-history

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    return
fi

function __peco_history() {
    local line
    line=$(
        HISTTIMEFORMAT= builtin history |
        sed 's/ *[0-9][0-9]* *//' |
        tac |
        awk '!a[$0]++' |
        __peco --query "$READLINE_LINE"
    )

    if [ -z "$line" ]; then
        return 1
    fi

    READLINE_LINE="$line"
    READLINE_POINT=${#READLINE_LINE}
}

if [ -t 1 ]; then
    bind -x '"\C-x\C-x":__peco_history'
fi
