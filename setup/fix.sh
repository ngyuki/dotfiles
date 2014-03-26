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
	echo -ne "\e[0;36m"
	cat "$@" | sed -e 's/^/  /'
	echo -e "\e[m"
}

###

for fn in .bashrc .bash_profile; do

	src="$PWD/$fn"
	dst="$HOME/$fn"

	if [ -s "$dst" ] && grep -F "$src" "$dst" >/dev/null; then
		pp "no fix $dst"
	else
		if [ ! -s "$dst" ]; then
			echo >> "$dst"
		fi

		echo "source \"$src\"" >> "$dst"

		pp "fix $dst"
	fi

	pcat "$dst"

done

touch "$HOME/.gitconfig.local"
