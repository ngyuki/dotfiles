function __oreore_fzf_find_file
  set -l commandline (__fzf_parse_commandline)
  set -l dir $commandline[1]
  set -l fzf_query $commandline[2]

  command fd -L . $dir --print0 2> /dev/null \
  | sed -z 's@^\./@@' \
  | fzf --read0 --print0 --multi --prompt "$dir/" --query $fzf_query \
  | while read --null --local result
      set results $results (builtin string escape $result)
    end

  if [ -z $results ]
    commandline -f repaint
    return
  end

  commandline -rt -- (builtin string join ' ' $results)
  commandline -f repaint
end
