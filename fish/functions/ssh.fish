function ssh
  if test (count $argv) -eq 0
    xssh
  else
    # tmux で TERM が tmux-256color にされるとターミナルタイトルが接続先にならなくなるので
    export TERM=xterm-256color
    command ssh $argv
  end
end
