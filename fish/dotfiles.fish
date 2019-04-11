
#set TERM cygwin

set -l my_function_path (dirname -- (realpath -- (status -f)))/functions
if not contains $my_function_path $fish_function_path
  set fish_function_path $my_function_path $fish_function_path
end

function fish_greeting
end

function fish_prompt
  if [ $status -eq 0 ]
    set color (set_color green)
  else
    set color (set_color red)
  end

  set git_branch (git branch --no-color 2> /dev/null -a | sed -n -e '/^\*/{s/^[* ]*//;p}')
  if [ -z $git_branch ]
    set git_branch ""
  else
    set git_branch (set_color magenta)" ($git_branch)"
  end

  echo
  echo (set_color yellow)(__fish_pwd)$git_branch
  echo "$color\$ "(set_color $fish_color_normal)
end

function fish_right_prompt
end

# direnv
if type direnv >/dev/null 2>&1
  eval (direnv hook fish)
end

# complete
complete -c tmux-cssh -w ssh

# alias
if status --is-interactive
  if hash exa 2>/dev/null
    alias ls='exa --time-style=long-iso'
  end
  if hash bat 2>/dev/null
    alias cat='bat --paging=never'
    alias less='bat --paging=always'
  end
  if hash rg 2>/dev/null
    alias grep='rg'
  end
end
