#!/bin/sh
# ~/.profile.d/find_sys_dir.sh
# Define a function for finding system directories from normal locations

_find_sys_dir() {
    local p='' d=''
    for p in ${PREFIX:+"$PREFIX/usr/local"} \
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
