#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function for munging colon (:) seperated PATHs

_pathmunge() {
    # shellcheck disable=2039
    local a='' p='' _IFS='' IFS donttest='' path=''
    _IFS="$IFS"; IFS=":" donttest=true
    "${TEST:-false}" && donttest=false
    for a in "$@"
    do  for p in $a
        do  "$donttest" || [ -d "$p" ] || continue
            case ":$path:" in
                *":$p:"*)   :;; # already there, ignore
                *)          path="$path:$p";;
            esac
        done
    done
    echo "${path#:}"
    IFS="$_IFS"
}

# if called with args, then run
[ $# -eq 0 ] ||
    _pathmunge "$@"
