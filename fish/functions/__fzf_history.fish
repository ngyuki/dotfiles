function __fzf_history
  builtin history --null |\
    awk -v RS=\0 '!a[$0]++' |\
    fzf +m +s --read0 --tiebreak=index --toggle-sort=ctrl-r --query (commandline) |\
    read -z select
  if not [ -z $select ]
    commandline -rb (builtin string trim "$select")
    commandline -f repaint
  end
end
