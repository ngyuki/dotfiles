function __fzf_history
  builtin history --null |\
    awk -v RS=\0 '!a[$0]++' |\
    fzf --no-multi --no-sort --read0 --layout=default --tiebreak=index --toggle-sort=ctrl-r --query (commandline) |\
    read -lz result

  if [ -z $result ]
    return
  end

  commandline -rb -- (builtin string trim $result)
  commandline -f repaint
end
