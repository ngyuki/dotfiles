function xssh
  set fzf_opts
  if type -f xpanes >/dev/null 2>&1
    set fzf_opts "-m"
  end

  set hosts (__fish_print_hostnames | fzf $fzf_opts)

  if test (count $hosts) -eq 1
    set cmd ssh $hosts $argv
  else if test (count $hosts) -gt 1
    set cmd xpanes --ssh $hosts $argv
  end

  history_add $cmd
  $cmd
end
