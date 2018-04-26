# https://github.com/fish-shell/fish-shell/issues/450
# https://stackoverflow.com/questions/30813606/how-to-add-entry-to-fish-shell-history

function history_add
  if set -q fish_history
    set __fish_history $fish_history
  else if set -q XDG_DATA_HOME
    set __fish_history $XDG_DATA_HOME/fish/fish_history
  else
    set __fish_history ~/.local/share/fish/fish_history
  end

  echo "- cmd:" $argv >> $__fish_history
  echo "  when:" (date "+%s") >> $__fish_history
  history --merge
end
