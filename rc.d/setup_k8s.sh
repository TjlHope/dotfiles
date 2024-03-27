#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function and alias for setting up k8s (kubectl & helm)
# TODO: support multiple kubectl profiles

# TODO: better source detection
# If it's sourced, and there's no kubectl don't polute the environment
[ "$(basename -- "$0" .sh)" != setup_k8s ] && _have kubectl || return 0

setup_k8s() {
    [ $# -le 1 ] || { echo "Usage: setup_k8s [timeout]" >&2; return 100; }
    _have kubectl || { echo "kubectl not found" >&2; return 111; }
    # shellcheck disable=2039
    local timeout='' _alias='' __all_ns=''
    timeout="${1-5s}"; case "$timeout" in *[0-9]) timeout="${timeout}s";; esac
    __all_ns='--all-namespaces=true'

    if [ "${_SH-}" = bash ]
    then
        eval "$(kubectl completion bash)"

        ! _have helm || eval "$(helm completion bash)"
    fi

    # TODO: remove?
    for _alias in \
        k="kubectl" \
        kall="kubectl $__all_ns" \
    ; do
        _alias "$_alias"
    done

    # shellcheck disable=2039
    local IFS _IFS='' ctx='' c='' nss='' ns='' ns_name=''
    _IFS="$IFS" IFS="${_NL:?FATAL}" || return
    for ctx in $(kubectl config get-contexts -oname)
    do  IFS="$_IFS"
        _can_alias "$ctx" || {
            echo "Warning: cannot alias k8s context: $ctx" >&2
            continue
        }
        _alias="kubectl --context=$ctx"
        _alias "kubectl-$ctx=$_alias"
        _alias "kubectl-$ctx-all=$_alias $__all_ns"
        # TODO: should this setup namespace aliases?
        _alias "kubectl-use-$ctx=kubectl config use-context $ctx"

        c="${ctx%${ctx#?}}"
        if _have "k$c" &&
            case "$(alias "k$c" 2>/dev/null)" in
                "alias k$c="*"$_alias"*) false;;
            esac
        then
            echo "Warning: not setting up short \`k$c\` alias" >&2
            echo "         for kube context '$ctx', already exists" >&2
            c=''
        else
            _alias "k$c=$_alias"
            _alias "k${c}all=$_alias $__all_ns"
        fi

        IFS="$_NL"
        nss="$(kubectl --context="$ctx" --request-timeout="$timeout" \
            get namespace --no-headers=true \
            --output=custom-columns=:.metadata.name \
        )" && for ns in $nss
        do  IFS="$_IFS"
            _can_alias "$ns" || {
                echo "Warning: cannot alias k8s namespace: $ns" >&2
                continue
            }
            ns_name="$(echo "$ns" | sed 's/[^[:alnum:]-]\+/_/g')"
            case "$ns_name" in
                kube_*|k8s_*|k8_*|kubernetes_*) ns_name="${ns_name#*_}";;
                kube-*|k8s-*|k8-*|kubernetes-*) ns_name="${ns_name#*-}";;
            esac
            _alias="kubectl --context=$ctx --namespace=$ns"
            # shellcheck disable=2139
            _alias "kubectl-$ctx-$ns_name=$_alias"
            [ -z "$c" ] || _alias "k$c$ns_name=$_alias"
        done
    done
    unset ctx c nss ns ns_name
    unset timeout _alias
}

alias .k8s=setup_k8s

# kubectl wrapper to provide extra commands/aliases I find useful
kubectl() {
    # shellcheck disable=2039
    local i='' a='' v=''
    i=$#
    while [ $i -gt 0 ]
    do  a="$1" i=$((i-1)); shift
        case "$a" in
            # every option seems to take a value, just rotate them
            -*=*)   set -- "$@" "$a";;
            -*)     v="$1" i=$((i-1)); shift; set -- "$@" "$a" "$v";;
            *)  # found the main cmd
                case "$a" in
                    ###### my custom aliases ######
                    sh) # next arg must be the pod
                        case "${1-}" in
                            ''|'-h'|'--help')
                                echo "Usage: kubectl sh <pod> [...sh-args]" >&2
                                return;;
                        esac
                        v="$1" i=$((i-1)); shift
                        set -- "$@" exec -ti "$v" -- sh     # rotate to the end
                        [ "$1" != -- ] ||                   # strip an extra --
                            { i=$((i-1)); shift; }
                        ;;
                    # everything else just rotate
                    *)  set -- "$@" "$a";;
                esac
                break;;     # found the main command, so break
        esac
    done
    while [ $i -gt 0 ]  # rotate the rest of the way round
    do  a="$1" i=$((i-1)); shift; set -- "$@" "$a"
    done
    command kubectl "$@"    # and now execute the real command
}

# if called with args, then run (eases testing)
[ $# -eq 0 ] || {
    case "$1" in
        [0-9]*) setup_k8s "$1"; shift;;
        *)      setup_k8s;;
    esac
    [ $# -gt 0 ] || return 0
    case "$1" in k*|helm) false;; esac || set -- kubectl "$@"
    "$@"
}
