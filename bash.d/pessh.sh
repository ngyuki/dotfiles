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
  local host

  if hash _known_hosts_real 2>/dev/null; then
    host=$(
      # bash_completion の _known_hosts_real を呼ぶ
      _known_hosts_real -a -- ""
      IFS=$'\n'; echo "${COMPREPLY[*]}" | sort | uniq | fzf
    )
  else
    host=$(
      cat "/etc/hosts" |
        grep -v -e '^$' -e '^[ \t]*#' |
        sed -e 's/[ \t][ \t]*/\n/g' |
        sort | uniq | fzf
    )
  fi

  if [ -z "$host" ]; then
    return 1
  fi

  history -s ssh "$host" "$@"
  ssh "$host" "$@"
}
