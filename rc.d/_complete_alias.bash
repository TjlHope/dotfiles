#!/bin/bash
# vi: sw=4 sts=4 ts=8 et
# Define a function to auto add completion for an alias

# Generate an individual completion wrapper for each alias (more environment
# polution but each individual completion is faster), a 'namespace' is used to
# make pollution less obvious. TODO: get working for non function completion
_complete_alias () {
    # Function to generate wrapper
    local IFS _IFS='' alias='' name_cmdline='' \
        name='' env='' cmd='' cmdline='' ns=''
    _IFS="$IFS" IFS="${_STN?:FATAL}" || return
    [ $# -gt 0 ] || { echo 'no alias provided' >&2; return 1; }
    [ $# -gt 1 ] || {
        # shellcheck disable=2086
        case "$1" in *=*) alias="$1";; *) alias="$(alias "$1")";; esac &&
        name_cmdline="$(echo "$alias" | _alias_name_cmdline)" &&
        [ -n "$name_cmdline" ] &&
        set -- $name_cmdline &&
        [ $# -gt 1 ]
    } || { echo "cannot find alias: $1" >&2; return 1; }
    IFS="$_IFS"
    name="$1" && shift
    # remember the cmdline can be `ENV1=val1 ENV2=val2 cmd args...`
    while [ $# -gt 0 ] && case "$1" in *=*) :;; *) false;; esac
    do  env="$env $1" && shift;
    done
    cmd="$1" cmdline="$*"
    [ "$name" = "$cmd" ] &&     # don't process ones like ls='ls --color=auto'
        return 0
    ns='_alias_comp.'           # namespace for aliases
    # Get the old completion function and completion line for the new alias
    local cmd_comp='' comp_func_comp='' comp_func='' comp=''
    cmd_comp="$(complete -p "$cmd" 2>/dev/null)" || return 0    # no completion
    comp_func_comp="$(echo "$cmd_comp" | sed -nEe "
        # complete functions are used as-is
        s:^(complete(\s.*)?\s-F\s+)(\S+)\s(.*)$cmd\s*$:\3|\1$ns$name \4$name:p
        # complete commands are surrounded in single quotes
        s:^(complete(\s.*)?\s-C\s+)'([^']+)'\s(.*)$cmd\s*$:\3|\1$ns$name \4$name:p
        ")" && [ -n "$comp_func_comp" ] ||
            return 0    # not a completion function/command
    comp_func="${comp_func_comp%%|complete*}"   # Get original function name
    comp="${comp_func_comp#*|}"                 # and the actual complete cmd
    # Generate the new wrapper function
    eval "
$ns$name () {
    COMP_CWORD=\$(( \${COMP_CWORD} + $(( $# - 1 )) ))
    COMP_WORDS=( $cmdline \"\${COMP_WORDS[@]:1}\" )
    COMP_POINT=\$(( \${COMP_POINT} - ${#name} + ${#cmdline} ))
    COMP_LINE=\"$cmdline\${COMP_LINE#$name}\"
    $env $comp_func $cmd \"\${COMP_WORDS[\${COMP_CWORD}]}\" \"\${COMP_WORDS[\$((\${COMP_CWORD} - 1))]}\" 
}" &&
    # Generate the new completion
    eval "$comp"
}

_alias_name_cmdline() {
    # optional alias prefix, option quotes surrounding cmdline
    # doesn't deal with embedded quotes or newlines, so ignores them
    sed -nEe "s:^(alias\s+)?([^\:;=]+)=(['\"])?([^;\:\"'(){}]+)\3?\s*$:\2 \4:p"
}

