# https://github.com/junegunn/fzf/wiki/Examples-(fish)
function ... -d 'cd backwards'
  set -l arr (string split / $PWD)
  for i in (seq (count $arr) -1 2)
      string join / $arr[1..$i] ""
  end | eval (__fzfcmd) +m --select-1 --exit-0 $FZF_BCD_OPTS | read -l result
  if test -n "$result"
    cd "$result"
  end
  commandline -f repaint
end
