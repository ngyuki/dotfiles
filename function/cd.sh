################################################################################
### cd

if [ -n "${WINDIR-}" ]; then

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
                __pecd_add "$dir"
                return "$?"
            fi
        fi

        __pecd_add "$@"
    }

else

    function cd()
    {
        __pecd_add "$@"
    }

fi

function __pecd_add()
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

function __pecd_fix()
{
    if [ -f "$HOME/.bash_dirs" ]; then
        cat "$HOME/.bash_dirs" | tac | awk '!a[$0]++' | tac | tail -100 > "$HOME/.bash_dirs~"
        mv -f "$HOME/.bash_dirs~" "$HOME/.bash_dirs"
    fi
}

function pecd()
{
    local input
    local dir

    if [ -t 0 ]; then
        input="$HOME/.bash_dirs"
        __pecd_fix
    else
        input=-
    fi

    dir=$(cat "$input" | tac | awk '!a[$0]++' | peco)

    if [ -z "$dir" ]; then
        return 1
    fi

    history -s cd $(printf "%q" "$dir")
    __pecd_add "$dir"
}

function pecd-clean()
{
    if [ ! -f "$HOME/.bash_dirs" ]; then
        return
    fi

    cat "$HOME/.bash_dirs" | (
        while read x; do
            if [ -d "$x" ]; then
                echo "$x"
            fi
        done
    ) | tac | awk '!a[$0]++' | tac | tail -100 > "$HOME/.bash_dirs~"

    mv -f "$HOME/.bash_dirs~" "$HOME/.bash_dirs"
}
