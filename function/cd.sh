################################################################################
### cd follow windows shortcut

[ -z "$WINDIR" ] && return

function cd
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
            builtin cd "$dir"
            return $?
        fi
    fi

    builtin cd "$@"
    return $?
}
