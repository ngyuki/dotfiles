
set -eu
cd "$(dirname "$0")/.."

if [ -t 1 ]; then

    function pp
    {
        printf "\e[1;32m%s\e[m\n" "${*}"
    }

    function pcat
    {
        printf "\e[0;36m"
        cat "$@" | sed -e 's/^/  /'
        printf "\e[m\n"
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
