function __fzf_find
  set -l commandline (__fzf_parse_commandline)
  set -l dir $commandline[1]
  set -l fzf_query $commandline[2]

  command find -L $dir -mindepth 1 -maxdepth 3 -path '*/\.*' -prune -o -print0 2> /dev/null |\
    sed -z 's@^\./@@' |\
    fzf --read0 --print0 --multi --prompt "$dir/" --query $fzf_query |\
    while read --null --local result
      set results $results (builtin string escape $result)
    end

  if [ -z $results ]
    return
  end

  commandline -rt -- (builtin string join ' ' $results)
  commandline -f repaint
end
