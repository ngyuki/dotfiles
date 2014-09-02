################################################################################
### xdebug remote enable/disable

function xdebug-remote
{
    case $1 in
        on)
            if [ -n "$SSH_CLIENT" ]; then
                XDEBUG_CONFIG="idekey=default remote_host=$(echo $SSH_CLIENT | awk '{print $1}')"
            else
                XDEBUG_CONFIG="idekey=default"
            fi
            PHP_IDE_CONFIG="serverName=$(hostname -s)"
            export XDEBUG_CONFIG
            export PHP_IDE_CONFIG
            ;;
        off)
            XDEBUG_CONFIG=
            PHP_IDE_CONFIG=
            unset XDEBUG_CONFIG
            unset PHP_IDE_CONFIG
            export XDEBUG_CONFIG
            export PHP_IDE_CONFIG
            ;;
        *)
            echo "Usage xdebug-remote <on or off>" 1>&2
            return 1
            ;;
    esac

    echo "XDEBUG_CONFIG=$XDEBUG_CONFIG"
    echo "PHP_IDE_CONFIG=$PHP_IDE_CONFIG"
}
