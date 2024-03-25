#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function to define an alias, and, if _complete_alias is available,
# enable completion for it.

_can_alias() {
    while [ $# -gt 0 ]
    do      # TODO: fix completion
        case "$1" in (*["&;|$_STN"]*) return 1;; esac
        shift
    done
}

_alias() {
    [ $# -eq 1 ] || {
        echo "Usage: _alias_and_complete <alias_name=alias_cmd>" >&2
        return 1
    }
    alias "$1" || return
    if _have _complete_alias
    then
        _complete_alias "$1"
    fi
}

