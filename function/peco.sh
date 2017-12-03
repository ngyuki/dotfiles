################################################################################
### peco

function peco()
{
    if type -f peco 1> /dev/null 2>&1; then
        function peco() {
            command peco "$@"
        }
    elif type -f fzf 1> /dev/null 2>&1; then
        function peco() {
            command fzf --reverse "$@"
        }
    else
        function peco() {
            echo 'You should be install peco or fzf' 1>&2
            return 1
        }
    fi
    peco "$@"
}

function pessh()
{
    local input
    local host

    if [ -t 0 ]; then
        input=/etc/hosts
    else
        input=-
    fi

    host=$(
        cat "$input" |
        grep -v -e '^$' -e '^[ \t]*#' |
        sed -e 's/[ \t][ \t]*/\n/g' |
        sort | uniq | peco
    )

    if [ -z "$host" ]; then
        return 1
    fi

    history -s ssh "$host" "$@"
    ssh "$host" "$@"
}

if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then

    function peco-history()
    {
        local line

        line=$(
            HISTTIMEFORMAT= \
            command history |
            sed 's/ *[0-9][0-9]* *//' |
            tac |
            awk '!a[$0]++' |
            peco --query "$READLINE_LINE"
        )

        if [ -z "$line" ]; then
            return 1
        fi

        READLINE_LINE="$line"
        READLINE_POINT=${#READLINE_LINE}
    }

    #if [ -n "$PS1" ]; then
    if [ -t 1 ]; then
        bind -x '"\C-x\C-x":peco-history'
    fi
fi
