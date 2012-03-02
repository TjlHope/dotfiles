#!/bin/bash

###############################
## Definition of bash completions

# Use drop in scripts
[ -f "/etc/profile.d/bash-completion.sh" ] && # gentoo style
    . "/etc/profile.d/bash-completion.sh"
[ -f "/etc/profile.d/bash_completion.sh" ] && # ubuntu style
    . "/etc/profile.d/bash_completion.sh"

# And indiviual programs without thier own completion
complete -o dirnames -fX '!*.[Pp][Dd][Ff]' apvlv mupdf
type 'VisualBoyAdvance' > /dev/null 2>&1 &&
    complete -o dirnames -fX '!*.[Gg][Bb]*' VisualBoyAdvance 
type 'desmume' > /dev/null 2>&1 &&
    complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume desmume-glade desmume-cli

# Wrap all alias definitions to allow completion when using them, this
# dynamically resolves the function - slower, but less environment pollution.
_wrap_alias () {
    # Function to generate wrapper
    local name="${1}"	; shift
    local cmd="${1}"	; shift
    [ "${name}" = "${cmd}" ] &&	# don't process ones like ls='ls --color=auto'
	return 0
    local ns="_alias."	# namespace for aliases
    # Get the old completion function and completion line for the new alias
    local comp="$(complete -p ${cmd} 2>/dev/null | sed -ne \
	"s:^\(complete\s.*\s-F\s\+\)\(\S\+\)\s\(.*\)${cmd}\s*$:\2|\1${ns}${name} \3${name}:p")"
    [ -z "${comp}" ] &&		# no completion function
	return 0
    local comp_func="${comp%%|complete*}"	# Get original function name
    # Generate the new wrapper function
    eval "
${ns}${name} () {
    COMP_CWORD=\$(( \${COMP_CWORD} + ${#} ))
    COMP_WORDS=( ${cmd} ${@} \${COMP_WORDS[@]:1} )
    ${comp_func} ${cmd} \${COMP_WORDS[\${COMP_CWORD}]} \${COMP_WORDS[\$((\${COMP_CWORD} - 1))]} 
}"
    # Generate new complete
    eval "${comp#*|}"
}
# Process all aliases
eval "$(alias -p | sed -ne \
    "s:^alias\s\+\([^\:;=]\+\)='\([^;\:\"'(){}]\+\)'\s*$:_wrap_alias \1 \2:p")"
# don't need function anymore
unset _wrap_alias

# Completion function allowing 'cd' to interpret N '.'s to mean the (N-1)th
# parent directory; i.e. '..' is up to parent, '...' is parent's parent,
# '....' is parent's parent's parent, etc.
_cdd () {
    COMP_WORDS[1]="$(echo "${COMP_WORDS[1]}" | sed -e \
	':sub
	s:^\(.*/\)\?\.\.\.:\1../..:g
	t sub')"
    _cd $1 ${COMP_WORDS[1]} $2
    return 0
}
complete -p cd >/dev/null 2>&1 &&
    complete -o nospace -F _cdd cd

# More complete 'sudo' completion (only works completely with my inputrc and in
# in a tmux session)
_sudo () {
    # Start default sudo completion
    local PATH="${PATH}:/sbin:/usr/sbin:/usr/local/sbin"
    local offset i;
    offset=1;
    for ((i=1; i <= COMP_CWORD; i++ ))
    do
	if [[ "${COMP_WORDS[i]}" != -* ]]; then
	    offset=$i;
	    break;
	fi;
    done;
    _command_offset ${offset}
    # End default sudo completion
    if [ ${#COMPREPLY[@]} -gt 1 ]; then
	return 0	# If we have several, return now
    elif [ ${#COMPREPLY[@]} -eq 1 ]; then
	# Need to expand aliases, so sudo can run them...
	local alias_cmd=( $(alias "${COMPREPLY[0]}" 2> /dev/null | \
	    sed -ne "s:^alias\s${COMPREPLY[0]}='\(.\+\)'\s*$:\1:p") )
	if [ -n "${alias_cmd[*]}" ]; then
	    # Only try expansion if name is different (ignore ll='ls -l', etc.)
	    [ ${COMPREPLY[0]} != ${alias_cmd[0]} ] && {
		[ -n "${TMUX}" ] &&	# Use tmux to send alias expansion keys
		    tmux send-keys "Escape" "L" "A" "Space" &&	# FIXME: HACK!!
		    COMPREPLY=()
		return 0	# Have one valid [expanded] alias, we're done
	    }
	fi
    fi
    #echo;echo "|${COMPREPLY[*]}|";echo
    if [ ${#COMPREPLY[@]} -le 0 ]; then
	local comp_func="$(complete -p "${COMP_WORDS[${offset}]}" 2>/dev/null \
	    | sed -ne \
	    "s:complete\s.*-F\s\(\S\+\)\s\+${COMP_WORDS[${offset}]}\s*$:\1:p")"
	if [ -n "${comp_func}" ]; then
	    COMP_WORDS=( ${COMP_WORDS[@]:${offset}} )
	    COMP_CWORD=$(( ${COMP_CWORD} - ${offset} ))
	    ${comp_func} ${COMP_WORDS[0]} $2 $3
	fi
    fi
    return 0
}
complete -p cd >/dev/null 2>&1 && {
    alias sudo='sudo '		# needed for alias expansion	# FIXME: HACK!!
    complete -F _sudo sudo
}

## End completions
######################

