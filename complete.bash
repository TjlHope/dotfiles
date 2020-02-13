#!/bin/bash

###############################
## Definition of bash completions

# Use drop in scripts
# shellcheck disable=2140 # seems rather dodgy detection...
for comp in \
    ${PREFIX:+ \
	"$PREFIX/etc/bash/bashrc.d/bash_completion.sh" \
	"$PREFIX/etc/profile.d/bash-completion.sh" \
	"$PREFIX/etc/profile.d/bash_completion.sh" \
	"$PREFIX/etc/bash_completion" \
    } \
    $(type brew >/dev/null 2>&1 && echo "$(brew --prefix)/etc/bash_completion") \
    "/etc/bash/bashrc.d/bash_completion.sh" \
    "/etc/profile.d/bash-completion.sh" \
    "/etc/profile.d/bash_completion.sh" \
    "/etc/bash_completion"
do
    # shellcheck source=/dev/null
    [ -f "$comp" ] && . "$comp" && break
done
unset comp

# And extension completion for programs without their own defined.
# TODO: Generate from mime database?
type 'apvlv' > /dev/null 2>&1 &&
    complete -o plusdirs -fX '!*.@(pdf|PDF)' apvlv
type 'mupdf' > /dev/null 2>&1 &&
    complete -o plusdirs -fX '!*.@(pdf|PDF)' mupdf
type 'zathura' > /dev/null 2>&1 &&
    complete -o plusdirs -fX '!*.@(pdf|PDF|djv?(u)|DJV?(U)|ps|PS)' zathura
type 'VisualBoyAdvance' > /dev/null 2>&1 &&
    complete -o plusdirs -fX '!*.@(gb|GB)*(c|C|a|A)' VisualBoyAdvance
type 'vbam' >/dev/null 2>&1 &&
    complete -o plusdirs -C 'vbam -C' vbam
type 'desmume' > /dev/null 2>&1 &&
    complete -o plusdirs -fX '!*.@(nds|NDS)' desmume desmume-glade desmume-cli

type 'rlwrap' >/dev/null 2>&1 && {
    alias rlwrap='rlwrap '	# needed for alias expansion	# FIXME: HACK!!
    complete -F _command rlwrap
}

type 'fork' >/dev/null 2>&1 &&
    complete -F _command fork

type 'pipe_wireshark' >/dev/null 2>&1 && {
    complete -F _ssh pipe_wireshark
}

type 'vm' >/dev/null 2>&1 &&
    complete -F _command vm

# Completion function allowing 'cd' to interpret N '.'s to mean the (N-1)th 
# parent directory; i.e. '..' is up to parent, '...' is grandparent, '....' is 
# great-grandparent, etc. Complement to 'cdd' function.
_cdd () {
    COMP_WORDS[${COMP_CWORD}]="$( \
	echo "${COMP_WORDS[$COMP_CWORD]}" | \
	    sed -e ':sub
		s:^\(.*/\)\?\.\.\.:\1../..:g
		t sub'
	)"
    [ "${1}" = "${2}" ] &&	# only do substitution once if needed
	two="${COMP_WORDS[$COMP_CWORD]}" || two="$2"
    _cd "$1" "${COMP_WORDS[${COMP_CWORD}]}" "$two"
}
complete -p cd >/dev/null 2>&1 && {
    complete -o nospace -F _cdd cd		# ./..../file 'cd' completion
    complete -o nospace -F _cdd pushd		# ... and for 'pushd'
    complete -o nospace -F _cdd pushpopd	# ... and my 'pd' function
}

# More complete 'sudo' completion (only works completely with my inputrc and in
# in a tmux session)
_sudo () {
    # Start default sudo completion
    local PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"
    local offset i;
    offset=1;
    for ((i=1; i <= COMP_CWORD; i++ ))
    do
	if [[ "${COMP_WORDS[i]}" != -* && "${COMP_WORDS[i]}" != *'='* ]]; then
	    offset=$i;
	    break;
	fi;
    done;
    _command_offset $offset
    # End default sudo completion
    #if [ ${#COMPREPLY[@]} -gt 1 ]; then
	#return 0	# If we have several, return now
    #elif [ ${#COMPREPLY[@]} -eq 1 ]; then
	# Need to expand aliases, so sudo can run them...
	#local alias_cmd=( $(alias "${COMPREPLY[0]}" 2> /dev/null | \
	    #sed -ne "s:^alias\s${COMPREPLY[0]}='\(.\+\)'\s*$:\1:p") )
	#if [ -n "${alias_cmd[*]}" ]; then
	    # Only expand if different name (ignore ls='ls -x', etc.)
	    #[ ${COMPREPLY[0]} != ${alias_cmd[0]} ] && {
		#[ -n "${TMUX}" ] &&	# Use tmux to send alias expansion keys
		    #tmux send-keys "Escape" ",xlA" "Space" &&	# FIXME: HACK!!
		    #COMPREPLY=()
		#return 0	# Have one valid [expanded] alias, we're done
	    #}
	#fi
    #fi
    #echo;echo "|${COMPREPLY[*]}|";echo
    if [ ${#COMPREPLY[@]} -le 0 ]; then
	local comp_func=""
	comp_func="$(complete -p "${COMP_WORDS[$offset]}" 2>/dev/null |
	    sed -nEe \
		"s:complete\s.*-F\s*(\S+)\s+${COMP_WORDS[$offset]}\s*$:\1:p"
	    )"
	if [ -n "${comp_func}" ]; then
	    COMP_WORDS=( "${COMP_WORDS[@]:$offset}" )
	    COMP_CWORD=$(( COMP_CWORD - offset ))
	    c_l=${#COMP_LINE}
	    COMP_LINE="${COMP_WORDS[${offset}]}${COMP_LINE#*${COMP_WORDS[${offset}]}}"
	    COMP_POINT=$(( COMP_POINT - c_l + ${#COMP_LINE} ))
	    unset c_l
	    "${comp_func}" "${COMP_WORDS[0]}" "$2" "$3"
	fi
    fi
    return 0
}
complete -p sudo >/dev/null 2>&1 && {
    alias sudo='sudo '		# needed for alias expansion	# FIXME: HACK!!
    complete -F _sudo sudo
}

type git-hg-diff >/dev/null 2>&1 &&
    _git_hg_diff() { _git_diff "$@"; }
type git-svn-diff >/dev/null 2>&1 &&
    _git_svn_diff() { _git_diff "$@"; }
type git-sparse-clone >/dev/null 2>&1 &&
    _git_sparse_clone() { _git_clone "$@"; }
type git-sparse >/dev/null 2>&1 &&
    _git_sparse() { _git_checkout "$@"; }

# Make everything with -o default have -o bashdefault
# FIXME: doesn't work as 'bashdefault' doesn't do files, and 'default' doesn't 
# understand $VAR etc. so it completes with filename \$VAR/file
#$(complete -p | sed -ne \
    #'\:\s-o\s\<default\>: {
	#\:\s-o\s\<bashdefault\>: !{
	    #s:\s-o\s\<default\>: -o bashdefault&:p
	#}
    #}')

# Wrap all alias definitions to allow completion when using them, generating an 
# individual completion wrapper for each alias (more environment polution but 
# each individual completion is faster), a 'namespace' is used to make 
# pollution less obvious. TODO: get working for non function completion
_wrap_alias () {
    # Function to generate wrapper
    local name="$1"	; shift
    local cmd="$1" cmdline="$*"
    [ "$name" = "$cmd" ] &&	# don't process ones like ls='ls --color=auto'
	return 0
    local ns="_alias_comp."	# namespace for aliases
    # Get the old completion function and completion line for the new alias
    local comp=""
    comp="$(complete -p "$cmd" 2>/dev/null | sed -nEe \
	"s:^(complete\s.*\s-F\s+)(\S+)\s(.*)$cmd\s*$:\2|\1$ns$name \3$name:p"
	)" || return
    [ -z "$comp" ] &&		# no completion function
	return 0
    local comp_func="${comp%%|complete*}"	# Get original function name
    # Generate the new wrapper function
    eval "
$ns$name () {
    COMP_CWORD=\$(( \${COMP_CWORD} + $(( $# - 1 )) ))
    COMP_WORDS=( $cmdline \"\${COMP_WORDS[@]:1}\" )
    COMP_POINT=\$(( \${COMP_POINT} - ${#name} + ${#cmdline} ))
    COMP_LINE=\"$cmdline\${COMP_LINE#$name}\"
    $comp_func $cmd \"\${COMP_WORDS[\${COMP_CWORD}]}\" \"\${COMP_WORDS[\$((\${COMP_CWORD} - 1))]}\" 
}"
    # Generate the new completion
    eval "${comp#*|}"
}
# Process all aliases
eval "$(alias -p | sed -ne \
    "s:^alias\s\+\([^\:;=]\+\)='\([^;\:\"'(){}]\+\)'\s*$:_wrap_alias \1 \2:p")"
# don't need function anymore
unset _wrap_alias

# shellcheck source=/dev/null
type 'tmuxinator_completion' >/dev/null 2>&1 &&
    . tmuxinator_completion
type 'teamocil' >/dev/null 2>&1 &&
    complete -W "$(teamocil --list)" teamocil

## End completions
######################

