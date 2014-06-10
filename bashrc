# ~/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup, including
# some apparently interactive shells such as scp and rcp that can't tolerate
# any output. So make sure this doesn't display anything or bad things will
# happen!

# Test for an interactive shell. There is no need to set anything past this
# point for scp and rcp, and it's important to refrain from outputting anything
# in those cases.
case "$-" in
    *i*)	:;;		# Shell is interactive, carry on
    *)		return;;	# otherwise, be done now!
esac

###############################
## Fix vte screwing TERM variable	{{{1

if [ -n "${COLORTERM}" -a "${TERM%color}" = "${TERM}" ] ||
    [ ! -f "/usr/share/terminfo/${TERM%${TERM#?}}/${TERM}" ]
then
    case "${COLORTERM}" in
	"Terminal")
	    export TERM="${TERM}-256color"
	    ;;
	"rxvt-xpm")
	    export TERM="${TERM}-256color"
	    ;;
	"gnome-terminal")
	    export TERM="${TERM}-16color"
	    ;;
	*)
	    export TERM="${TERM}-color"
	    ;;
    esac
fi

## End vte fix		}}}1
######################

###############################
## Automate multiplexer use		{{{1

# Test to see if we are in a multiplexer session or not.
if [ "${TERM#screen}" = "${TERM}" ]
then

    # TODO: allow attaching to previous session.
    # TODO: get working with screen as well.
    # Not in a multiplexer session, so start one now. Make sure it's not a
    # function or builtin, and fail gracefully.
    mux_cmd="$(command -v "tmux")" && {
	mux_active_cmd="${mux_cmd} list-sessions -F #{session_name}"
	mux_new_cmd="${mux_cmd} new-session -ds \${name} \\; \
	    set-option -qt \${name} lock-after-time \${timeout} \\; \
	    attach-session -t \${name}"
    }
    [ -n "${mux_cmd}" -a -z "${mux_cmd%%/*}" ] && {	# exists, and abs path
	sed -n -e '/^-/q1' /proc/$$/cmdline && {	# logins start with '-'
	    name_pre='sh'		# session name prefix
	    timeout=0			# don't timeout normal sessions
	} || {
	    name_pre='login'		# ... or for login shells
	    timeout=300			# 5 minute timeout for login shells
	}
	name_idx=0				# starting index
	mux_active="$(${mux_active_cmd} 2>/dev/null)" && {
	    # Check for conflicts
	    while [ "${mux_active#*${name_pre}${name_idx}}" != \
		"${mux_active}" ]
	    do
		name_idx=$(( ${name_idx} + 1 ))
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

fi

## End mux		}}}1
######################

###############################
## Shell configuration variables	{{{1

# Find the name of the current shell
[ -f "/proc/$$/comm" ] && {	# only available in later kernels.
    read _SH < "/proc/$$/comm"
} || {
    _SH="$(sed -ne "s:^-\?\([^\x00]\+\)\x00.*:\1:p" "/proc/$$/cmdline")"
    _SH="${_SH##*/}"
}
# Find path of this script, and consequently other conf files.
case "${_SH}" in
    bash)
	rc_path="$(readlink -f "${BASH_SOURCE[0]}")"
	;;
    zsh)
	rc_path="$(readlink -f "${0}")"
	;;
    *sh)
	[ -f "${HOME}/.${_SH}rc" ] &&
	    rc_path="$(readlink -f "${HOME}/.${_SH}rc")"
	;;
esac
export RC_D="${rc_path%/*}"
unset rc_path

# If not in a .dotfiles dir, the files will themselves be .dotfiles
[ "${RC_D}" = "${HOME}" ] && _DOT='.' || _DOT=''

[ -z "${SHM_D}" ] && {	# if not set from profile, do it now.
    ### export SHM_D variable pointing to personal tempory storage
    ! sed -ne '\:^\s*\S\+\s\+/dev/shm\s\+tmpfs\s\+.*$: q1' /proc/mounts &&
	export SHM_D="/dev/shm/${USER}" ||
	export SHM_D="/tmp/${USER}"	# default to /tmp if no shared memory
    [ -d "${SHM_D}" ] || mkdir "${SHM_D}"
    [ -d "${SHM_D}" ] && chmod 700 "${SHM_D}"	# user read only
}

## End shell conf	}}}1
######################

###############################
## Colourise and PS1			{{{1
## pulled from Gentoo's /etc/bashrc to allow changing PS1 with colour

# Get PS1 functions.
. "${RC_D}/${_DOT}ps1.bash"

USE_COLOR=false
_dircolors="$(command -v "dircolors")"	# The dircolors command
for dir_colors in "${HOME}/.dir_colors.${TERM}" "${HOME}/.dircolors.${TERM}" \
    "${HOME}/.dir_colors" "${HOME}/.dircolors" "/etc/DIR_COLORS" ""
do
    [ -f "${dir_colors}" -a -r "${dir_colors}" ] || continue
    while read line
    do
	[ "${line#TERM ${TERM}}" != "${line}" ] &&
	    USE_COLOR=true &&
	    break
    done < "${dir_colors:-$(${_dircolors} -p)}" || continue
    break       # TODO: if  ^this doesn't exist??
done

if ${USE_COLOR}
then
    # Prefer ~/.dir_colors #64489
    if [ -n "$_dircolors" -a -z "${_dircolors%%/*}" ] &&
	[ -n "$dir_colors" -a -z "${dir_colors%%/*}" ]
    then
	eval "$($_dircolors -b ${dir_colors:+"$dir_colors"})"
    fi
    # Variables to help setting PS1
    S='\[\033[00;'		# start colour code (always reset first)
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
        ps1="$I$r$E\$(_t)$H$r$E\h $H$b$E\W$ps1"	# root is red,
    } || {
        ps1=" $H$b$E\$(_sW)$ps1"
        [ $EUID -lt 1000 ] &&
            ps1="$B$o$E\u$N$r$E\$(_t)$N$o$E@$H$o$E\h$ps1" ||	# system orange
            ps1="$B$g$E\u$N$o$E\$(_t)$N$g$E@$H$g$E\h$ps1"	# users green
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
unset safe_term _dircolors dir_colors match_lhs ps1

## End Colourise	}}}1
######################

###############################
## Put your fun stuff here.	{{{1
######################

### bash control variables	{{{2
# prevents adding of useless commands to bash_history
export HISTCONTROL="ignoreboth"
export HISTIGNORE="l:l?:l??:duh:df:dfh:cd:[bf]g:batt:exit:?q"
export HISTSIZE=1000
# PATH completion for cd (need to enter full name - no bash file completion)
export CDPATH=".:~:~/Documents/Imperial/EE4:~/Documents/Code/:~/Games:~/Documents:~/Videos:/run/media/${USER}:/media:/mnt"

### vi style	{{{2
set -o vi		# vi like line editing
export EDITOR="vim"

# determine whether we have vim*pager scripts.

type 'vimpager' >/dev/null 2>&1 &&	false &&	# comment to enable
    export PAGER='vimpager'

if type 'vimmanpager' >/dev/null 2>&1	#&& false	# comment to enable
then
    export MANPAGER='vimmanpager'
elif type 'vim' >/dev/null 2>&1		#&& false	# comment to enable
then	# adapted from vimmanpager script
    opts="--cmd 'let no_plugin_maps = 1'"	# stop plugin maps before vimrc
    opts="${opts} -c 'sil %s/\[[0-9]\+m//g'"	# remove ansi colour codes
    opts="${opts} -c 'sil %!col -b'"		# filter to remove *roff stuff
    opts="${opts} -c 'set nolist nomod ft=man'"	# set up as man page
    opts="${opts} -c 'let g:showmarks_enable=0'"	# disable marks
    opts="${opts} -c 'runtime! macros/less.vim'"	# use less.vim
    export MANPAGER="vim ${opts} -"		# vim read from stdin
    unset opts
fi


### Source shell additions, attempt to cache to reduce magic		{{{2

type 'shopt' >/dev/null 2>&1 && {
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
[ -d "${SHM_D}" -a -w "${SHM_D}" ] && {
    [ -f "${SHM_D}/complete.cache" ] ||
	complete -p >"${SHM_D}/complete.cache"
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
	while read cmd args
	do
	    [ -n "${cmd###*}" ] &&	# have a non-(empty|comented) cmd
		! command pgrep -u "$USER" "$cmd" >/dev/null &&
                cmd="$(command -v $cmd)" >/dev/null &&  # command is valid
		priv "$cmd" $args >/dev/null 2>&1	# run it
	done < "$f"
done
unset priv f cmd args

### Try and switch the Escape and Caps_Lock keys			{{{2
# FIXME: as switch_escape-capslock will be in SU_PATH (sbin) not PATH (bin), 
# there is no easy way to test for it's existance, let sudo fail instead.
command sudo -n switch_escape-capslock >/dev/null 2>&1

### Add ssh keys to agent if we have keychain (and the handy alias).	{{{2
type 'keychain.add_all' >/dev/null 2>&1 && {
    trap ":" INT	# catch SIGINT to prevent it stopping the sourcing.
    # If not tried before, add keys; then stop future tries:
	[ -f "${SHM_D}/keychain_added" ] || keychain.add_all --quiet
	[ -d "${SHM_D}" -a -w "${SHM_D}" ] && >"${SHM_D}/keychain_added"
    trap - INT		# remove trap for following execution
}

