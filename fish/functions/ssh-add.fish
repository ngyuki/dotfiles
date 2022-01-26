
function ssh-add
  if test (count $argv) -ne 0
    command ssh-add $argv
  else
    command ssh-addx
  end
end
