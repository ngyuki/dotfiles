#!/bin/bash

set -e
cd "$(dirname "$0")/.."

###

function pp
{
	echo -ne "\e[1;31m"
	echo -n "${*}"
	echo -e "\e[m"
}

function pcat
{
	echo -ne "\e[0;34m"
	cat "$@" | sed -e 's/^/  /'
	echo -e "\e[m"
}

###

pp "create symbolic links"

files=(
	".inputrc .inputrc"
	".gitignore .gitignore"
)

gitcheck=$(
	{
		git version | cut -f3 -d" "
		echo 1.8.0
	} | sort -t . -n -k 1,1 -k 2,2 -k 3,3 | head -1
)

if [ "$gitcheck" == "1.8.0" ]; then
	files+=(".gitconfig .gitconfig")
else
	files+=(".gitconfig .gitconfig-17")
fi

for fn in "${files[@]}"; do
	fn=($fn)
	src="$PWD/${fn[1]}"
	dst="$HOME/${fn[0]}"
	ln -vsf "$src" "$dst"
done | pcat
