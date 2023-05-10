function ssh
  if test (count $argv) -eq 0
    xssh
  else
    command ssh $argv
  end
end
