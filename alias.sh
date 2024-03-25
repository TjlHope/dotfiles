#!/bin/sh

###############################
## Shell alias definitions	{{{1

# source aliases		{{{2
# shellcheck disable=2139
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

alias cdp='cd $(pwd)'

# fs viewing aliases		{{{2
if "${USE_COLOR:-false}"
then	# TODO finish _term_detect() and use that instead
    alias ls='ls --color=always -x'
    alias tree='tree -C'
    alias dmesg='dmesg --color=always'
fi

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
_have "$VIMPAGER" && alias vp="${VIMPAGER}"
_have "$VIMMANPAGER" && alias vmp="${VIMMANPAGER}"
_have 'dash' && alias dash='dash -V'
alias :q='exit'
_have 'vim' && {
    vim -h | grep -q '[-]-servername' &&	# only in later versions
	alias vim='vim --servername VIM'	# Needed for LaTeX-Box latexmk
    alias svim='SUDO_EDITOR=vim sudoedit'	# try to stop 'sudo vim'ing!!!
    alias sudovim='SUDO_EDITOR=vim sudoedit'
}

# searching aliases		{{{2
if "${USE_COLOR:-false}"
then alias grep='grep --colour=always'
else alias grep='grep --colour=never'
fi
# shellcheck disable=2230 # check if which supports -i
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
type 'mpv'						>/dev/null 2>&1 &&
    alias mpv.slow='mpv --vd-lavc-fast --vd-lavc-skiploopfilter=all'
type 'opera'						>/dev/null 2>&1 &&
    alias opera='opera -nomail'
type 'octave'						>/dev/null 2>&1 &&
    alias octave='octave --silent'
type 'xdg-open'						>/dev/null 2>&1 && {
    alias xo='xdg-open >/dev/null 2>&1'
    type 'open' >/dev/null 2>&1 || alias open='xdg-open >/dev/null 2>&1'
}
type 'sshfs'						>/dev/null 2>&1 &&
    alias sshfs='sshfs -o reconnect' # doesn't seemt to work: ' -o workaround=all'
if [ -x "${HOME}/Documents/Code/t/t.py" ]
then
    # shellcheck disable=2116
    alias t="$(echo \
	"\"${HOME}/Documents/Code/t/t.py\"" \
	"--task-dir \"${HOME}/Documents/tasks\" --list tasks" \
    )"
    alias tf="t -f"; #alias tr="t -r"	# tr is a cmd
    alias tarchive="t --list archive"

    alias b="\"${HOME}/Documents/Code/t/t.py\" --task-dir . --list bugs"
    alias bf="b -f"; #alias br="b -r"
fi
_have skopeo && alias docker-skopeo="skopeo"	# I keep forgetting the name
_have docker && {
    # shellcheck disable=2116
    alias docker-pids="$(echo \
	"docker inspect \$(docker ps --format '{{.ID}}') --format" \
	"'{{.Id|printf \"%.10s\"}} {{.State.Pid|printf \"%6s\"}} {{.Name}}'" \
    )"
    alias docker-pid="docker inspect --format '{{.State.Pid}}'"
}


# gentoo aliases		{{{2
type 'equery'						>/dev/null 2>&1 && {
    if "${USE_COLOR:-false}"
    then alias equery='equery --no-pipe'
    else alias equery='equery --no-color --no-pipe'
    fi
    alias elist='equery list --installed --portage-tree --overlay-tree'
    alias euses='equery uses'
    alias ehas='equery hasuse'
    alias egraph='equery depgraph'
    alias edepend='equery depends'
}
type 'eix'						>/dev/null 2>&1 && {
    if "${USE_COLOR:-false}"
    then alias eix='eix --force-color'
    else alias eix='eix --nocolor'
    fi
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
    alias g='git'
    alias gs='git status'       # because gs is also ghostscript
}

# mercurial aliases		{{{2
type 'hg'						>/dev/null 2>&1 && {
    alias hs='hg status'
    alias hl='hg log'
    alias hc='hg commit'
}

# CVS aliases			{{{2
type 'cvs'						>/dev/null 2>&1 && {
    alias cs='cvs -nq update'
    alias cl='pgr cvs log'
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
	[ -x "${f}" ] && [ "${f%orig*.exe}" = "${f}" ]	&& {
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

alias dd.usb='dd oflag=sync bs=1M'

alias lsblk.label='lsblk -o name,label,uuid,size,ro,type,mountpoint'

alias toggle_echo="stty \$(stty -a | sed -ne '
        s/\(.*\s\)\?-echo\(\s.*\)\?/echo/p; t; s/\(.*\s\)\?echo\(\s.*\)\?/-echo/p'
    )"

type ant >/dev/null 2>&1 && {
    alias ant.local_lib='ant $(find ../*/dist -name *.jar | sed "s:.*:-lib &:")'
    alias ant.test_vm='ssh test@vm ant -f "~/${PWD#$HOME}/build.xml"'
    alias dita-ant.test_vm='ssh test@vm /usr/share/dita-ot-1.8/dita-ant -f "~/${PWD#$HOME}/build.xml"'
}

alias vm='IWD="${PWD#$HOME/}" ssh test@vm'
alias vm7='IWD="${PWD#$HOME/}" ssh test@tosp-a'

type rpmbuild > /dev/null 2>&1 &&
    alias build_rpm='CLASSPATH="$CLASSPATH:$(echo $(find ${PWD}/../*/dist -name *.jar) | sed "s/\s\+/:/g")" rpmbuild --nodeps --define "_topdir ${PWD}/build/rpmbuild" --rebuild build/rpmbuild/SRPMS/*.src.rpm'

alias test_cp='echo "$CLASSPATH:$(echo $(find ${PWD}/../*/dist -name *.jar) | sed "s/\s\+/:/g")"'

type mysql > /dev/null 2>&1 &&
    alias mysql='mysql -u root'

type java > /dev/null 2>&1 && {
    alias java_jconsole='java -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false'
    alias java_debug='java -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n'
    alias java_flags='java -XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version'
}

_have rlwrap && {
    _have bsh-interpreter && alias bsh='rlwrap -rc bsh-interpreter'

    _have nc && alias ncrl='rlwrap nc'

    _have snc && alias sncrl="WRAPPER=\${WRAPPER:-rlwrap} snc"

    _have perl && alias iperl='rlwrap perl -de1'
}

type python > /dev/null 2>&1 && {       # python goodies
    alias pycalc='python -i -c "from __future__ import division; from math import *; from cmath import *"'
    #alias pycalc="PYTHONSTARTUP='${RC_D}/${_DOT}calc.py' python"

    # answer for
    # http://stackoverflow.com/questions/356578/how-to-output-mysql-query-results-in-csv-format
    type t2csv >/dev/null 2>&1 || {
        alias t2csv="python -c \"import sys as s,csv as c;"
        eval "$(alias t2csv)'r=c.DictReader(s.stdin,dialect=c.excel_tab);'"
        eval "$(alias t2csv)'w=c.DictWriter(s.stdout,r.fieldnames,'"
        eval "$(alias t2csv)'dialect=c.excel,quoting=c.QUOTE_MINIMAL);'"
        eval "$(alias t2csv)'w.writeheader();w.writerows(r)\"'"
    }

    type gethostbyaddr >/dev/null 2>&1 || {
        alias gethostbyaddr="python -c \"import sys as s, socket as k;"
        eval "$(alias gethostbyaddr)'print(k.gethostbyaddr(s.argv[1]))\"'"
    }

    type gethostbyname >/dev/null 2>&1 || {
        alias gethostbyname="python -c \"import sys as s, socket as k;"
        eval "$(alias gethostbyname)'print(k.gethostbyname(s.argv[1]))\"'"
    }

    type a2b > /dev/null 2>&1 || {
        alias a2b="python2 -c \"from sys import argv as a, stdin as i;"
        eval "$(alias a2b)'from binascii import a2b_hex as a2b;'"
        eval "$(alias a2b)'print(a2b(a[1] if len(a)>1 else i.read().strip()))\"'"
    }
    type b2a > /dev/null 2>&1 || {
        alias b2a="python2 -c \"from sys import argv as a, stdin as i;"
        eval "$(alias b2a)'from binascii import b2a_hex as b2a;'"
        eval "$(alias b2a)'print(b2a(a[1] if len(a)>1 else i.read().strip()))\"'"
    }

    type paste_image >/dev/null 2>&1 || {
        alias paste_image="python -c \"import sys as s, gtk as g;"
        eval "$(alias paste_image)'c=g.clipboard_get(); i=c.wait_for_image();'"
        eval "$(alias paste_image)'i.save(s.argv[1], \\\"png\\\");\"'"
    }
}

_have cacaview && alias cacaview='env -uDISPLAY cacaview'

_have watch_for &&
    alias watch_mem_cache="watch_for /proc/meminfo '^(Dirty|Writeback):'"

_have mvn && {
    alias mvn="mvn -D'https.protocols=TLSv1,TLSv1.1,TLSv1.2'"
}

_have tmux-xpanes && {
    alias tmux-xssh="tmux-xpanes --ssh -ss -lev"
}

alias flush_dnsmasq='sudo killall -HUP dnsmasq'

alias backup.pt='sfdisk --dump'
alias backup.vg='vgcfgbackup'	# note: dumps to files under /etc/lvm/backup

type aws >/dev/null 2>&1 && {
    : #alias aws-dev='aws --profile contact-gb-dev-s1'
}

## End aliases		}}}1
######################

