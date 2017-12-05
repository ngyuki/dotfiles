################################################################################
### peco

function __peco()
{
    if type -f fzf 1> /dev/null 2>&1; then
        function __peco() {
            command fzf --reverse "$@"
        }
    elif type -f peco 1> /dev/null 2>&1; then
        function __peco() {
            command peco "$@"
        }
    else
        function __peco() {
            echo 'You should be install peco or fzf' 1>&2
            return 1
        }
    fi
    __peco "$@"
}

