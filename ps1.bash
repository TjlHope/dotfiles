#!/bin/bash

###############################
## Customisation of bash PS1

# If on a LANG is utf8, we want unicode support for "…" in `_W`.
case "$LANG" in
    *.[uU][tT][fF]8|*.[uU][tT][fF]-8)
	{	# If on a vt we need to successfully enable unicode
	    [ "$TERM" != 'linux' ] || unicode_start
	} && _elip="…";;	# then enable utf8 elipsis.
    *)  _elip='..';;		# replacement string to if no unicode
esac

## Short version of \w - attempt to limit PWD to set length.
_W () {
    local wd="${PWD/#$HOME/~}"	# CWD with ~ for $HOME	# FIXME:bashism
    #[ "${PWD#$HOME}" = "$PWD" ] &&
	#local wd="$PWD" ||		# current working directory
	#local wd="~${PWD#$HOME}"	# ... with ~ for $HOME
    local len=${1:-$((${COLUMNS-80} / 2 - 25))}	# max length of \w; def: ~1/2
    [ $len -lt 0 ] && len=0			# can't have a negative length
    local chars=1	# minimum number of characters to keep from name
    local fixdot=1	# set non-zero to have $chars after . in hidden .dirs
    local iter=3	# incrementally decrement $len to $chars...
    local sep=2		# ... using decrement of $sep
    # Keep trying to shrink, one directory at a time
    while [ ${#wd} -gt $len ]
    do
	local nchars=$(($chars + $iter * $sep))	# $iter dependent chars
	local h="${wd%%/*}"	# head (~) if it's there
	local b="${wd#$h/}"	# main body
	local nb=""		# new body (before current dir)
	local d="${b%%/*}"	# current directory
	b="${b#$d/}"		# body (after current dir)
	# Number of chars depending on ${fixdot}
	[ ${fixdot:-0} -gt 0 -a "$d" != "${d#.}" ] &&
	    local nc=$(($nchars + 1)) || local nc=$nchars
	# Iterate over directories for directory to shrink
	while [ "$b" != "${b#*/}" -a ${#d} -le $(($nc + ${#_elip})) ]
	do			# if current directory too short
	    nb="$nb/$d"		# add it to new body
	    d="${b%%/*}"	# get next directory
	    b="${b#$d/}"	# get rest of body after new dir
	    #[ -n "$DEBUG" ] && echo "$h | $nb | $d | $b" >&2
	    # Number of chars depending on ${fixdot}
	    [ ${fixdot:-0} -gt 0 -a "$d" != "${d#.}" ] &&
		nc=$(($nchars + 1)) || nc=$nchars
	done
	# Join with reduced dir for new CWD
	wd="$h/${nb#/}${nb:+/}${d:0:$nc}$_elip/$b"	# FIXME:bashism
	[ "$b" = "${b#*/}" ] && {	# tried to shrink all dirs?
	    [ $iter -gt 0 ] && {	# still got iterations to go?
		iter=$(($iter - 1))
		continue		# ... go to next iteration
	    } ||
		break			# ... done all we can, so end
	}
    done
    echo "$wd"
}

## Short version of \w - uses sed instead of shell loops, expansion and globs.
# Executes an order of magnitude faster, but is less customisable and elegant.
# It will either strip all chars from first dir, then all chars from second
# dir, etc.  or strip every directory by 1 char for each iteration, regardless
# of individual directory length.
_sW () {
    # Pass sed flags in as first, and length as second variables.
    # 'p' flag good for debugging, 'g' flag reduces every dir simultaneously,
    # instead of doing the first, then the second, etc.
    local len=${2:-$((${COLUMNS-80} / 2 - 25))}	# max length of \w; def: ~1/2
    [ $len -lt 0 ] && len=0			# can't have a negative length
    local chs=1		# minimum number of characters to keep from name
    local _el="${_elip//./\\.}"					# FIXME:bashism
    #_el="$(echo "$_elip" | sed 's:\.:\\.:g')"			# FIXME:SLOW!!
    echo "$PWD" | sed -e "\
	s:^$HOME:\~:
	:chk
	\:^.\{0,$len\}$: b
	:sub
	s:\(\.\?[^/]\{$chs,\}\)[^/$_el]\{1,\}\($_el\)\?/:\1$_el/:${1-}
	t chk
	"
}

## Provide repositary information, e.g. branch, etc.
_R () {
    local d="$PWD"	# current dir
    local b=""		# branch name
    local x=""		# extra information about repo
    # Iterate up to root directory searching for repo.
    while [ -n "$d" ]
    do
	if [ -e "$d/.git" ] && {			# git repo
		[ -d "$d/.git" ] &&			# standard git repo
		    git_d="$d/.git" || {
		    local a v				# otherwise submodule
		    while read a v
		    do
			case "$a" in
			    gitdir:)	git_d="$d/$v";;
			    *)		false;;
			esac && break
		    done < "$d/.git"
		}
	    } && [ -f "$git_d/HEAD" ]
	then

	    # Take action parsing from git bash completion
	    if [ -f "$git_d/rebase-merge/interactive" ]
	    then
		x="|REBASE-i"
		#b="$(< "$d/.git/rebase-merge/head-name")"	# FIXME:bashism
		read -r b < "$git_d/rebase-merge/head-name"
	    elif [ -d "$git_d/rebase-merge" ]
	    then
		x="|REBASE-m"
		#b="$(< "$git_d/rebase-merge/head-name")"	# FIXME:bashism
		read -r b < "$git_d/rebase-merge/head-name"
	    else
		if [ -d "$git_d/rebase-apply" ]
		then
		    if [ -f "$git_d/rebase-apply/rebasing" ]; then
			x="|REBASE"
		    elif [ -f "$git_d/rebase-apply/applying" ]; then
			x="|AM"
		    else
			x="|AM/REBASE"
		    fi
		elif [ -f "$git_d/MERGE_HEAD" ]
		then
		    x="|MERGING"
		elif [ -f "$git_d/BISECT_LOG" ]
		then
		    x="|BISECTING"
		fi
	    # End action parsing from git bash completion.
		#b="$(< "$git_d/HEAD")"				# FIXME:bashism
		read -r b < "$git_d/HEAD"
		b="${b##*/}"
	    fi
	elif [ -d "$d/.hg" -a -f "$d/.hg/branch" ]	# mercurial repo
	then
	    if [ -d "$d/.hg/merge" ]
	    then
		x="|MERGING"
	    fi
	    #b="$(< "$d/.hg/branch")"				# FIXME:bashism
	    read -r b < "$d/.hg/branch"
	elif [ -d "$d/CVS" ]				# CVS repo
	then
	    if [ -f "$d/CVS/Tag" ]
	    then
		read -r b < "$d/CVS/Tag"
		b="${b#T}"
	    else
		b=HEAD
	    fi
	else			# up a directory
	    d="${d%/*}"	
	    continue
	fi
	[ ${#b} -le 10 ] ||
	    b="${b%${b#?????????}}$_elip"
	echo " ($b$x)"
	break
    done
}

## Provide task number
_t () {
    type t >/dev/null 2>&1 || return    # if we don't have it, do nothing
    local num=$(t 2>/dev/null | wc -l) print0=false
    [ "${1-}" = -0 ] && print0=true && shift
    [ ${num:-0} -gt 0 ] || $print0 &&
	echo "${1:-[}${num:-0}${2:-${1:-]}}"
}

## Displays non-zero exit status at end of previous line
# CSI:	\033[
#	CNL:	nE	CPL:	nF
#	CHA:	nG	CUP:	n;mH
#	SCP:	s	RCP:	u
# NB:
#	Cannot output these codes from a function as bash only evaluates PS1 
#	once.
# NB:
#	Anything not in the main prompt should be enclosed in \[..\] so as to 
#	not screw up cursor position when accessing history or with multiline 
#	commands.
_xf () {	# Outputs non-zero exit status (iff a new command)
    local x=${?} p
    [ -f "${SHM_D}/cmd/$$" ] && read p < "${SHM_D}/cmd/$$"
    [ ${x} -gt 0 ] && [ ${p:-0} -ne ${1} ] && {
	echo ${1} > "${SHM_D}/cmd/$$"
	echo ${x}
    }
}
[ -d "${SHM_D}/cmd" ] || mkdir "${SHM_D}/cmd"	# make the dir for _xf
# This only works at the start of PS1:
#_x="\[\033[F\033[\$((\${COLUMNS}-\${#?}+1))G\$(_xf \\#)\033[E\]"
# By saving and restoring cursor position this should work anywhere:
_x="\\[\033[s\033[F\033[\$((\${COLUMNS}-\${#?}+1))G\$(_xf \\#)\033[u\\]"

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
					    -e "s:\$(_sW):$(_sW):g" \
					    -e "s:\$(_R):$(_R):g" \
					    -e 's:\\\$:$:g' \
			)"
} || true
