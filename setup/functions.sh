
set -eu
cd "$(dirname "$0")/.."

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
