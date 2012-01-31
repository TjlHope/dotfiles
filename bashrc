# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Prevent tests for commands getting aliases/functions when re-sourcing.
unalias which 2> /dev/null

###############################
## Fix vte screwing TERM var

if [ "${TERM%color}" = "${TERM}" ]
then
    case "$COLORTERM" in
	"Terminal")
	    export TERM="$TERM-256color"
	    ;;
	"")
	    # not a color term!
	    ;;
	*)
	    export TERM="$TERM-color"
	    ;;
    esac
fi

## End vte fix
######################

###############################
## Colourise
## pulled from Gentoo's /etc/bashrc to allow changing PS1 with colour

# Get PS1 functions.
. ~/.dotfiles/ps1.bash

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
    alias ls='ls --color=always'
    alias grep='grep --colour=auto'
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
	ps1="${_b}2${_e}\u${_n}2${_e}@${_h}2${_e}\h ${_h}4${_e}"'$(_W)'"${ps1}"
    unset _s _n _b _h _e
else
    # Disable colors for ls, etc.
    alias ls='ls --color=never'
    alias ls='grep --color=never'
    # show root@ when we don't have colors
    [[ ${EUID} == 0 ]] &&
	ps1='\u@\h \W \$ ' ||
	ps1='\u@\h $(_W)$(_R) \$ '
fi

export PS1="${ps1}"
# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs ps1

## End Colourise
######################

###############################
## Put your fun stuff here.
######################

# prevents adding of useless commands to bash_history
export HISTCONTROL="ignoreboth"
export HISTIGNORE="ls:lh:ll:la:lA:lal:lAl:lgd:lagd:duh:df:dfh:cd:[bf]g:batt:exit:?q"
# PATH completion for cd (need to enter full name - no bash file completion)
export CDPATH=".:~:~/Documents/Imperial/EE4:~/Games:~/Documents:~/Videos:/media:/mnt"

# vi like line editing
set -o vi
# determine whether we have vim pager scripts.
which 'vimpager' 2>&1 > /dev/null &&
    export VIMPAGER='vimpager' ||
    export VIMPAGER="${PAGER:-less}"
which 'vimmanpager' 2>&1 > /dev/null &&
    export VIMMANPAGER='vimmanpager' ||
    export VIMMANPAGER="${MANPAGER:-less}"
# use vim as editor and pager
export EDITOR="vim"
#export PAGER="${VIMPAGER}"
export MANPAGER="${VIMMANPAGER}"

# fs viewing aliases
alias l='ls'
lpg () {
    [ -n "${PAGER}" ] &&
	ls ${@} | ${PAGER} ||
	ls ${@} | less
}
alias ll='ls -l'
alias la='ls -A'
alias lal='ls -Al'
alias lgd='ls --group-directories-first'
alias lagd='ls -A --group-directories-first'
alias lh='ls -sh'
alias llh='ls -lh'
alias lah='ls -Ash'
alias lalh='ls -Alh'
alias duh='du -sh'
alias dfh='df -h'

# vi like stuff aliases
alias vp="${VIMPAGER}"
alias vmp="${VIMMANPAGER}"
alias dash='dash -V'
alias :q='exit'

# program aliases
alias bc='bc --quiet'
#alias ipython='PAGER="$MANPAGER" ipython'
alias keychain.add_all='keychain $(ls "${HOME}/.ssh/" | sed -ne "/id.*[^\(.pub\)]$/p")'
alias opera='opera -nomail'
#alias pydoc='PAGER="$MANPAGER" pydoc'
#alias python='PAGER="$MANPAGER" python'
#alias python2='PAGER="$MANPAGER" python2'
#alias python3='PAGER="$MANPAGER" python3'
alias octave='octave --silent'
alias xo='xdg-open'

# gentoo aliases
which 'equery' 2>&1 > /dev/null && {
    alias elist='equery list --installed --portage-tree --overlay-tree'
    alias euses='equery uses'
    alias egraph='equery depgraph'
    alias edepend='equery depends'
}

# git aliases
alias gs='git status'
alias gl='git log'
alias gca='git commit -a'

# game aliases
alias DSLoA='wine "~/Games/Dungeon Siege/DSLOA.exe"'
alias VisualBoyAdvance='VisualBoyAdvance --config="/home/tom/.VBArc"'

# misc aliases
alias .rc='. ${HOME}/.bashrc'
alias luvcview.n220='luvcview -f yuv -i 30'
alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'

# searching aliases
alias which='(alias; declare -f) | which -i'

### enable bash completion
[ -f /etc/profile.d/bash-completion.sh ] &&
    . /etc/profile.d/bash-completion.sh
[ -f /etc/profile.d/bash_completion.sh ] &&
    . /etc/profile.d/bash_completion.sh
## and for sudo
#complete -cf sudo
## and for apvlv
complete -o dirnames -fX '!*.[Pp][Dd][Ff]' apvlv 
## and for VBA, DeSmuME
complete -o dirnames -fX '!*.[Gg][Bb]*' VisualBoyAdvance 
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume 
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume-glade
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume-cli 

### Add ssh keys to agent, use ssh-add as keychain already set up from .profile
trap ":" SIGINT		# catch SIGINT to prevent it stopping the sourcing.
# If not tried before, add keys; then stop future tries:
[ -f "${SHM}/pass_id_add" ] || keychain.add_all --quiet
touch "${SHM}/pass_id_add"
trap SIGINT		# remove trap for following execution

