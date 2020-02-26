if hash diff-highlight
  function diff
    if test -t 1
      command diff --color=always $argv | diff-highlight
    else
      command diff --color=never $argv
    end
  end
else
  function diff
    command diff --color=auto $argv
  end
end
