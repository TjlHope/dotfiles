#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function for finding system directories from normal locations

_find_sys_dir() {
    # shellcheck disable=2039
    local p='' d=''
    for p in    ${PREFIX:+"$PREFIX/usr/local"} \
                ${PREFIX:+"$PREFIX/usr"} \
                ${PREFIX:+"$PREFIX"} \
                /usr/local /usr /
    do  [ -d "$p" ] &&
            for d in "$@"
            do  [ -d "$p/$d" ] && echo "${p%/}/${d#/}" && return
            done
    done
}

# if called with args, then run
[ $# -eq 0 ] ||
    _find_sys_dir "$@"
