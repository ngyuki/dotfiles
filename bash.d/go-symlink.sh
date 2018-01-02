
function go-symlink(){
  local base="$GOPATH/src/github.com/ngyuki"
  if [ ! -d "$base" ]; then
    mkdir -p -- "$base"
  fi
  local dst="$base/${PWD##*/}"
  if [ -e "$dst" ]; then
    if [ ! -L "$dst" ]; then
      echo "$dst is not synlink" 1>&2
      return 1
    else
      unlink -- "$dst"
    fi
  fi
  ln -s "${PWD}" "$dst"
  echo "symlink ${PWD} -> $dst"
}
