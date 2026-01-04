
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
    #alias ls='ls --color=auto' # fish 組み込みで十分
    #alias la='ls -a'
    #alias ll='ls -alF'
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

# wtp
if type wtp >/dev/null 2>&1
  wtp shell-init fish | source

  function wtp
    for arg in $argv
      if test "$arg" = "--generate-shell-completion"
        command wtp $argv
        return $status
      end
    end
    if test "$argv[1]" = "cd"
      set -l target_dir
      if test -z "$argv[2]"
        set target_dir (command wtp cd 2>/dev/null)
      else
        set target_dir (command wtp cd $argv[2] 2>/dev/null)
      end
      if test $status -eq 0 -a -n "$target_dir"
        cd "$target_dir"
      else
        if test -z "$argv[2]"
          command wtp cd
        else
          command wtp cd $argv[2]
        end
      end
    else
      command wtp $argv
    end
  end

end
