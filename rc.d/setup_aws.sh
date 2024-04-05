#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function and alias for setting up aws

# TODO: better source detection
# If it's sourced, and there's no kubectl don't polute the environment
[ "$(basename -- "$0" .sh)" != setup_aws ] && _have aws || return 0

# I don't like everything going to less by default
export AWS_PAGER="${AWS_PAGER-}"

setup_aws() {
    [ $# -eq 0 ] || { echo "Usage: setup_k8s" >&2; return 100; }
    _have aws || { echo "aws not found" >&2; return 111; }

    if [ "${_SH-}" = bash ]
    then
        # shellcheck disable=2039
	if   _have _aws_completer;  then complete -C _aws_completer aws
	elif _have aws_completer;   then complete -C aws_completer aws
	fi
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
            _alias "$_alias"
        done
    fi

    unset _complete_alias alias_p
}

alias .aws=setup_aws

# make sourcing this file cause the cached cmds to be re-generated
unset __aws_cmds
__aws_cmds() {
    [ "${__aws_cmds+set}" = set ] || __aws_cmds="$(aws - 2>&1 | sed -nEe '
        1,/aws: error:/d
        /^\s*$/d
        s/\s*\|\s*/\n/
        p
    ')" || return
    echo "$__aws_cmds"
}

# aws wrapper to provide extra commands I find useful
# that don't work as aliases
aws() {
    # shellcheck disable=2039
    local i='' a='' seen_opt=''
    i=$# seen_opt=false
    while [ $i -gt 0 ]
    do  a="$1" i=$((i-1)); shift
        case "$a" in
            -*=*)   set -- "$@" "$a"; seen_opt=false;;
            # some options take values, some don't, so just rotate the options
            # and hope that a value doesn't match a command name
            -*)     set -- "$@" "$a"; seen_opt=true;;
            ###### custom aliases ######
            sh)
                [ $i -ge 1 ] || {
                    echo "Usage: aws sh <instance> [...args]" >&2; return 1
                }
                # shellcheck disable=2039
                local target=''
                case "$1" in
                    i-) target="$1";;   # already looks like an instance id
                    *)  { target="$(aws ec2 instances --id "$1")" &&
                            [ -n "$target" ] &&
                            [ "$(echo "$target" | wc -l)" -eq 1 ]
                        } || {
                            echo "cannot find one instance to connect to for '$1':" >&2
                            echo "$target" >&2
                            return 1
                        };;
                esac
                i="$((i-1))"; shift
                set -- "$@" ssm start-session --target "$target"
                break;;     # found cmd, break
            ###### end custom aliases ######
            # else look for potential commands
            *)  # found a potential command
                # we're going to want to rotate it anyway
                set -- "$@" "$a"
                case "$_NL${__aws_cmds=$(__aws_cmds)}$_NL" in
                    *"$_NL$a$_NL"*) break;;     # it is a cmd, so break
                    # else if we've seen an opt, assume this is a val and
                    # continue, otherwise assume it's a cmd typo or __aws_cmds
                    # caching problem, and break
                    *)      "$seen_opt" || break;;
                esac
        esac
    done
    while [ $i -gt 0 ]  # rotate the rest of the way round
    do  a="$1" i=$((i-1)); shift; set -- "$@" "$a"
    done
    command aws "$@"    # and now execute the real command
}


case ":${_SETUP_INIT-}:" in *:aws:*) setup_aws;; esac

# if called with args, then run (eases testing)
[ $# -eq 0 ] || {
    setup_aws
    case "$1" in aws|aws-*) false;; esac || set -- aws "$@"
    "$@"
}
