function __fzf_hostnames

  set selects (__fish_print_hostnames | fzf -m --query (commandline -t))
  if count $selects >/dev/null
    commandline -rt -- (string join ' ' $selects)
    commandline -f repaint
  end

end
