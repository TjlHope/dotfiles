#!/bin/bash

###############################
## Definition of bash aliases

# check we have the special _which function:
declare -f _which > /dev/null ||
    _which () { false ; }

# source aliases
alias .rc=". ${RC_DIR}/bashrc"
alias .ps1=". ${RC_DIR}/ps1.bash"
alias .function=". ${RC_DIR}/function.bash"
alias .alias=". ${RC_DIR}/alias.bash"

# fs viewing aliases
alias l='ls'
alias lpg='ls_pager'
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
[ -n "${VIMPAGER}" ] &&
    alias vp="${VIMPAGER}"
[ -n "${VIMMANPAGER}" ] &&
    alias vmp="${VIMMANPAGER}"
_which 'dash' &&
    alias dash='dash -V'
alias :q='exit'

# program aliases
_which 'bc' &&
    alias bc='bc --quiet'
_which "keychain" &&
    alias keychain.add_all='keychain "${HOME}/.ssh/id"*[^p][^u][^b]'
_which 'opera' &&
    alias opera='opera -nomail'
_which 'octave' &&
    alias octave='octave --silent'
_which 'xdg-open' &&
    alias xo='xdg-open'

# gentoo aliases
_which 'equery' && {
    alias elist='equery list --installed --portage-tree --overlay-tree'
    alias euses='equery uses'
    alias egraph='equery depgraph'
    alias edepend='equery depends'
}

# git aliases
_which 'git' && {
    alias gs='git status'
    alias gl='git log'
    alias gca='git commit -a'
}

# searching aliases
alias which='(alias; declare -f) | which -i'

# game aliases
_which 'VisualBoyAdvance' &&
    alias VisualBoyAdvance='VisualBoyAdvance --config="${HOME}/.VBArc"'
for f in "${HOME}/Games/"*/*.exe
do
    if [ "${f}" != "${HOME}/Games/*/*.exe" ]
    then
	[ -x "${f}" -a "${f%orig*.exe}" = "${f}" ] && {
	    name="$(echo "${f}" | sed -e 's:^.*/\(.*\)\.exe$:\1:; s:\s\+:_:g')"
	    # Don't want to overwrite a system command (note use of previously
	    # defined which alias).
	    which "wine.${name}" > /dev/null 2>&1 ||
		eval "alias wine.${name}='wine ${f}'"
	}
    else
	break
    fi
done
unset f name

# misc aliases
_which 'luvcview' &&
    alias luvcview.n220='luvcview -f yuv -i 30'
_which 'msp430-gcc' 'mspdebug' &&
    alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'

## End aliases
######################

