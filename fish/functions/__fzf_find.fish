function __fzf_find

  set -l word (commandline -t)
  set -l dirs
  set -l files

  for w in (eval string split / $word)
    if [ $w = '' ]
      if [ (count $dirs) -eq 0 ]
        set dirs ''
      end
      if [ (count $files) -eq 0 ]
        continue
      end
    end
    if [ (count $files) -eq 0 -a -d (string join / $dirs $w) ]
      set dirs $dirs $w
    else
      set files $files $w
    end
  end

  if not count $dirs >/dev/null
    set dirs '.'
  end
  set dirs (string join / $dirs '')

  if not count $files >/dev/null
    set files ''
  end

  command find -L $dirs -mindepth 1 -maxdepth 3 -path '*/\.*' -prune -o -printf '%P\0' 2> /dev/null |\
    fzf --read0 --print0 -m --prompt $dirs --query (string join / $files) |\
    while read --null --local select
      set selects $selects (builtin string escape "$dirs/$select")
    end

  if count $selects 1>/dev/null 2>&1
    commandline -rt -- (builtin string join ' ' $selects)
    commandline -f repaint
  end

end
