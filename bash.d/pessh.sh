################################################################################
### pessh

pessh() {

  # tmux-cssh があるなら複数選択を可能にする
  local fzf_multi=()
  if type -f tmux-cssh >/dev/null 2>&1; then
    fzf_multi=(-m)
  fi

  # ruptime が無いと _known_hosts_real が妙に遅いのでダミーを作る
  if hash _known_hosts_real 2>/dev/null; then
    if ! type -f ruptime >/dev/null 2>&1; then
      ruptime(){
        if type -f ruptime >/dev/null 2>&1; then
          unset -f ruptime
        fi
      }
    fi
  fi

  # ホストを選択
  local hosts
  hosts=$(
    {
      if hash _known_hosts_real 2>/dev/null; then
        _known_hosts_real -a -- ""
        IFS=$'\n'
        echo "${COMPREPLY[*]}"
      else
        cat /etc/hosts | grep -v -e '^$' -e '^[ \t]*#' | sed -e 's/[ \t][ \t]*/\n/g'
      fi
    } | sort | uniq | fzf "${fzf_multi[@]}"
  )

  # 配列化
  IFS=$'\n' eval 'hosts=($hosts)'

  # 実行
  if [[ "${#hosts[@]}" -eq 1 ]]; then
    history -s ssh "${hosts[@]}" "$@"
    ssh "${hosts[@]}" "$@"
  elif [[ "${#hosts[@]}" -gt 1 ]]; then
    history -s tmux-cssh "${hosts[@]}" "$@"
    tmux-cssh "${hosts[@]}" "$@"
  else
    return 1
  fi
}
