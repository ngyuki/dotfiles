#!/bin/bash

source "$(dirname "$0")/functions.sh"

for fn in .bashrc .bash_profile .bash_logout; do

	src="$PWD/$fn"
	dst="$HOME/$fn"

	pp "$fn"

	if [ -s "$dst" ] && grep -F "$src" "$dst" >/dev/null; then
		echo "no fix" | pcat
	else
		if [ ! -s "$dst" ]; then
			echo >> "$dst"
		fi

		echo "source \"$src\"" >> "$dst"

		pcat "$dst"
	fi

done
