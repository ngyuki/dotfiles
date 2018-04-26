
function pecd
  cat $Z_DATA | sort -t \| -k 3nr | cut -d\| -f1 | string escape | fzf +s | read --local select
  if [ $select ]
    cd $select
  end
end
