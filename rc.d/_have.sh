#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a silent `type` / `command -v` / `which` style function

_have() {
    [ $# -eq 1 ] || { echo "Usage: _have <cmd>"; return 100; }
    type "$1" >/dev/null 2>&1
}

# if called with args, then run
[ $# -eq 0 ] ||
    _have "$@"
