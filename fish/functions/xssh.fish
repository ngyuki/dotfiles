function xssh
  set -l fzf_opts
  if command -q xpanes
    set fzf_opts "-m"
  end

  set -l hosts (
    __fish_print_hostnames \
    | grep -v -E '^[0-9\.]+$' \
    | grep -v -E '^i-' \
    | sort -ru \
    | fzf $fzf_opts
  )

  set -l cnt (count $hosts)
  if test $cnt -eq 0
    return 1
  else if test $cnt -eq 1
    set cmd ssh $hosts $argv
  else
    set cmd xpanes --ssh $hosts $argv
  end

  history append -- (string join ' ' -- (string escape -- $cmd))
  $cmd
end
