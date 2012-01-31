#!/bin/bash
###############################
## Customisation of bash PS1

# If on a LANG is utf8, we want unicode support for "…" in `_W`.
[[ "${LANG}" =~ [Uu][Tt][Ff][-_]?8 ]] && {
    {	# If on a vt we need to successfully enable unicode
	[[ "${TERM}" != 'linux' ]] || unicode_start
    } && _elip="…"	# then enable utf8 elipsis.
} || {
    _elip='..'		# replacement string to if no unicode
}

## Short version of \w - attempt to limit PWD to set length.
_W () {
    local wd="${PWD/#${HOME}/~}"	# CWD with ~ for $HOME
    local len=${1:-$(( (${COLUMNS} / 2) - 25))}	# max length of \w; def: ~1/2
    #local len=$((${COLUMNS:-80} / 2 - 25))
    local chars=1	# minimum number of characters to keep from name
    local fixdot=1	# non-zero to have ${chars} after . in hidden .dirs
    local iter=3	# incrementally decrement len to ${chars}...
    local sep=2		# ... using decrement of ${sep}
    local nchars=$((${chars}+${iter}*${sep}))	# chars depending on ${iter}
    # Keep trying to shrink, one directory at a time
    while [ ${#wd} -gt ${len} ]
    do
	local h="${wd%%/*}"	# head (~) if it's there
	local b="${wd#${h}/}"	# main body
	local nb=""		# new body (before current dir)
	local d="${b%%/*}"	# current directory
	# Number of chars depending on ${fixdot}
	[ ${fixdot:-0} -gt 0 -a "${d}" != "${d#.}" ] &&
	    local nc=$((${nchars}+1)) || local nc=${nchars}
	b="${b#${d}/}"		# body (after current dir)
	# Iterate over directories for directory to shrink
	while [ "${d}" != "${b}" -a ${#d} -le $((${nc}+${#_elip})) ]
	do			# if current directory too short
	    nb="${nb}/${d}"	# add it to new body
	    d="${b%%/*}"	# get next directory
	    b="${b#${d}/}"	# get rest of body after new dir
	    # Number of chars depending on ${fixdot}
	    [ ${fixdot:-0} -gt 0 -a "${d}" != "${d#.}" ] &&
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
	wd="${h}/${nb#/}${nb:+/}${d:0:${nc}}${_elip}/${b}"
    done
    echo "${wd}"
}

## Include repositary information, e.g. branch, etc.
_R () {
    local d="$PWD"	# current dir
    local b=""		# branch name
    local x=""		# extra information about repo
    # Iterate up to root directory searching for repo.
    while [ -n "${d}" ]
    do
	if [ -d "${d}/.git" ]	# git repo
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
		b="$(< "${d}/.git/HEAD")"
		b="${b##*/}"
	    fi
	elif [ -d "${d}/.hg" ]	# mercurial repo
	then
	    b="$(< ${d}/.hg/branch)"
	else
	    d="${d%/*}"		# up a directory
	    continue
	fi
	echo " (${b}${x})"
	break
    done
}

# If run as a program, output a representation of PS1
[ "${0##*/}" = "ps1.bash" ] && {
    
    [ -n "${PS1}" ] ||		# Give PS1 a default
	PS1='(example)	\[\033[01;32m\]\u@\h\[\033[01;34m\] $(_W)\[\033[00;36m\]$(_R) \[\033[01;34m\]\$\[\033[00m\] '
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
