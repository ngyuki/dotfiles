function ssh
  if test (count $argv) -eq 0
    xssh
  else
    # tmux で TERM が tmux-256color にされるとターミナルタイトルが接続先にならなくなるので
    export TERM=xterm-256color
    # ProxyCommand を /bin/sh で実行するため
    export SHELL=/bin/sh
    command ssh $argv
  end
end
