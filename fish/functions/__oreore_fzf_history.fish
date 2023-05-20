function __oreore_fzf_history
  builtin history merge
  builtin history --null \
  | fzf --no-multi --read0 --tiebreak=index --toggle-sort=ctrl-r --query (commandline) \
  | read --local --null result
  and commandline -- (builtin string trim $result)
  commandline -f repaint
end
