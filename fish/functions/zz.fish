
function zz
  z -l -t | awk '{ print $2 }' | string escape |
    fzf +s --preview 'ls -al --color=always {}' |
    read --local select
  if [ $select ]
    cd $select
  end
end
