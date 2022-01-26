function pessh

  set fzf_multi
  if type -f tmux-cssh >/dev/null 2>&1
    set fzf_multi "-m"
  end

  set hosts (__fish_print_hostnames | fzf $fzf_multi)

  if test (count $hosts) -eq 1
    history_add ssh $hosts $argv
    ssh $hosts $argv
  else if test (count $hosts) -gt 1
    history_add tmux-cssh --new-session $hosts $argv
    tmux-cssh --new-session $hosts $argv
  end
end
