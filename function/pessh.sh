################################################################################
### pessh

function pessh() {
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
        sort | uniq | __peco
    )

    if [ -z "$host" ]; then
        return 1
    fi

    history -s ssh "$host" "$@"
    ssh "$host" "$@"
}
