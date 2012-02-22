#!/bin/sh

###############################
## Definition of shell aliases

# source aliases
alias .rc=". ${RC_DIR}/${_dot}${_SH}rc"
for t in "ps1" "function" "alias" "complete"
do
    if [ -f "${RC_DIR}/${_dot}${t}.${_SH}" ]; then
	eval "alias .${t}='. ${RC_DIR}/${_dot}${t}.${_SH}'"
    elif [ -f "${RC_DIR}/${_dot}${t}.sh" ]; then
	eval "alias .${t}='. ${RC_DIR}/${_dot}${t}.sh'"
    fi
done
unset t

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
type "${VIMPAGER}" > /dev/null 2>&1 &&
    alias vp="${VIMPAGER}"
type "${VIMMANPAGER}" > /dev/null 2>&1 &&
    alias vmp="${VIMMANPAGER}"
type 'dash' > /dev/null 2>&1 &&
    alias dash='dash -V'
alias :q='exit'

# program aliases
type 'bc' > /dev/null 2>&1 &&
    alias bc='bc --quiet'
type 'keychain' > /dev/null 2>&1 &&
    alias keychain.add_all='keychain "${HOME}/.ssh/id"*[^p][^u][^b]'
type 'opera' > /dev/null 2>&1 &&
    alias opera='opera -nomail'
type 'octave' > /dev/null 2>&1 &&
    alias octave='octave --silent'
type 'xdg-open' > /dev/null 2>&1 &&
    alias xo='xdg-open'

# gentoo aliases
type 'equery' > /dev/null 2>&1 && {
    alias equery='equery --no-pipe'
    alias elist='equery list --installed --portage-tree --overlay-tree'
    alias euses='equery uses'
    alias egraph='equery depgraph'
    alias edepend='equery depends'
}

# git aliases
type 'git' > /dev/null 2>&1 && {
    alias gs='git status'
    alias gl='git log'
    alias gca='git commit -a'
}

# searching aliases
alias which='{ alias; declare -f; } | which -i'

# game aliases
type 'VisualBoyAdvance' > /dev/null 2>&1 &&
    alias VisualBoyAdvance='VisualBoyAdvance --config="${HOME}/.VBArc"'
for f in "${HOME}/Games/"*/*.exe
do
    if [ "${f}" != "${HOME}/Games/*/*.exe" ]
    then
	[ -x "${f}" -a "${f%orig*.exe}" = "${f}" ] && {
	    name="$(echo "${f}" | sed -e 's:^.*/\(.*\)\.exe$:\1:; s:\s\+:_:g')"
	    # Don't want to overwrite a system command.
	    type "wine.${name}" > /dev/null 2>&1 ||
		eval "alias wine.${name}='wine \"${f}\"'"
	}
    else
	break
    fi
done
unset f name

# misc aliases
type 'luvcview' > /dev/null 2>&1 &&
    alias luvcview.n220='luvcview -f yuv -i 30'
type 'msp430-gcc' 'mspdebug' > /dev/null 2>&1 &&
    alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'

## End aliases
######################

