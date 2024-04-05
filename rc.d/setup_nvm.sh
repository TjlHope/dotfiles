#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function and alias for setting up nvm

# TODO: better source detection
# If it's sourced, and there's no ~/.nvm don't polute the environment
[ "$(basename -- "$0" .sh)" != setup_nvm ] && [ -d "$HOME/.nvm" ] || return 0

setup_nvm() {
    [ -d "$HOME/.nvm" ] || {
        # shellcheck disable=2088
        echo "~/.nvm doesn't exist" >&2
        return 1
    }

    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=1090
    . "$HOME/.nvm/nvm.sh"

    if [ "${BASH+set}" != set ]
    then
        # shellcheck disable=1090
        . "$HOME/.nvm/bash_completion"
    fi
}

alias .nvm=setup_nvm


case ":${_SETUP_INIT-}:" in *:nvm:*) setup_nvm;; esac

# if called with args, then run (eases testing)
[ $# -eq 0 ] || {
    setup_nvm
    [ "$1" = nvm ] || set -- nvm "$@"
    "$@"
}
