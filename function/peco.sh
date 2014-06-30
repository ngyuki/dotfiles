################################################################################
### peco

if ! hash peco 1> /dev/null 2>&1; then

    function peco()
    {
        if ! type -f peco 1> /dev/null 2>&1 ; then
            {
                echo "You should be install peco"
                echo "  see https://github.com/peco/peco/releases"
                echo "  Or..."
                echo "  go get github.com/peco/peco/cmd/peco"
            } 1>&2
        else
            command peco "$@"
        fi
    }

fi

function peco-ssh()
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

    ssh "$host" "$@"
}
