function tmux_ai_complete
  set -l script (path resolve (path dirname (status current-filename))/tmux-ai-complete.ts)
  set -l generated (command node --no-warnings --experimental-strip-types $script (commandline))
  if test $status -eq 0; and test -n "$generated"
    commandline --replace -- $generated
  end
end
