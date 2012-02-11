# ~/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup, including
# some apparently interactive shells such as scp and rcp that can't tolerate
# any output. So make sure this doesn't display anything or bad things will
# happen!

# Test for an interactive shell. There is no need to set anything past this
# point for scp and rcp, and it's important to refrain from outputting anything
# in those cases.
if [ "${-#*i}" = "${-}" ]
then

    # Shell is non-interactive.  Be done now!
    return

fi

###############################
## Fix vte screwing TERM variable

if [ -n "${COLORTERM}" -a "${TERM%color}" = "${TERM}" ]
then
    case "${COLORTERM}" in
	"Terminal")
	    export TERM="$TERM-256color"
	    ;;
	*)
	    export TERM="$TERM-color"
	    ;;
    esac
fi

## End vte fix
######################

# Test to see if we are in a multiplexer session or not.
if [ "${TERM#screen}" = "${TERM}" ]
then

    # Not in a multiplexer session, so start one now. Make sure it's not a
    # function or builtin, and fail gracefully.
    _tmux="$(command -v "tmux")"
    [ -n "${_tmux}" -a -z "${_tmux%%/*}" ] &&	# exists, and absolute path
	${_tmux}
    # TODO: allow attaching to previous session.
    unset _tmux

fi

# Find path of this script, and consequently other conf files.
rc_path="$(readlink -f "${BASH_SOURCE[0]}")"			# FIXME:bashism
export RC_DIR="${rc_path%/*}"
unset rc_path

###############################
## Colourise
## pulled from Gentoo's /etc/bashrc to allow changing PS1 with colour

# Get PS1 functions.
[ "${RC_DIR}" = "${HOME}" ] &&
    . "${HOME}/.ps1.bash" ||
    . "${RC_DIR}/ps1.bash"

use_color=false
safe_term=${TERM//[^[:alnum:]]/?}	# sanitize TERM		# FIXME:bashism
_dircolors="$(command -v "dircolors")"	# The dircolors command
match_lhs=""						# FIXME:bashisms (2j)
[ -f "${HOME}/.dir_colors" ] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[ -f "/etc/DIR_COLORS" ] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[ -z "${match_lhs}" ] &&
    [ -n "${_dircolors}" -a -z "${_dircolors%%/*}" ] &&	# exists, and abs path
    match_lhs="$(dircolors --print-database)"
[ "${match_lhs#* TERM ${safe_term}}" != "${match_lhs}" ] && use_color=true

if ${use_color}
then

    # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
    [ -n "${_dircolors}" -a -z "${_dircolors%%/*}" ] && {
	[ -f "${HOME}/.dir_colors" ] && {
	    eval $(dircolors -b "${HOME}/.dir_colors")
	} || [ -f "/etc/DIR_COLORS" ] && {
	    eval $(dircolors -b "/etc/DIR_COLORS")
	}
    }
    alias ls='ls --color=always'
    alias grep='grep --colour=always'
    # Variables to help setting PS1
    _s='\[\033['		# start colour code
    _n="${_s}00;3"		# normal colour code
    _b="${_s}01;3"		# bold colour code
    [ "${TERM}" != "linux" ] &&
	_h="${_s}00;9" ||	# highlighted color code
	_h="${_s}01;3"		# ...  (fall back to bold)
    _e='m\]'			# end colour code
    # Repo status and prompt (#/$) code
    ps1="${_n}6${_e}"'$(_R) '"${_b}4${_e}"'\$ '"${_s}0${_e}"
    [ ${EUID} = 0 ] &&		# prepend hostname, etc.
	ps1="${_h}1${_e}\h ${_h}4${_e}\W${ps1}"	||
	ps1="${_b}2${_e}\u${_n}2${_e}@${_h}2${_e}\h ${_h}4${_e}"'$(_sW)'"${ps1}"
    unset _s _n _b _h _e

else

    # Disable colours for ls, etc.
    alias ls='ls --color=never'
    alias ls='grep --color=never'
    # show root@ when we don't have colours
    [ ${EUID} = 0 ] &&
	ps1='\u@\h \W \$ ' ||
	ps1='\u@\h $(_sW)$(_R) \$ '

fi

PS1="${ps1}"	# Don't export it, as sub-shells may not be bash compatible.
# Try to keep environment pollution down.
unset use_color safe_term _dircolors match_lhs ps1

## End Colourise
######################

###############################
## Put your fun stuff here.
######################

### bash control variables
# prevents adding of useless commands to bash_history
export HISTCONTROL="ignoreboth"
export HISTIGNORE="l:l?:l??:duh:df:dfh:cd:[bf]g:batt:exit:?q"
# PATH completion for cd (need to enter full name - no bash file completion)
export CDPATH=".:~:~/Documents/Imperial/EE4:~/Games:~/Documents:~/Videos:/media:/mnt"

### vi style
set -o vi		# vi like line editing
export EDITOR="vim"
# determine whether we have vim pager scripts.
type 'vimpager' > /dev/null 2>&1 &&
    export VIMPAGER='vimpager'
type 'vimmanpager' > /dev/null 2>&1 &&
    export VIMMANPAGER='vimmanpager'
#export PAGER="${VIMPAGER}"
export MANPAGER="${VIMMANPAGER}"

### Source bash additions, using file caches if they exist to cut down on magic
shopt -qs extglob	# gentoo functions use this extensively
# function definitions
[ -f "${SHM}/function.cache" ] &&
    . "${SHM}/function.cache" || {
    [ "${RC_DIR}" = "${HOME}" ] &&
	. "${HOME}/.function.sh" ||
	. "${RC_DIR}/function.sh"
}
# alias definitions
[ -f "${SHM}/alias.cache" ] &&
    . "${SHM}/alias.cache" || {
    [ "${RC_DIR}" = "${HOME}" ] &&
	. "${HOME}/.alias.sh" ||
	. "${RC_DIR}/alias.sh"
}
# completion definitions
[ -f "${SHM}/complete.cache" ] &&
    . "${SHM}/complete.cache" || {
    [ "${RC_DIR}" = "${HOME}" ] &&
	. "${HOME}/.complete.bash" ||
	. "${RC_DIR}/complete.bash"
}
# Cache the definitions, so we only have to do the checks and magic once. It
# can't be done in individual files as complete, for example, may depend on
# function, but defines more, etc.
[ -d "${SHM}" -a -w "${SHM}" ] && {
    [ -f "${SHM}/complete.cache" ] ||
	complete -p > "${SHM}/complete.cache"
    [ -f "${SHM}/alias.cache" ] ||
	alias -p > "${SHM}/alias.cache"
    [ -f "${SHM}/function.cache" ] ||
	declare -fp > "${SHM}/function.cache"
}

### Add ssh keys to agent if we have keychain (and our handy alias defined).
type 'keychain.add_all' > /dev/null 2>&1 && {
    trap ":" SIGINT	# catch SIGINT to prevent it stopping the sourcing.
    # If not tried before, add keys; then stop future tries:
	[ -f "${SHM}/skip_id_add" ] || keychain.add_all --quiet
	> "${SHM}/skip_id_add"
    trap SIGINT		# remove trap for following execution
}

