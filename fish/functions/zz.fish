
function zz
  cat $Z_DATA | sort -t \| -k 3nr | cut -d\| -f1 | string escape | fzf +s --preview 'ls -al --color=always {}' | read --local select
  if [ $select ]
    cd $select
  end
end
