
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

fetch-github-latest-release(){
    url=$1 # https://github.com/docker/compose
    latest=$(curl -fSIL "$url/releases/latest" | tr -d '\r' | awk -F'/' 'BEGIN{IGNORECASE=1}/^Location:/{print $NF}')
    if [ -z "$latest" ]; then
        echo "Unable fetch latest release" 1>&2
        return 1
    fi
    printf "%s" "$latest"
    return 1
}

install-github-latest-release() {    
    latest_url=$1
    download_url=$2
    dest_name=$3
    version_cmd=$4

    (
        set -eux

        latest=$(curl -fSIL "$latest_url" | tr -d '\r' | awk -F'/' 'BEGIN{IGNORECASE=1}/^Location:/{print $NF}')
        if [ -z "$latest" ]; then
            echo "Unable fetch latest release ... $url" 1>&2
            exit 1
        fi

        download_url="$(eval echo "$download_url")"

        tmp=$(mktemp -t "dotfiles-install-XXXXXXXX.$dest_name")
        trap 'rm -f -- "$tmp"' EXIT

        curl -fSL "$download_url" -o "$tmp"
        install -D -m0755 "$tmp" "$HOME/bin/$dest_name"
    )

    echo
    echo "$dest_name is installed ... $( $version_cmd )"
    exit 0
}


install-github-latest-release-tgz() {
    latest_url=$1
    download_url=$2
    extract_file=$3
    dest_name=$4
    version_cmd=$5

    (
        set -eux

        latest=$(curl -fSIL "$latest_url" | tr -d '\r' | awk -F'/' 'BEGIN{IGNORECASE=1}/^Location:/{print $NF}')
        if [ -z "$latest" ]; then
            echo "Unable fetch latest release ... $url" 1>&2
            exit 1
        fi

        download_url="$(eval echo "$download_url")"
        extract_file="$(eval echo "$extract_file")"
        download_file=${download_url##*/}

        tgz=$(mktemp -t "dotfiles-install-XXXXXXXX.$download_file")
        tmp=$(mktemp -t "dotfiles-install-XXXXXXXX.$dest_name")
        trap 'rm -f -- "$tgz" "$tmp"' EXIT

        curl -fSL "$download_url" -o "$tgz"
        tar -xf "$tgz" --to-stdout "$extract_file" > "$tmp"
        install -D -m0755 "$tmp" "$HOME/bin/$dest_name"
    )

    echo
    echo "$dest_name is installed ... $( $version_cmd )"
    exit 0
}
