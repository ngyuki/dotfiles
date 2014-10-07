#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "create symbolic links"

files=(
	.gitignore
	.inputrc
)

for fn in "${files[@]}"; do
    src="$PWD/${fn}"
    dst="$HOME/${fn}"
    ln -vsf "$src" "$dst"
done | pcat
