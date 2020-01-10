if hash diff-highlight
  function diff
    if test -t 1
      command diff -u --color=always $argv | diff-highlight
    else
      command diff -u --color=never $argv
    end
  end
else
  function diff
    command diff -u --color=auto $argv
  end
end
