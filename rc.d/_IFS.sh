#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a backup IFS var and other related vars

_IFS="$IFS"
_NL="$(printf '\n#')" && _NL="${_NL%#}"
_TB="$(printf '\t#')" && _TB="${_TB%#}"
_SP=" "
_STN="$_SP$_TB$_NL"

export _IFS _NL _TB _SP _STN
