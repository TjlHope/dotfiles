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
## pulled from /etc/bashrc to allow changed PS1 and color control

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
	PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    # set color terminal
    #[[ "$XAUTHORITY" ]] && export TERM="xterm-256color"
else
    # show root@ when we don't have colors
    [[ ${EUID} == 0 ]] &&
	PS1='\u@\h \W \$ ' ||
	PS1='\u@\h \w \$ '
    # set non-color terminal
    #[[ "$XAUTHORITY" ]] && export TERM="xterm"
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

## end color control
######################

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

## end color control
######################

###############################
## Put your fun stuff here.
######################

# set user locale
export LANG="en_GB.utf8"

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
alias pydoc='PAGER="$MANPAGER" pydoc'
alias python='PAGER="$MANPAGER" python'
alias python2='PAGER="$MANPAGER" python2'
alias python3='PAGER="$MANPAGER" python3'
alias octave='octave --silent'
alias dash='dash -V'
alias :q='exit'

# searching aliases
alias lgrep='grep -A2 -B2'
alias rgrep='grep ./ -Re'
alias lpgrep='pgrep -l'
alias which='(alias; declare -f) | which -i'

# gentoo aliases
alias elist='equery list --installed --portage-tree --overlay-tree'

# git aliases
alias gs='git status'
alias gca='git commit -a'

# game aliases
alias DSLoA='wine ~/Games/Dungeon\ Siege/DSLOA.exe'
alias VisualBoyAdvance='VisualBoyAdvance --config="/home/tom/.VBArc"'

# misc aliases
alias luvcview.i='luvcview -f yuv -i 30'
#alias umount.media='for x in /media/[^c][^d]* ; do pumount "$x" ; done'
#alias umount.cd='pumount /media/cdrom/'
alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'
alias opera='opera -nomail'

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

### python vars
pythonpath="$HOME/Documents/Code/python"
[ -n "${PYTHONPATH}" ] &&
    export PYTHONPATH="${PYTHONPATH%${pythonpath}}:${pythonpath}" ||
    export PYTHONPATH=${pythonpath}
unset pythonpath	# keep env pollution down

### gnuplot vars
GNUPLOT_FONTPATH+=":/usr/share/fonts/!"
GDFONTPATH+=":/usr/share/fonts/!"
GNUPLOT_DEFAULT_GDFONT="veranda"

### gnash / lightspark
export GNASH_PLUGIN_DESCRIPTION="Shockwave Flash 10.1 r999"

#export WINEDEBUG="-all"
export INTEL_BATCH=1

# Add ssh keys to agent
/usr/bin/keychain -q $(ls "${HOME}/.ssh/" | sed -ne '/id.*[^\(.pub\)]$/p')

