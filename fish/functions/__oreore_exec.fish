function __oreore_exec

    commandline --search-mode; and return
    commandline --paging-mode; and return

    echo
    eval (commandline)
    echo
    echo
    commandline -f repaint
end
