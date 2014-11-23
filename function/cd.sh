################################################################################
### cd

[ -n "$WINDIR" ] && {

    # follow windows shortcut
    function cd()
    {
        local link=
        local arg

        for arg in "$@"; do

            if [ "${arg#-}" != "${arg}" ]; then
                continue
            fi

            if [ -d "$arg" ]; then
                break
            fi

            if [ -f "$arg.lnk" ]; then
                link="$arg.lnk"
                break
            fi

            if [ "${arg%.lnk}.lnk" == "${arg}" ]; then
                if [ -f "$arg" ]; then
                    link="$arg"
                    break
                fi
            fi

            break
        done

        if [ -n "$link" ]; then
            local base=$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)")

            if [ ! -f "$base/lib/getlink.js" ]; then
                echo "script notfound ... lib/getlink.js"
                return 1
            fi

            local dir=$(cscript //nologo "$base/lib/getlink.js" "$link")

            if [ -n "$dir" ]; then
                __ng_cd_save "$dir"
                return "$?"
            fi
        fi

        __ng_cd_save "$@"
    }

} || {

    function cd()
    {
        __ng_cd_save "$@"
    }
}

function __ng_cd_save()
{
    local oldoldpwd=$OLDPWD

    builtin cd "$@"
    local rc=$?

    [ $rc -ne 0 ] && return $rc

    case "$PWD" in
        "$oldoldpwd"|"$OLDPWD"|"$HOME"|"/")
            return $rc
    esac

    echo "$PWD" >> "$HOME/.bash_dirs"

    return $rc
}

function __ng_cd_fix()
{
    cat "$HOME/.bash_dirs" | uniq | tail -100 > "$HOME/.bash_dirs~"
    mv -f "$HOME/.bash_dirs~" "$HOME/.bash_dirs"
}

function pecd()
{
    local input
    local dir

    if [ -t 0 ]; then
        input="$HOME/.bash_dirs"
        __ng_cd_fix
    else
        input=-
    fi

    dir=$(cat "$input" | sort -u | peco)

    if [ -z "$dir" ]; then
        return 1
    fi

    history -s cd "$dir"
    builtin cd "$dir"
}
