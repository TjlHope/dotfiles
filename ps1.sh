#!/bin/bash
###############################
## Customisation of bash PS1

######################
## Colourise
## pulled from Gentoo's /etc/bashrc to allow

use_color=false
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
    && type -P dircolors >/dev/null \
    && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    if type -P dircolors >/dev/null ; then
	if [[ -f ~/.dir_colors ]] ; then
	    eval $(dircolors -b ~/.dir_colors)
	elif [[ -f /etc/DIR_COLORS ]] ; then
	    eval $(dircolors -b /etc/DIR_COLORS)
	fi
    fi
    alias ls='ls --color=auto'
    alias grep='grep --colour=auto'
    [[ ${EUID} == 0 ]] &&
	PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] ' ||
	PS1='\[\033[01;32m\]\u\[\033[00;32m\]@\[\033[00;92m\]\h\[\033[01;34m\] $(_W)\[\033[00;36m\]$(_R) \[\033[01;34m\]\$\[\033[00m\] '
    # set color terminal
    #[[ "$XAUTHORITY" ]] && export TERM="xterm-256color"
else
    # show root@ when we don't have colors
    [[ ${EUID} == 0 ]] &&
	PS1='\u@\h \W \$ ' ||
	PS1='\u@\h $(_W)$(_R) \$ '
    # set non-color terminal
    #[[ "$XAUTHORITY" ]] && export TERM="xterm"
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

## Short version of \w - attempt to limit PWD to set length.
_W () {
    local wd="${PWD/#${HOME}/~}"	# CWD with ~ for $HOME
    local len=${1:-30}			# max length of \w
    #local len=$((${COLUMNS:-80} / 2 - 25))
    #local rep=".."	# replacement string to indicate shriking
    local rep="…"	# for this term needs same encoding as file (utf8)
    local chars=1	# minimum number of characters to keep from name
    local fixdot=1	# non-zero to have ${chars} after . in .dirs
    local iter=3	# incrementally decrement len to ${chars}...
    local sep=2		# ... using decrement of ${sep}
    local nchars=$((${chars}+${iter}*${sep}))	# chars depending on ${iter}
    # Keep trying to shrink, one directory at a time
    while [ ${#wd} -gt ${len} ]
    do
	local h=${wd%%/*}	# head (~) if it's there
	local b=${wd#${h}/}	# main body
	local nb=""		# new body (before current dir)
	local d=${b%%/*}	# current directory
	# Number of chars depending on ${fixdot}
	[ ${fixdot:-0} -gt 0 -a ${d} != ${d#.} ] &&
	    local nc=$((${nchars}+1)) || local nc=${nchars}
	b=${b#${d}/}		# body (after current dir)
	# Iterate over directories for directory to shrink
	while [ "${d}" != "${b}" -a ${#d} -le $((${nc}+${#rep})) ]
	do			# if current directory too short
	    nb="${nb}/${d}"	# add it to new body
	    d=${b%%/*}		# get next directory
	    b=${b#${d}/}	# get rest of body after new dir
	    # Number of chars depending on ${fixdot}
	    [ ${fixdot:-0} -gt 0 -a ${d} != ${d#.} ] &&
		nc=$((${nchars}+1)) || nc=${nchars}
	done
	[ "${d}" = "${b}" ] && {	# tried to shrink all dirs?
	    [ ${iter} -gt 0 ] && {	# still got iterations to go?
		iter=$((${iter}-1))
		nchars=$((${chars}+${iter}*${sep}))
		continue
	    } ||
		break			# ... done all we can, so end
	}
	# Join with reduced dir for new CWD
	wd="${h}/${nb#/}${nb:+/}${d:0:${nc}}${rep}/${b}"
    done
    echo "${wd}"
}

## Include repositary information, e.g. branch, etc.
_R () {
    local d=$PWD	# current dir
    local b=""		# branch name
    local x=""		# extra information about repo
    # Iterate up to root directory searching for repo.
    while [ -n "${d}" ]
    do
	if [ -d ${d}/.git ]	# git repo
	then
	    # Take action parsing from git bash completion
	    if [ -f "${d}/.git/rebase-merge/interactive" ]; then
		x="|REBASE-i"
		b="$(< "${d}/.git/rebase-merge/head-name")"
	    elif [ -d "${d}/.git/rebase-merge" ]; then
		x="|REBASE-m"
		b="$(< "${d}/.git/rebase-merge/head-name")"
	    else
		if [ -d "${d}/.git/rebase-apply" ]; then
		    if [ -f "${d}/.git/rebase-apply/rebasing" ]; then
			x="|REBASE"
		    elif [ -f "${d}/.git/rebase-apply/applying" ]; then
			x="|AM"
		    else
			x="|AM/REBASE"
		    fi
		elif [ -f "${d}/.git/MERGE_HEAD" ]; then
		    x="|MERGING"
		elif [ -f "${d}/.git/BISECT_LOG" ]; then
		    x="|BISECTING"
		fi
	    # End action parsing from git bash completion.
		b=$(< "${d}/.git/HEAD")
		b=${b##*/}
	    fi
	elif [ -d ${d}/.hg ]	# mercurial repo
	then
	    b=$(<${d}/.hg/branch)
	else
	    d=${d%/*}		# up a directory
	    continue
	fi
	echo " (${b}${x})"
	break
    done
}

# If run as a program, output a representation of PS1
[ ${0##*/} = "ps1.sh" ] && {
    [ "${1}" = "raw" ] &&
    echo "PS1:	${PS1}" ||
    echo -e "PS1:\t$(echo "${PS1}" | sed -e 's:\\\(\[\|\]\)::g' \
					-e "s:\\\\u:$USER:g" \
					-e "s:\\\\h:$(hostname):g" \
					-e "s:\$(_W):$(_W):g" \
					-e "s:\$(_R):$(_R):g" \
					-e 's:\\\$:$:g' \
		    )"
}
