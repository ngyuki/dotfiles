function history-fzf-delete
  history merge

  history --null | fzf --read0 --print0 --multi --exact | while read -lz item
    history delete --exact --case-sensitive -- "$item"
  end

  history save
end
