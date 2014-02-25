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
	.gitignore
	.gitconfig
	.inputrc
)

for fn in "${files[@]}"; do

	src="$PWD/$fn"
	dst="$HOME/$fn"
	ln -vsf "$src" "$dst"

done | pcat
