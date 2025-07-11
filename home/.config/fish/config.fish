
# https://fishshell.com/docs/3.4/language.html#featureflags
set -U fish_features all

# 謎のゴミが表示される問題 ... TERM を変更すると tig がまともに動かない・・
# https://github.com/fish-shell/fish-shell/issues/789#issuecomment-207898381
# set TERM cygwin

set -l my_function_path (realpath -- (dirname -- (realpath -- (status -f)))/../../../fish/functions)
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
    set git_stash (git stash list | wc -l)
    if [ $git_stash -gt 0 ]
        set prompt "$prompt $(set_color magenta)($git_branch $(set_color red)stash#$git_stash$(set_color magenta))"
    else
        set prompt "$prompt $(set_color magenta)($git_branch)"
    end
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

# ターミナルのタイトル
# https://fishshell.com/docs/current/cmds/fish_title.html
function fish_title
  if set -q argv[1]
    string split -f 1 " " $argv[1]
  else
    set abs (__fish_pwd)
    set rel (string replace -ra '^.*/' './' $abs)
    if [ (string length -- $rel) -lt (string length -- $abs) ]
      echo $rel
    else
      echo $abs
    end
  end
end

# mise
if type mise >/dev/null 2>&1
  mise activate fish | source
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

# zoxide
if type zoxide >/dev/null 2>&1
  export _ZO_FZF_OPTS="--ansi --color=16 --info=inline --scheme=path --keep-right --no-sort --preview 'ls -alF --color=always {2..}'"
  zoxide init fish | source
  alias zz=zi
end

# gpg
if status --is-interactive
    set -gx GPG_TTY (tty)
end

# aws complete ... https://dev.classmethod.jp/articles/fish-shell-aws-cli-complete/
complete -c aws -f -a '(
    begin
        set -lx COMP_SHELL fish
        set -lx COMP_LINE (commandline)
        aws_completer
    end
)'

# pass otp
complete -c pass -f -n '__fish_pass_needs_command' -a otp
complete -c pass -f -n '__fish_pass_uses_command otp' -a "(__fish_pass_print_entries)"

# jethrokuan/fzf
set -g FZF_COMPLETE 2
set -g FZF_COMPLETE_OPTS "--height=40% --bind=esc:print-query --no-reverse --select-1"
set -g FZF_FIND_FILE_COMMAND "command fd -L . \$dir 2>/dev/null"
set -g FZF_TMUX 1
set -g FZF_TMUX_HEIGHT "80% -p 95%,80% -y 50%"

if status --is-interactive
    # tmux の pane_path にカレントディレクトリを反映させる
    function __oreore_pwd_hook --on-variable PWD
        printf \e]7\;%s\e\\ $PWD
    end
    __oreore_pwd_hook
end

# 失敗したコマンドを履歴に残さないやつ
# プロンプト表示時や exit 時にものすごいもっさりするので削除
# fisher remove meaningful-ooo/sponge

# プロンプト表示を非表示にするやつ
# /tmp にファイルがまき散らされるので削除
# fisher remove acomagu/fish-async-prompt

# starship
starship init fish | source

# ecs-exec
ecs-exec --fish-complete | source
