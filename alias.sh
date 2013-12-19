#!/bin/sh

###############################
## Shell alias definitions	{{{1

# source aliases		{{{2
alias .rc=". '${RC_D}/${_DOT}${_SH}rc'"
for t in "ps1" "function" "alias" "complete"
do
    if [ -f "${RC_D}/${_DOT}${t}.${_SH}" ]
    then
	eval "alias .${t}=\". '${RC_D}/${_DOT}${t}.${_SH}'\""
    elif [ -f "${RC_D}/${_DOT}${t}.sh" ]
    then
	eval "alias .${t}=\". '${RC_D}/${_DOT}${t}.sh'\""
    fi
done
unset t

# fs navigation aliases		{{{2
alias d='dirs'
alias pd='pushpopd'

# fs viewing aliases		{{{2
${USE_COLOR}					&& {
    alias ls='ls --color=always -x'
    alias tree='tree -C'
}						|| {
    alias ls='ls --color=never -x'
    alias tree='tree -n'
}

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

# vi like stuff aliases		{{{2
type "${VIMPAGER}"					>/dev/null 2>&1 &&
    alias vp="${VIMPAGER}"
type "${VIMMANPAGER}"					>/dev/null 2>&1 &&
    alias vmp="${VIMMANPAGER}"
type 'dash'						>/dev/null 2>&1 &&
    alias dash='dash -V'
alias :q='exit'
type 'vim'						>/dev/null 2>&1 && {
    ! vim -h | sed -ne '/--servername/q1' &&	# only in later versions
	alias vim='vim --servername VIM'	# Needed for LaTeX-Box latexmk
    alias svim='SUDO_EDITOR=vim sudoedit'	# try to stop 'sudo vim'ing!!!
    alias sudovim='SUDO_EDITOR=vim sudoedit'
}

# searching aliases		{{{2
${USE_COLOR}					&&
    alias grep='grep --colour=always'		||
    alias grep='grep --colour=never'
which -i which </dev/null				>/dev/null 2>&1 &&
    alias which='{ alias; declare -f; } | which -i'

# program aliases		{{{2
type 'bc'						>/dev/null 2>&1 &&
    alias bc='bc --quiet'
type 'keychain'						>/dev/null 2>&1 &&
    alias keychain.add_all='keychain 2>/dev/null "${HOME}/.ssh/id"*[^p][^u][^b]'
type 'mplayer'						>/dev/null 2>&1 &&
    alias mplayer.slow='mplayer -vfm ffmpeg -lavdopts fast:skiploopfilter=all'
type 'mplayer2'						>/dev/null 2>&1 &&
    alias mplayer2.slow='mplayer2 --vfm=ffmpeg --lavdopts=fast:skiploopfilter=all'
type 'opera'						>/dev/null 2>&1 &&
    alias opera='opera -nomail'
type 'octave'						>/dev/null 2>&1 &&
    alias octave='octave --silent'
type 'xdg-open'						>/dev/null 2>&1 &&
    alias xo='xdg-open >/dev/null 2>&1'
[ -f "${HOME}/Documents/Code/t/t.py" ] && {
    alias t="${HOME}/Documents/Code/t/t.py"
    eval "$(alias t)' --task-dir \"\${HOME}/Documents/tasks\" --list tasks'"
    alias f="t -f"
    alias r="t -r"
    alias td="t --done"
    alias b="${HOME}/Documents/Code/t/t.py --task-dir . --list bugs"
    alias deps="${HOME}/Documents/Code/t/t.py"
    eval "$(alias deps)' --task-dir \"\$HOME/Documents/tasks\" --list deps'"
}


# gentoo aliases		{{{2
type 'equery'						>/dev/null 2>&1 && {
    ${USE_COLOR}				&&
	alias equery='equery --no-pipe'		||
	alias equery='equery --no-color --no-pipe'
    alias elist='equery list --installed --portage-tree --overlay-tree'
    alias euses='equery uses'
    alias ehas='equery hasuse'
    alias egraph='equery depgraph'
    alias edepend='equery depends'
}
type 'eix'						>/dev/null 2>&1 && {
    ${USE_COLOR}				&&
	alias eix='eix --force-color'		||
	alias eix='eix --nocolor'
    alias eex='eix --exact'
    alias eie='eix --installed --exact'
    alias eicat='eix --installed --category'
    alias eidep='eix --installed --deps'
    alias eihas='eix --installed --use'
    alias eiwith='eix --installed-with-use'
    alias eiwithout='eix --installed-without-use'
    alias eiwo='eix --installed-without-use'
    alias eover='eix --in-overlay'
    alias eiover='eix --installed-from-overlay'
}

# git aliases			{{{2
type 'git'						>/dev/null 2>&1 && {
    alias gs='git status'
    alias gl='git log'
    alias gch='git checkout'
    alias gca='git commit -a'
    alias gb='git branch'
    alias gvn='git svn'
}

# mercurial aliases		{{{2
type 'hg'						>/dev/null 2>&1 && {
    alias hs='hg status'
    alias hl='hg log'
    alias hc='hg commit'
}

# game aliases			{{{2
type 'VisualBoyAdvance'					>/dev/null 2>&1 && {
    alias VisualBoyAdvance='VisualBoyAdvance --config="${HOME}/.vba/VisualBoyAdvance.cfg"'
    alias VBA='VisualBoyAdvance'
}
for f in "${HOME}/Games/"*/*.exe
do
    if [ "${f}" != "${HOME}/Games/*/*.exe" ]
    then
	[ -x "${f}" -a "${f%orig*.exe}" = "${f}" ]	&& {
	    name="$(echo "${f}" | sed -e 's:^.*/\(.*\)\.exe$:\1:; s:\s\+:_:g')"
	    # Don't want to overwrite a system command.
	    type "wine.${name}" >/dev/null 2>&1 ||
		eval "alias wine.${name}='wine \"${f}\"'"
	}
    else
	break
    fi
done
unset f name

# misc aliases			{{{2
type 'luvcview'						>/dev/null 2>&1 &&
    alias luvcview.n220='luvcview -f yuv -i 30'
type 'msp430-gcc' 'mspdebug'				>/dev/null 2>&1 &&
    alias prog.msp430='make; echo -e "\n###########\n"; mspdebug -q rf2500 "prog main.elf"'
type 'sudo' >/dev/null 2>&1 &&
    alias bkgnd='sudo >/dev/null 2>&1 -bnu "${USER}" '

type yum >/dev/null 2>&1 &&
    alias yum='yum --nogpgcheck'

alias dd_usb='dd oflag=sync bs=1M'

type ant >/dev/null 2>&1 && {
    alias ant.local_lib='ant $(find ../*/dist -name *.jar | sed "s:.*:-lib &:")'
    alias vant="ssh test@vm ant -f '~/${PWD#$HOME}/build.xml'"  # TODO: generic
}

type rpmbuild > /dev/null 2>&1 &&
    alias build_rpm='CLASSPATH="$CLASSPATH:$(echo $(find ${PWD}/../*/dist -name *.jar) | sed "s/\s\+/:/g")" rpmbuild --nodeps --define "_topdir ${PWD}/build/rpmbuild" --rebuild build/rpmbuild/SRPMS/*.src.rpm'

alias test_cp='echo "$CLASSPATH:$(echo $(find ${PWD}/../*/dist -name *.jar) | sed "s/\s\+/:/g")"'

type python > /dev/null 2>&1 &&
    alias pycalc='python -i -c "from __future__ import division; from math import *; from cmath import *"'

type mysql > /dev/null 2>&1 &&
    alias mysql='mysql -u root'

type java > /dev/null 2>&1 && {
    alias java_jconsole='java -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false'
    alias java_debug='java -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n'
}

type rlwrap >/dev/null 2>&1 && {
    type bsh-interpreter >/dev/null 2>&1 &&
        alias bsh='rlwrap -w10 -O"bsh % " -pcyan -rc bsh-interpreter'

    type nc >/dev/null 2>&1 &&
        alias ncrl='rlwrap nc'

    type snc >/dev/null 2>&1 &&
        alias sncrl="WRAPPER=\${WRAPPER:-rlwrap} snc"
}

## End aliases		}}}1
######################

