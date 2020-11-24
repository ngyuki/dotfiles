
# 謎のゴミが表示される問題 ... TERM を変更すると tig がまともに動かない・・
# https://github.com/fish-shell/fish-shell/issues/789#issuecomment-207898381
# set TERM cygwin

set -l my_function_path (dirname -- (realpath -- (status -f)))/functions
if not contains $my_function_path $fish_function_path
  set fish_function_path $my_function_path $fish_function_path
end

# `Welcome to fish, the friendly interactive shell` みたいなメッセージを表示しない
function fish_greeting
end

set distribution_prompt " "(set_color cyan)"["(sh -c '. /etc/os-release; echo $NAME')"]"

function fish_prompt
  # 一定以上の時間を要したら自動で通知する
  # if test $CMD_DURATION
  #   if test $CMD_DURATION -gt (math "1000 * 30")
  #     set secs (math "$CMD_DURATION / 1000")
  #     echo "returned $status, $secs seconds" | toast "$history[1]" 1> /dev/null 2>&1
  #     set CMD_DURATION 0
  #   end
  # end

  set status_save $status

  if [ $status_save -ne 0 ]
    set status_prompt " "(set_color red)"[status=$status_save]"
    set status_color (set_color red)
  else
    set status_prompt ""
    set status_color (set_color green)
  end

  set git_branch (git branch --no-color 2> /dev/null -a | sed -n -e '/^\*/{s/^[* ]*//;p}')
  if [ -z $git_branch ]
    set git_branch ""
  else
    set git_branch (set_color magenta)" ($git_branch)"
  end

  echo
  echo (set_color yellow)(__fish_pwd)$git_branch$distribution_prompt$status_prompt
  echo $status_color"\$ "(set_color $fish_color_normal)
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
  if type -fq exa
    export EXA_COLORS="reset"
    alias ls='exa --color=auto --time-style=long-iso'
    alias la='ls -a'
    alias ll='ls -alF'
  end
  if type -fq bat
    #alias cat='bat --paging=never' # でかいファイルでおもすぎるので無効
    alias less='bat --paging=always'
  end
  if type -fq rg
    alias grep='rg'
  end
  if type -fq docker-wrapper
    alias docker='docker-wrapper'
  end
  if type -fq docker-compose-ssh
    alias docker-compose='docker-compose-ssh'
  end
end
