function __oreore_tmux_new
  commandline --search-mode; and return
  commandline --paging-mode; and return
  commandline --is-valid; or return

  tmux \
    new-window -c "#{pane_current_path}" (commandline) \;\
    set -w remain-on-exit on \;\
    set -w pane-border-status top \;\
    set -w pane-border-format " #{pane_start_command} "
end
