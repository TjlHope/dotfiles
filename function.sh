#!/bin/sh

###############################
## Definition of shell functions

cd() {
    # Function allowing 'cd' to interpret N '.'s to mean the (N-1)th parent 
    # directory; i.e. '..' is up to parent, '...' is grandparent, '....' is 
    # great-grandparent, etc. Complement to '_cdd' completion function.
    local d="$(echo "$1" | \
	sed -e ':sub
	    s:^\(.*/\)\?\.\.\.:\1../..:g
	    t sub'
	)"
    builtin cd ${d:+"$d"}	# if empty, no quoting, else quote
}

pushpopd() {
    # Combine pushd and popd, empty dir, or '-' is a pop, otherwise push.
    # The thought is that popd will rarely use arguments, and pushd nearly 
    # always has a path, and so they can be easily combined in this way.
    if [ -z "$1" -o "$1" = '-' ]
    then
	popd
    else
	pushd "$@"
    fi
}

pgr() {
    [ -n "$*" ] && [ "$1" != '-' ] &&
	"$@" | ${PAGER:-less} ||
	${PAGER:-less} "$@"
}

ls_pgr() {
    ls "$@" | ${PAGER:-less}
}

! type 'vimpager' >/dev/null 2>&1 &&		# comment to disable check
type 'vim' >/dev/null 2>&1 &&	#false &&	# comment 'false &&' to enable
    vimpager() {	# function edited from vimpager script
	local c=''
	[ -t 1 ] || c=cat
	${c:-vim --cmd 'let no_plugin_maps=1' -c 'runtime! macros/less.vim'} \
	    "${@:--}"
    }

date_time() {
    date "+$1%F_%X$2"
}

quote_url() {
    python -c "from urllib2 import quote; print(quote('$*'))"
}

unquote_url() {
    python -c "from urllib2 import unquote; print(unquote('$*'))"
}

send-message() {
    local host="$1" head="$2"; shift 2
    ssh "$host" sh <<- EOF
	export DISPLAY=:0.0
	export XAUTHORITY=/tmp/.gdm[^_]*
	export USER=\$(users | cut -d\  -f1)
	su \$USER -c 'notify-send "$head" "$@"'
	EOF
                    # TODO: properly quote ^this
}

fork() {
    local revert_setsid	        # local always exits with 0
    revert_setsid="$(alias setsid 2>/dev/null)" ||
	revert_setsid="unalias setsid"
    alias setsid='setsid '	# expand any aliases we pass in
    (setsid "$@" >/dev/null 2>&1 &)
    eval "$revert_setsid"
}

kill_after_timeout() {
    local wait_pid=$! timeout=$1 waiter_pid= ret=0; shift
    [ $# -gt 0 ] && {	# we've been passed a command to run
	"$@"			# so run it
	wait_pid=$!
    }		# otherwise assume it's been run just before us
    (   trap exit HUP
        sleep $timeout
        kill $wait_pid 2>/dev/null
    ) & waiter_pid=$!
    wait $wait_pid; ret=$?
    kill -HUP $waiter_pid 2>/dev/null
    return $ret
}

pipe_wireshark() {
    local host="$1"; shift
    ssh "$host" "tcpdump -U -n -w - -s 65535 -i any ${*:-not port 22}" |
	wireshark -k -i -
}

java_memdump() {
    jmap -dump:live,format=b,file="${2-$1.dump}" "$1"
}

twinkle() {
    local host="${1:-vm}"; shift
    ssh >/dev/null 2>&1 -f "$host" twinkle "$@"
}

my_ip() {
    # Output the first external ip of this machine
    # In case it's run under sudo with a crap setup that mangles PATH:
    local ip="$(command -v ip || { [ -x /sbin/ip ] && echo /sbin/ip; })"
    "$ip" 2>/dev/null -4 -o addr show | \
        sed -ne "
            /\<scope\s\+global\>/ {
                s/^.*\<inet\s\+\([0-9\.]\+\)\/[0-9]\+\>.*$/\1/p
                $([ "$1" = -a] || echo 'q')
            }"
}

mysql_grant() {
    ssh "$1" mysql -e \
        "\"grant all privileges on *.* to 'root'@'${2:-$(my_ip)}' with grant option\""
}

fix_for_old_terminfo() {
    ssh "$1" cat '>>' '~/.bashrc' <<- EOF
	case "\$TERM" in
	    screen-256color)    export TERM="screen";;
	    *-256color)         export TERM="\${TERM%-256color}-color";;
	esac
	EOF
}

ssh_set_up() {
    while [ $# -gt 0 ]
    do
        sudo ssh-copy-id -i "/root/.ssh/id_rsa.pub" "$1"
        sudo ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "$1"
        fix_for_old_terminfo "$1"
        shift
    done
}

pysoap() {
    ipython -i -c "from suds.client import Client; client = Client('https://$1/${2:-$PYSOAP_DEF}'); soap = client.service; print(client)"
}

snc() {
    local host="$1"; shift
    $WRAPPER ssh "$host" nc localhost "$@"
}

type rpm >/dev/null 2>&1 &&
rpm_list_keys() {
    local cmd="echo" key
    case "$1" in
        -a|-v|--all|--verbose)  cmd="rpm -qi";;
    esac
    for key in $(rpm -qa 'gpg-pubkey*')
    do
        $cmd "$key"
    done
}

## End functions
######################

