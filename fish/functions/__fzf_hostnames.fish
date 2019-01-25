function __fzf_hostnames

  __fish_print_hostnames | sort | uniq | fzf --multi --no-sort --query (commandline -t) |\
    while read --local result
      set results $results $result
    end

  if [ -z $results ]
    return
  end

  commandline -rt -- (builtin string join ' ' $results)
  commandline -f repaint
end
