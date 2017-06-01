#!/bin/sh
# ~/.profile.d/pathmunge.sh
# Define a function for munging colon (:) seperated PATHs

_pathmunge() {
    local a="" p="" IFS=":" donttest=true path="" 
    "${TEST:-false}" && donttest=false
    for a in "$@"
    do	for p in $a
	do  "$donttest" || [ -d "$p" ] || continue
	    case ":$path:" in
		*":$p:"*)   :;;	# already there, ignore
		*)	    path="$path:$p";;
	    esac
	done
    done
    echo "${path#:}"
}

# if called with args, then run
[ $# -eq 0 ] ||
    _pathmunge "$@"
