################################################################################
### pecd

__pecd_pwd=()

function __pecd_prompt_command() {
    if [[ "${__pecd_pwd[0]}" == "$PWD" ]]; then
        return
    fi
    if [[ "${__pecd_pwd[1]}" == "$PWD" ]]; then
        return
    fi
    __pecd_pwd=( "$PWD" "${__pecd_pwd[0]}" )
    echo "$PWD" >> "$HOME/.bash_dirs"
}
if [[ ";$PROMPT_COMMAND;" != *";__pecd_prompt_command;"* ]]; then
    PROMPT_COMMAND="__pecd_prompt_command;$PROMPT_COMMAND";
fi

function pecd() {
    local input="$HOME/.bash_dirs"

    if [ -t 0 ]; then
        if [ -f "$input" ]; then
            cat "$input" | tac | awk '!a[$0]++' | tac | tail -100 > "$input~"
            \cp -f "$input~" "$input"
            \rm -f "$input~"
        fi
    else
        input=-
    fi

    local dir=$(cat "$input" | fzf --tac)
    if [ -z "$dir" ]; then
        return 1
    fi

    history -s cd $(printf "%q" "$dir")
    builtin cd "$dir"
}

function pecd-clean() {
    local input="$HOME/.bash_dirs"

    if [ ! -f "$input" ]; then
        return
    fi

    cat "$input" | (
        while read -r x; do
            if [ -d "$x" ]; then
                echo "$x"
            fi
        done
    ) | tac | awk '!a[$0]++' | tac | tail -100 > "$input~"

    \cp -f "$input~" "$input"
    \rm -f "$input~"
}
