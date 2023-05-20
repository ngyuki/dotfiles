##
# Use fzf as fish completion widget.
#
#
# When FZF_COMPLETE variable is set, fzf is used as completion
# widget for the fish shell by binding the TAB key.
#
# FZF_COMPLETE can have some special numeric values:
#
#   `set FZF_COMPLETE 0` basic widget accepts with TAB key
#   `set FZF_COMPLETE 1` extends 0 with candidate preview window
#   `set FZF_COMPLETE 2` same as 1 but TAB walks on candidates
#   `set FZF_COMPLETE 3` multi TAB selection, RETURN accepts selected ones.
#
# Any other value of FZF_COMPLETE is given directly as options to fzf.
#
# If you prefer to set more advanced options, take a look at the
# `__fzf_complete_opts` function and override that in your environment.


# modified from https://github.com/junegunn/fzf/wiki/Examples-(fish)#completion
function __oreore_fzf_complete -d 'fzf completion and print selection back to commandline'

    commandline --search-mode; and return
    commandline --paging-mode; and return

    # As of 2.6, fish's "complete" function does not understand
    # subcommands. Instead, we use the same hack as __fish_complete_subcommand and
    # extract the subcommand manually.
    set -l cmd (commandline -co) (commandline -ct)

    switch $cmd[1]
        case env sudo
            for i in (seq 2 (count $cmd))
                switch $cmd[$i]
                    case '-*'
                    case '*=*'
                    case '*'
                        set cmd $cmd[$i..-1]
                        break
                end
            end
    end

    set -l query $cmd[-1]
    set cmd (string join -- ' ' $cmd)

    set -l complist (complete -C$cmd | cut -f1 -d\t | sort -u)
    set -l result

    # do nothing if there is nothing to select from
    test -z "$complist"; and return

    if test (count $complist) -eq 1
        # if there is only one option dont open fzf
        set result "$complist"
    else
        # 一致部分を取得
        set -l query ""
        for cmd in $complist
            if [ -z "$query" ]
                set query $cmd
            else
                set -l i 1
                set -l len (string length -- "$query")
                while [ $i -le $len ]
                    if [ (string sub -l "$i" -- "$query") != (string sub -l "$i" -- "$cmd") ]
                        set query (string sub -l (math $i - 1) -- "$query")
                        break
                    end
                    set i (math $i + 1)
                end
            end
            if [ -z "$query" ]
                break
            end
        end

        set -l opts --cycle --reverse --inline-info --height=40% --multi --print-query
        set -l bind --bind tab:down,btab:up,ctrl-space:toggle-out,esc:print-query
        string join -- \n $complist \
        | fzf --query="$query" $opts $bind \
        | while read -l r
            set result $result $r
          end

        # exit if user canceled
        if test -z "$result"
            commandline -f repaint
            commandline -t -- $query
            return
        end

        if test (count $result) -eq 1
            commandline -f repaint
            commandline -t -- $result
            return
        end

        set result $result[2..-1]
    end

    set -l completion
    for r in $result
        if test (string sub -l 1 -- $r) = '~'
            set completion $completion (string sub -s 2 (string escape -n -- $r))
        else
            set completion $completion (string escape -- $r)
        end
    end

    if eval "[ ! -d $result[-1] ]"
        set completion $completion ''
    end

    commandline -f repaint
    commandline -t -- (string join -- ' ' $completion)
end
