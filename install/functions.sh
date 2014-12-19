
set -eu
cd "$(dirname "$0")/.."

if [ -t 1 ]; then

    function pp
    {
        echo -ne "\e[1;32m"
        echo -n "${*}"
        echo -e "\e[m"
    }

    function pcat
    {
        echo -ne "\e[0;36m"
        cat "$@" | sed -e 's/^/  /'
        echo -e "\e[m"
    }

else

    function pp
    {
        echo "${*}"
    }

    function pcat
    {
        cat "$@" | sed -e 's/^/  /'
        echo
    }

fi
