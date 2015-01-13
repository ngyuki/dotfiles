################################################################################
### peco

if ! hash peco 1> /dev/null 2>&1; then

    function peco()
    {
        if ! type -f peco 1> /dev/null 2>&1 ; then
            {
                echo 'You should be install peco'
                echo '  see https://github.com/peco/peco/releases'
                echo
                echo 'Example'
                echo '  curl -L https://github.com/peco/peco/releases/download/v0.1.12/peco_linux_amd64.tar.gz \'
                echo '    | tar xzf - --directory /tmp/'
                echo '  sudo mv /tmp/peco_linux_amd64/peco /usr/local/bin'
                echo '  rm -fr /tmp/peco_linux_amd64'
            } 1>&2
        else
            command peco "$@"
        fi
    }

fi

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

    bind -x '"\C-x\C-x":peco-history'
fi
