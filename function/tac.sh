################################################################################
### compatible tac

hash tac 1> /dev/null 2>&1 && return

function tac(){
    sed -e '1!G;h;$!d' "$@"
}
