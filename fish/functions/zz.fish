function zz
  set -l result (
    command zoxide query --list -- $argv |
    FZF_DEFAULT_OPTS=$_ZO_FZF_OPTS command fzf --expect=enter,alt-enter --preview 'ls -alF --color=always {}'
  )
  set -l rc $status
  test $status -eq 0; or return $status
  test (count $result) -ge 2; or return 1

  set -l key $result[1]
  set -l dir $result[2]

  # tmux のキーバインドからの呼び出しでは常に新しいセッション
  if set -q _ZZ_TMUX_BIND_KEY
    set key alt-enter
  end

  switch $key
    case enter
      __zoxide_cd -- "$dir"
    case alt-enter
      # `.` や `:` はメタ文字になるためアンダースコアに置換
      set -l session (string replace -ra '[.:]' '_' (path basename "$dir"))

      # new-session -A だとセッションが存在するときにポップアップ内でセッションにアタッチしてしまう
      # なので has-session でセッションの存在を確認して処理を振り分ける
      if not command tmux has-session -t "$session" 2>/dev/null
        command tmux new-session -d -s "$session" -c "$dir" \; switch-client -t "$session"
      else
        command tmux switch-client -t "$session"
      end
  end
end
