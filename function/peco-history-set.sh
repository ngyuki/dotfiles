################################################################################
### peco-history-set

function pehist()
{
    local line=$("$@" | peco)
    if [ -z "$line" ]; then
        return 1
    fi
    history -s "$line"
}
