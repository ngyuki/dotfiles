################################################################################
### peco

hash peco 1> /dev/null 2>&1 && return

function peco()
{
    if ! type -f peco 1> /dev/null 2>&1 ; then
        echo "install peco ..." 1>&2
        go get github.com/peco/peco/cmd/peco
    fi
    command peco "$@"
}
