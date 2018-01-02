################################################################################
### pessh

# ruptime が無いと _known_hosts_real が妙に遅いのでダミー
if ! type -f ruptime 2>/dev/null; then
    ruptime(){
        if type -f ruptime 2>/dev/null; then
            unset -f ruptime
        fi
    }
fi

pessh() {
    # bash_completion の _known_hosts_real を呼ぶ
    _known_hosts_real -a -- ""

    host=$(IFS=$'\n'; echo "${COMPREPLY[*]}" | sort | uniq | __peco)
    COMPREPLY=()

    if [ -z "$host" ]; then
        return 1
    fi

    history -s ssh "$host" "$@"
    ssh "$host" "$@"
}
