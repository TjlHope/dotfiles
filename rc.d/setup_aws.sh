#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function and alias for setting up aws

# TODO: better source detection
# If it's sourced, and there's no kubectl don't polute the environment
[ "$(basename -- "$0" .sh)" != setup_aws ] && _have aws || return 0

setup_aws() {
    [ $# -eq 0 ] || { echo "Usage: setup_k8s" >&2; return 100; }
    _have aws || { echo "aws not found" >&2; return 111; }

    # I don't like everything going to less
    export AWS_PAGER=""

    # shellcheck disable=2039
    local _complete_alias=''
    _have _complete_alias &&
        _complete_alias='_complete_alias' || _complete_alias=:

    if [ "${_SH-}" = bash ]
    then
        # shellcheck disable=2039
	if   _have _aws_completer;  then complete -C _aws_completer aws
	elif _have aws_completer;   then complete -C aws_completer aws
	else _complete_alias=:
	fi
    else
        _complete_alias=:
    fi

    # shellcheck disable=2039
    local alias_p='' _alias=''
    alias_p="$HOME/.aws/cli/alias"
    if [ -f "$alias_p" ]
    then
        # shellcheck disable=2013
        for profile in $(aws configure list-profiles)
        do
            _alias="aws-$profile=AWS_PROFILE=$profile aws"
            alias "$_alias"
            "$_complete_alias" "$_alias"
        done
    fi

    unset _complete_alias alias_p
}

alias .aws=setup_aws

# if called with args, then run (eases testing)
[ $# -eq 0 ] || {
    setup_aws
    case "$1" in aws|aws-*) false;; esac || set -- aws "$@"
    "$@"
}
