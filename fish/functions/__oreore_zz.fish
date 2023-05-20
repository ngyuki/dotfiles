
function __oreore_zz
  z -l -t | awk '{ print $2 }' | string escape |
    fzf --scheme=path --keep-right --no-sort --preview 'ls -alF --color=always {}' |
    read --local select
  if [ $select ]
    cd $select
  end
end
