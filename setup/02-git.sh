#!/bin/bash

source "$(dirname "$0")/functions.sh"

pp "git config"

gitcheck=$(
    {
        git version | cut -f3 -d" "
        echo 1.8.0
    } | sort -t . -n -k 1,1 -k 2,2 -k 3,3 | head -1
)

if [ "$gitcheck" == "1.8.0" ]; then
    cmd=(git config --global include.path "$PWD/.gitconfig")
else
    cmd=(git config --global include.path "$PWD/.gitconfig-17")
fi

echo "${cmd[@]}" | pcat
"${cmd[@]}"
