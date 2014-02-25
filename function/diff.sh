################################################################################
### diff powered by git

hash git 1> /dev/null 2>&1 || return

function diff()
{
    git diff --no-index "$@"
}
