# https://github.com/junegunn/fzf/wiki/Examples-(fish)
function ... -d 'cd backwards'
  pwd | awk -v RS=/ '/\n/ {exit} {p=p $0 "/"; print p}' | tac | eval (__fzfcmd) +m --select-1 --exit-0 $FZF_BCD_OPTS | read -l result
  if test -n "$result"
    cd "$result"
  end
  commandline -f repaint
end
