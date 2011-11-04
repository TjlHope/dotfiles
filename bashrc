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
## Put your fun stuff here.
######################

# Set PS1
. ~/.dotfiles/ps1.sh

# prevents adding of useless commands to bash_history
export HISTCONTROL="ignoreboth"
export HISTIGNORE="ls:lh:ll:la:lA:lal:lAl:lgd:lagd:duh:df:dfh:cd:[bf]g:batt:exit:?q"
# PATH completion for cd (need to enter full name - no bash file completion)
export CDPATH=".:~:~/Documents/Imperial/EE4:~/Games:~/Documents:~/Videos:/media:/mnt"

# vi like line editing
set -o vi
# use vim as editor and pager
export EDITOR="vim"
export PAGER="/usr/bin/vimpager"
export MANPAGER="/usr/bin/vimmanpager"

# fs viewing aliases
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
alias vp='vimpager'
alias vmp='vimmanpager'
alias dash='dash -V'
alias :q='exit'

# searching aliases
alias which='(alias; declare -f) | which -i'

# program aliases
alias bc='bc --quiet'
alias ipython='PAGER="$MANPAGER" ipython'
alias opera='opera -nomail'
alias pydoc='PAGER="$MANPAGER" pydoc'
alias python='PAGER="$MANPAGER" python'
alias python2='PAGER="$MANPAGER" python2'
alias python3='PAGER="$MANPAGER" python3'
alias octave='octave --silent'
alias xo='xdg-open'

# gentoo aliases
alias elist='equery list --installed --portage-tree --overlay-tree'

# git aliases
alias gs='git status'
alias gl='git log'
alias gca='git commit -a'

# game aliases
alias DSLoA='wine ~/Games/Dungeon\ Siege/DSLOA.exe'
alias VisualBoyAdvance='VisualBoyAdvance --config="/home/tom/.VBArc"'

# misc aliases
alias .rc='. ~/.bashrc'
alias luvcview.i='luvcview -f yuv -i 30'
alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'

### enable bash completion
[ -f /etc/profile.d/bash-completion.sh ] &&
    . /etc/profile.d/bash-completion.sh
## and for sudo
#complete -cf sudo
## and for apvlv
complete -o dirnames -fX '!*.[Pp][Dd][Ff]' apvlv 
## and for VBA, DeSmuME
complete -o dirnames -fX '!*.[Gg][Bb]*' VisualBoyAdvance 
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume 
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume-glade
complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume-cli 

# Add ssh keys to agent
/usr/bin/keychain -q $(ls "${HOME}/.ssh/" | sed -ne '/id.*[^\(.pub\)]$/p')

