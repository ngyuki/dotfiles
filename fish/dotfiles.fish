
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

  set prompt \n(set_color yellow)(__fish_pwd)

  set git_branch (git branch --no-color 2> /dev/null -a | sed -n -e '/^\*/{s/^[* ]*//;p}')
  if [ $git_branch ]
    set prompt "$prompt $(set_color magenta)($git_branch)"
  end

  set append
  if [ $AWS_VAULT ]
    set append $append AWS_VAULT=$AWS_VAULT
  end
  if [ $TF_WORKSPACE ]
    set append $append TF_WORKSPACE=$TF_WORKSPACE
  end
  if [ $ANSIBLE_INVENTORY ]
    set append $append ANSIBLE_INVENTORY=$ANSIBLE_INVENTORY
  end
  if [ (count $append) -ne 0 ]
    set prompt "$prompt $(set_color green)($append)"
  end

  set prompt $prompt$status_prompt\n$status_color"\$ "(set_color $fish_color_normal)

  echo $prompt
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
    #alias ls='exa --color=auto --time-style=long-iso' # オプションが違いすぎてわかりにくい
    alias ls='ls --color=auto'
    alias la='ls -a'
    alias ll='ls -alF'
  end
  if type -fq bat
    #alias cat='bat --paging=never' # でかいファイルでおもすぎるので無効
    #alias less='bat --paging=always' # オプションが違いすぎてわかりにくい
  end
  # if type -fq rg
  #   alias grep='rg' # 明示的に呼べばよいと思う
  # end
end
