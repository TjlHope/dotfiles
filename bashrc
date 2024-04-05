#!/bin/bash
# ~/.bashrc
# shellcheck disable=1090,2015,2016
#
# This file is sourced by all *interactive* bash shells on startup, including
# some apparently interactive shells such as scp and rcp that can't tolerate
# any output. So make sure this doesn't display anything or bad things will
# happen!

# Test for an interactive shell. There is no need to set anything past this
# point for scp and rcp, and it's important to refrain from outputting anything
# in those cases.
case "$-" in
    *i*)    :;;         # Shell is interactive, carry on
    *)      return;;    # otherwise, be done now!
esac


###############################
## source any helper scripts for base variables & functions     {{{1
for s in "$HOME"/.rc.d/_*.sh "$HOME"/.rc.d/_*.bash
do  [ -f "$s" ] && . "$s"       # TODO: only if not already?
done; unset s
######################                                          }}}1

###############################
## Support graceful TERM fallback	{{{1

# But we can only do anything if we can find the terminfo directories...
if terminfo_d="$(_find_sys_dir share/terminfo)"
then
    has_term() {
	local term="${1-$TERM}"
	[ -n "$(find -L "$terminfo_d" -type f -name "$TERM")" ]
    }
    set_term() {
	local term="${1-$TERM}" pfx clrs sfxs sfx
	case "$term" in
	    *-truecolor)pfx="${term%-truecolor}" clrs=6000000;;	#TODO
	    *-256color)	pfx="${term%-256color}"	clrs=256;;
	    *-88color)	pfx="${term%-88color}"	clrs=88;;
	    *-16color)	pfx="${term%-16color}"	clrs=16;;
	    *-color)	pfx="${term%-color}"	clrs=8;;
	    *)		pfx="$term"		clrs=2;;
	esac
	sfxs="" &&
	    [ $clrs -ge 8 ] && sfxs="-color $sfxs" &&
	    [ $clrs -ge 16 ] && sfxs="-16color $sfxs" &&
	    [ $clrs -ge 88 ] && sfxs="-88color $sfxs" &&
	    [ $clrs -ge 256 ] && sfxs="-256color $sfxs" &&
	    [ $clrs -ge 6000000 ] && sfxs="-truecolor $sfxs" || :
	for sfx in $sfxs ''
	do has_term "$pfx$sfx" && export TERM="$pfx$sfx" && break
	done
    }

    # fix vte screwing TERM var
    [ "${COLORTERM+set}" = set ] && case "$COLORTERM" in
	"Terminal"|"gnome-terminal")
	    case "$TERM" in
		*-truecolor|*-256color)	:;;	# probably OK
		*)	# it's probably screwed it up - take a punt
		    echo "WARNING: don't trust TERM=$TERM for COLORTERM=$COLORTERM" >&2
		    export TERM="${TERM%-*color}-256color";;
	    esac;;
    esac

    has_term || set_term "$TERM" || {
	echo "WANING: cannot find suitable fallback for TERM=$TERM" >&2
	export TERM=xterm	# TODO: better fallback?
    }

    unset has_term set_term
fi
unset terminfo_d

## End TERM fallback		}}}1
######################

###############################
## Automate multiplexer use		{{{1

# Test to see if we are in a multiplexer session or not.
[ -n "$TMUX" ] || case "$TERM" in
    tmux*|screen*)	:;;	# do nothing - already in a mux session
    *)	# TODO: allow attaching to previous session.
	# TODO: get working with screen as well.
	# Not in a multiplexer session, so start one now. Make sure it's not a
	# function or builtin, and fail gracefully.
	mux_cmd="$(command -v "tmux")" && {
	    mux_active_cmd="${mux_cmd} list-sessions -F #{session_name}"
	    mux_new_cmd="${mux_cmd} new-session -ds \${name} \\; \
		set-option -qt \${name} lock-after-time \${timeout} \\; \
		attach-session -t \${name}"
	}
	[ -n "${mux_cmd}" ] && [ -z "${mux_cmd%%/*}" ] && {	# exists, and abs path
	    { [ -f "/proc/$$/cmdline" ] &&
		cat "/proc/$$/cmdline" ||
		ps -ocommand= "$$";
	    } | grep -q '^-' && {		# logins start with '-'
		name_pre='login'		# login session prefix
		timeout=300			# give them a 5 minute timeout
	    } || {
		name_pre='sh'		# normal session name prefix
		timeout=0			# don't timeout normal sessions
	    }
	    name_idx=0				# starting index
	    mux_active="$(${mux_active_cmd} 2>/dev/null)" && {
		# Check for conflicts
		while [ "${mux_active#*${name_pre}${name_idx}}" != \
		    "${mux_active}" ]
		do
		    name_idx=$(( name_idx + 1 ))
		done
	    }
	    name="${name_pre}${name_idx}"
	    eval "${mux_new_cmd}" && {	# run mux in foreground
		# If it didn't error, and the launched session is not still running,
		mux_active="$(${mux_active_cmd} 2>/dev/null)" &&
		    [ "${mux_active#*${name}}" != "${mux_active}" ] ||
		    exit		# finished with this terminal, so exit.
	    }
	    unset mux_active name_pre name_idx name timeout
	}
	unset mux_new_cmd mux_active_cmd mux_cmd
	;;
esac

## End mux		}}}1
######################

###############################
## Shell configuration variables	{{{1
# TODO: get rid of this - too magic

# Find path of this script, and consequently other conf files.
case "${_SH}" in
    bash)	rc_path="$(readlink -f "${BASH_SOURCE[0]}")";;
    zsh)	rc_path="$(readlink -f "${0}")";;
    *sh)	[ -f "${HOME}/.${_SH}rc" ] &&
		    rc_path="$(readlink -f "${HOME}/.${_SH}rc")";;
esac
export RC_D="${rc_path%/*}"
unset rc_path

# If not in a .dotfiles dir, the files will themselves be .dotfiles
[ "${RC_D}" = "${HOME}" ] && _DOT='.' || _DOT=''

## End shell conf	}}}1
######################

###############################
## Colourise and PS1			{{{1
## pulled from Gentoo's /etc/bashrc to allow changing PS1 with colour

# Get PS1 functions.
. "${RC_D}/${_DOT}ps1.bash"

USE_COLOR=false
find_term() {
    local line="" IFS=""
    while read -r line
    do  case "$line" in (TERM*)
	    case "TERM $TERM" in ($line)
		return;;
	    esac;;
	esac
    done
    false
}
for dir_colors in "${HOME}/.dir_colors.${TERM}" "${HOME}/.dircolors.${TERM}" \
    "${HOME}/.dir_colors" "${HOME}/.dircolors" "${PREFIX-}/etc/DIR_COLORS"
do
    [ -f "$dir_colors" ] && [ -r "$dir_colors" ] &&
	find_term <"$dir_colors" && USE_COLOR=true && break
done ||
    { _have dircolors &&
	dircolors -p | find_term && USE_COLOR=true; }
unset find_term dir_colors

if ${USE_COLOR}
then
    # Prefer ~/.dir_colors #64489
    if _have dircolors &&
	[ -n "$dir_colors" ] && [ -z "${dir_colors%%/*}" ]
    then
	eval "$(dircolors -b ${dir_colors:+"$dir_colors"})"
    fi
    # Variables to help setting PS1
    S="\\[\033[00;"		# start colour code (always reset first)
    N="${S}3"			# normal colour code
    B="${S}1;3"			# bold colour code
    [ "$TERM" != "linux" ] &&
	H="${S}9" ||		# highlighted color code
	H="${S}1;3"		# ...  (fall back to bold)
    I="${S}3;3"			# inverse colour code
    r=1 g=2 o=3 b=4 m=5 c=6	# colour codes
    E='m\]'			# end colour code
    D="${S}0$E"			# default color code
    # Repo status and prompt (#/$) code
    ps1="$N$c$E\$(_R) $B$b$E\\$ $D"
    [ $EUID -eq 0 ] && {	# prepend hostname, etc.
        ps1="$I$r$E\$(_t)$H$r$E\\h $H$b$E\\W$ps1"	# root is red,
    } || {
        ps1=" $H$b$E\$(_sW)$ps1"
        [ $EUID -lt 1000 ] &&
            ps1="$B$o$E\\u$N$r$E\$(_t)$N$o$E@$H$o$E\\h$ps1" ||	# system orange
            ps1="$B$g$E\\u$N$o$E\$(_t)$N$g$E@$H$g$E\\h$ps1"	# users green
    }
    ps1="$N$r$E$_x$ps1"		# prepend exit status in red
    unset S N B H r g o b m c E C
else
    # show root@ when we don't have colours
    [ $EUID = 0 ] &&
        ps1='${_x}\u$(_t)@\h \W$(_R) \$ ' ||
        ps1='${_x}\u$(_t)@\h $(_sW)$(_R) \$ '
fi

PS1="$ps1"	# Don't export it, as sub-shells may not be bash compatible.
# Try to keep environment pollution down.
unset safe_term dir_colors match_lhs ps1

## End Colourise	}}}1
######################

###############################
## Put your fun stuff here.	{{{1
######################

### bash control variables	{{{2
# prevents adding of useless commands to bash_history
export HISTCONTROL="erasedups"
export HISTIGNORE="l:l?:l??:duh:df:dfh:cd:[bf]g:batt:exit:?q"
export HISTSIZE=100000
export HISTTIMEFORMAT="%F %T %z  "
# PATH completion for cd (need to enter full name - no bash file completion)
export CDPATH=".:~:~/Documents/Imperial/EE4:~/Documents/Code/:~/Games:~/Documents:~/Videos:/run/media/${USER}:/media:/mnt"

### vi style	{{{2
set -o vi		# vi like line editing
export EDITOR="vim"

# determine whether we have vim*pager scripts.

_have 'vimpager' &&	false &&	# comment to enable
    export PAGER='vimpager'

if _have 'vimmanpager'	#&& false	# comment to enable
then
    export MANPAGER='vimmanpager'
elif _have 'vim'	#&& false	# comment to enable
then	# adapted from vimmanpager script
    opts="--cmd 'let no_plugin_maps = 1'"	# stop plugin maps before vimrc
    opts="${opts} -c 'sil! %s/\\[[0-9]\\+m//g'"	# remove ansi colour codes
    opts="${opts} -c 'sil! %!col -b'"		# filter to remove *roff stuff
    opts="${opts} -c 'set nolist nomod ft=man'"	# set up as man page
    opts="${opts} -c 'set fdm=manual'"		# ensure there's no folds
    opts="${opts} -c 'let g:showmarks_enable=0'"	# disable marks
    opts="${opts} -c 'runtime! macros/less.vim'"	# use less.vim
    export MANPAGER="vim ${opts} -"		# vim read from stdin
    unset opts
fi

export LESS="-R -M --shift 5 -i"

### Source shell additions, attempt to cache to reduce magic		{{{2

_have 'shopt' && {
    shopt -qs extglob	# used by gentoo functions, need to set it for cache
    shopt -qs no_empty_cmd_completion	# prevent cmd completion on empty line
}

# Source each file	{{{3
for t in "function" "alias" "complete"
do
    [ -f "${SHM_D}/${t}.cache" ] && {
	. "${SHM_D}/${t}.cache"
    } || {
	# Allow specific *.$_SH files to override generic *.sh ones
	[ -f "${RC_D}/${_DOT}${t}.sh" ] &&
	    . "${RC_D}/${_DOT}${t}.sh"
	[ -f "${RC_D}/${_DOT}${t}.${_SH}" ] &&
	    . "${RC_D}/${_DOT}${t}.${_SH}"
    }
done
unset t

# Cache the definitions, so we only have to do the checks and magic once. {{{3 
# It can't be done in individual files as complete, for example, may depend on 
# function, but defines more, etc.
false && [ -d "${SHM_D}" ] && [ -w "${SHM_D}" ] && {
    [ -f "${SHM_D}/complete.cache" ] ||
	complete -p | sed "s/^complete -F _minimal\\s*$/& ''/" >"${SHM_D}/complete.cache"
    [ -f "${SHM_D}/alias.cache" ] ||
	alias -p >"${SHM_D}/alias.cache"
    [ -f "${SHM_D}/function.cache" ] ||
	declare -fp >"${SHM_D}/function.cache"
}


### autostart.*sh contains stuff to run at startup - try it now		{{{2
priv() {	# run cmd with correct permissions and (io)niced
    local _nice="$(command -v nice) $(command -v ionice)"
    command sudo -nb -u "$USER" $_nice "$@"
}
for f in "$RC_D/${_DOT}autostart.$_SH" "$RC_D/${_DOT}autostart.sh"
do
    [ -f "$f" ] &&
	while read -r cmd args
	do
	    [ -n "${cmd###*}" ] &&	# have a non-(empty|comented) cmd
		! command pgrep -u "$USER" "$cmd" >/dev/null &&
                cmd="$(command -v "$cmd")" >/dev/null &&  # command is valid
		priv "$cmd" $args >/dev/null 2>&1	# run it
	done < "$f"
done
unset priv f cmd args

### Try and switch the Escape and Caps_Lock keys			{{{2
# FIXME: as switch_escape-capslock will be in SU_PATH (sbin) not PATH (bin), 
# there is no easy way to test for it's existance, let sudo fail instead.
command sudo -n switch_escape-capslock >/dev/null 2>&1

### Add ssh keys to agent if we have keychain (and the handy alias).	{{{2
_have 'keychain.add_all' && {
    trap ":" INT	# catch SIGINT to prevent it stopping the sourcing.
    # If not tried before, add keys; then stop future tries:
    [ -f "$SHM_D/keychain_added" ] || keychain.add_all --quiet
    [ -d "$SHM_D" ] && [ -w "$SHM_D" ] && touch "$SHM_D/keychain_added"
    trap - INT		# remove trap for following execution
}
[ -d "$SHM_D" ] || {
    echo "WARNING: SHM_D doesn't exist: post keychain" >&2
}


# Any ~/.rc.d/setup_* scripts to auto-init
_SETUP_INIT="$(_pathmunge "${_SETUP_INIT-}" \
    #aws - aws configure list-profiles is slow switch to sed? \
    #nvm \
    #k8s - not k8s as it's slow and needs auth \
)"

###############################
## source any extra rc scripts                          {{{1
for s in "$HOME"/.rc.d/[!_]*.sh "$HOME"/.rc.d/[!_]*.bash
do  [ -f "$s" ] && . "$s"       # TODO: only if not already?
done; unset s
######################                                  }}}1


# Output the current task status
_have t && t || :
