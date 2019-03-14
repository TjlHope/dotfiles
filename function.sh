#!/bin/sh
# shellcheck disable=2039,2120

###############################
## Definition of shell functions

cd() {
    # Function allowing 'cd' to interpret N '.'s to mean the (N-1)th parent 
    # directory; i.e. '..' is up to parent, '...' is grandparent, '....' is 
    # great-grandparent, etc. Complement to '_cdd' completion function.
    local d="" >/dev/null 2>&1 || :
    d="$(echo "$1" | sed -e ':sub
	    s:^\(.*/\)\?\.\.\.:\1../..:g
	    t sub
	    ')"
    command cd ${d:+"$d"}	# if empty, no quoting, else quote
}

pushpopd() {
    # Combine pushd and popd, empty dir, or '-' is a pop, otherwise push.
    # The thought is that popd will rarely use arguments, and pushd nearly 
    # always has a path, and so they can be easily combined in this way.
    if [ -z "$1" ] || [ "$1" = '-' ]
    then
	popd || return
    else
	pushd "$@" || return
    fi
}

pgr() {
    if [ -n "$*" ] && [ "$1" != '-' ]
    then
	"$@" | ${PAGER:-less}
    else
	${PAGER:-less} "$@"
    fi
}

ls_pgr() {
    # shellcheck disable=2012
    ls "$@" | ${PAGER:-less}
}

! type 'vimpager' >/dev/null 2>&1 &&		# comment to disable check
type 'vim' >/dev/null 2>&1 &&	#false &&	# comment 'false &&' to enable
    vimpager() {	# function edited from vimpager script
	local c=''
	[ -t 1 ] || c="cat"
	${c:-vim --cmd 'let no_plugin_maps=1' -c 'runtime! macros/less.vim'} \
	    "${@:--}"
    }

date_time() {
    date "+$1%F_%X$2"
}

quote_url() {
    python2 \
	-c 'import urllib2 as u,sys;print(u.quote(" ".join(sys.argv[1:])))' \
	"$@"
}

unquote_url() {
    python2 \
	-c 'import urllib2 as u,sys;print(u.unquote(" ".join(sys.argv[1:])))' \
	"$@"
}

fifo_size() {
    [ $# -lt 1 ] || [ "$1" = -h ] && {
	echo "Usage: fifo_size <path/to/fifo>"
	return 0
    }
    local fifo="$1"
    [ -p "$fifo" ] || {
	echo "Not a FIFO (named pipe): $fifo" >&2
	return 1
    }
    python <<-_EOF
	from fcntl import ioctl
	from struct import unpack
	from termios import FIONREAD
	from threading import Thread

	# we need to also open the fifo as a writer, as if there's no writer
	# the read open will block indefinitely
	fifo = "$fifo"
	writer = None
	def open_writer(f):
	    global writer
	    writer = open(f, 'wb')
	thread = Thread(target=open_writer, args=(fifo,))
	thread.daemon = True
	thread.start()
	reader = open(fifo, 'rb');
	try:
	    print(unpack('h', ioctl(reader, FIONREAD, "  "))[0])
	finally:
	    reader.close()
	if (writer): writer.close()
	thread.join()
	_EOF
}

send-message() {
    local host="$1" head="$2"; shift 2
    # shellcheck disable=2087
    ssh "$host" sh <<- EOF
	export DISPLAY=:0.0
	export XAUTHORITY=/tmp/.gdm[^_]*
	export USER=\$(users | cut -d\\  -f1)
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
    local wait_pid=$! timeout="$1" err='' waiter_pid='' ret=0; shift
    err="$([ "$timeout" -gt 0 ] 2>&1)" || {
	echo "Invalid timeout: '$timeout' : $err" >&2
	return 1
    }
    [ $# -gt 0 ] && {	# we've been passed a command to run
	"$@"			# so run it
	wait_pid=$!
    }		# otherwise assume it's been run just before us
    (   trap exit HUP
        sleep "$timeout"
        kill "$wait_pid" 2>/dev/null
    ) & waiter_pid=$!
    wait $wait_pid; ret=$?
    kill -HUP $waiter_pid 2>/dev/null
    return $ret
}

pipe_wireshark() {
    local host="$1"; shift
    # shellcheck disable=2029
    ssh "$host" "tcpdump -U -n -w - -s 65535 -i any ${*:-not port 22}" |
	wireshark -k -i -
}

java_memdump() {
    jmap -dump:live,format=b,file="${2-$1.dump}" "$1"
}

twinkle.remote() {
    local host="${1:-vm}"; shift
    # shellcheck disable=2029
    ssh >/dev/null 2>&1 -f "$host" twinkle "$@"
}

my_ip() {
    # Output the first external ip of this machine
    # In case it's run under sudo with a crap setup that mangles PATH:
    local ip=''
    ip="$(command -v ip)" ||
	{ [ -x /sbin/ip ] && ip="/sbin/ip"; } ||
	{ echo "command ip not found" >&2; return 127; }
    "$ip" 2>/dev/null -4 -o addr show | \
        sed -ne '
            /\<scope\s\+global\>/ {
                s/^.*\<inet\s\+\([0-9\.]\+\)\/[0-9]\+\>.*$/\1/p
                '"$([ "$1" = -a ] || echo 'q')"'
            }'
}

mysql_grant() {
    [ $# -eq 1 ] || [ $# -eq 2 ] || {
	echo "Usage: mysql_grant <remote_addr> [local_addr]" >&2
	return 1
    }
    local remote="$1" self=''
    # shellcheck disable=2119
    self="${2:-$(my_ip)}" && [ -n "$self" ] || return
    # shellcheck disable=2029
    ssh "$remote" mysql -e \
        "\"grant all privileges on *.* to 'root'@'$self' with grant option\""
}

mysql_convert_charset() {
    local db="$1" charset="${2-utf8}" query="SELECT"
    query="$query CONCAT(\"ALTER TABLE \`\", table_schema, \"\`.\`\","
    query="$query table_name, \"\` CONVERT TO CHARACTER SET $charset;\")"
    query="$query AS cmd FROM information_schema.tables"
    query="$query WHERE table_schema = \"$db\";"
    #echo "mysql -BNe '$query' | mysql"
    mysql -BNe "$query" | mysql
}

ssh_fix_for_old_terminfo() {
    # shellcheck disable=2088
    ssh "$1" cat '>>' '~/.bashrc' <<- EOF
	case "\$TERM" in
	    screen-256color)    export TERM="screen";;
	    *-256color)         export TERM="\${TERM%-256color}-color";;
	esac
	EOF
}

ssh_set_up() {
    local fix_term=false
    case "$1" in (-f|-t|--fix-term) fix_term=true; shift;; esac
    while [ $# -gt 0 ]
    do
        sudo ssh-copy-id -i "/root/.ssh/id_rsa.pub" "$1"
        sudo ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" "$1"
        "$fix_term" && ssh_fix_for_old_terminfo "$1"
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

watch_for() {
    local i=0 int=2 fl regex
    case "$1" in
        -i)     int="$2"; shift 2;;
        -i*)    int="${1#-i}"; shift;;
    esac
    if [ -f "$1" ] && [ -r "$1" ]
    then
        fl="$1"
        shift
    else
        echo "Cannot read file: $1" >&2
        return 1
    fi
    case $# in
        0)  regex="";;
        1)  regex="\\$1";;
        *)  regex="\\$1"; shift;
            while [ $# -gt 0 ]
            do regex="$regex|$1"; shift
            done
            regex="$regex)";;
    esac
    # shellcheck disable=2016
    while printf '\r%*s\r%i%s' "$COLUMNS" ' ' "$(( i * int ))" \
        "$(sed "$fl" -Ene "$regex"'{s/\s+/ /g;H};${g;s/\n/\t/g;p}')"
    do
        i=$(( i + 1 ))
        sleep "$int"
    done
}

spring_login() {
    local host="$1" user="" pass="" session=""; shift
    [ $# -gt 0 ] && { user="$1"; shift; } || user="all"
    [ $# -gt 0 ] && { pass="$1"; shift; } || pass="$user"
    session=$(curl 2>/dev/null -k https://"$host"/j_spring_security_check \
        --data "j_username=$user&j_password=$pass" -w "%{redirect_url}" \
        | sed 's/.*\(;jsessionid=.*\)/\1/')
    echo "$session"
    # TODO work for both cookie and url style
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

type firefox >/dev/null 2>&1 && {
    get_firefox_extension_id() {
        unzip -qc "$1" install.rdf | xmlstarlet sel \
            -N rdf=http://www.w3.org/1999/02/22-rdf-syntax-ns# \
            -N em=http://www.mozilla.org/2004/em-rdf# \
            -t -v \
            "//rdf:Description[@about='urn:mozilla:install-manifest']/em:id" \
            -n
    }
    get_firefox_extension_name() {
        unzip -qc "$1" install.rdf | xmlstarlet sel -n \
            -N rdf=http://www.w3.org/1999/02/22-rdf-syntax-ns# \
            -N em=http://www.mozilla.org/2004/em-rdf# \
            -t -v \
            "//rdf:Description[@about='urn:mozilla:install-manifest']/em:name" \
            -n

    }
}

type pip >/dev/null 2>&1 && {
    pip() {
	case "$1" in
	    update|upgrade)	shift
		local _ifs="$IFS" IFS="
"
		# shellcheck disable=2046
		set -- install --upgrade "$@" \
		    $(pip list --outdated --format=freeze | cut -d= -f1 |
			grep -v mercurial)	# TODO
		IFS="$_ifs";;
	    reinstall)		shift
		set -- install --upgrade --force-reinstall --no-deps "$@";;
	    *)	:;;
	esac
	command pip "$@"
    }
}

join_logs() { # $1: line start
    [ $# -eq 1 ] || {
	echo "usage: join_logs <line_start>" >&2
	return 1
    }
    local line_start="$1"
    case "$line_start" in ('\n'*) :;; (*) line_start="\\n$line_start";; esac
    sed -e ':start; N;
	/'"$line_start"'/{
	    h; s/\n.*//p; g; s/[^\n]*\n//;
	    b start;
	};
	s/\n/\\n/g;
	t start;
	'
}

type kubectl >/dev/null 2>&1 && {
    k_bad_pods() {
	{   if [ $# -eq 1 ] && [ "$1" = '-' ]
	    then
		cat
	    elif [ $# -gt 0 ]
	    then
		case "$*" in
		    k*)		"$@";;
		    *" get "*)	kubectl "$@";;
		    *)		kubectl get pods "$@";;
		esac
	    else
		kubectl --all-namespaces=true get pods -a -owide
	    fi
	} | sed -En '
	    1{p;b;}
	    /^(\S+\s+){3,4}[1-9][0-9]+/{p;b;};
	    /^(\S+\s+){1,2}0\/[0-9]+\s+Completed/d;
	    /(\S+\s+){1,2}([0-9]+)\/\2\s+Running/d;
	    p;
	    '
    }
}

type rg >/dev/null 2>&1 && {
    rf() {
	local i=0 t="$#" a='' _g='-g'
	while [ "$i" -lt "$t" ];
	do  i=$(( i + 1 )) a="$1"; shift
	    case "$a" in
		-i)				_g="--iglob=";	continue;;
		-I)				_g="-g";	continue;;
		-*)				:;;
		*/*)				:;;	# assume it's a PATH
		'!'*'*'*|'!'*'?'*|'!'*'['*)	a="$_g$a";;
		'!'*)				a="$_g!*${a#!}*";;
		*'*'*|*'?'*|*'['*)		a="$_g$a";;
		*)				a="$_g*$a*";;
	    esac
	    set -- "$@" "$a"
	done
	rg --files --ignore "$@"
    }
}

type openssl >/dev/null 2>&1 && {
    encrypt() {
	local in="$1" out="${2:-}"
	[ -f "$in" ] || { echo "No such file: $1" >&2; return 1; }
	[ -n "$out" ] || out="$in.enc"
	openssl aes-256-cbc -a -salt -in "$in" -out "$out"
    }
    decrypt() {
	local in="$1" out="${2:-}"
	[ -f "$in" ] || { echo "No such file: $1" >&2; return 1; }
	[ -n "$out" ] || {
	    case "$in" in
		*.enc)
		    out="${in%.enc}"
		    [ -f "$out" ] && out="$out.dec"
		    ;;
		*)
		    out="$in.dec"
		    ;;
	    esac
	}
	openssl aes-256-cbc -d -a -in "$in" -out "$out"
    }
}

_term_detect() {	# TODO
    local fd="${1-1}" pipe="" our_pid="$$"
    # if it's a tty, we're good already
    [ -t "$fd" ] && return
    # otherwise, let's see if it's a pipe
    pipe="$(readlink "/proc/$$/fd/$fd")" || return
    case "$pipe" in
	'pipe['[0-9]*']')	pipe="${pipe%]}"; pipe="${pipe#pipe[}";;
	*)			false;;
    esac || return	# if it's not a pipe we're done
    # So now we need to find the other end of the pipe
    other_pid_cmd_type="$(lsof -wu"$(id -u)" -blnP +Ui -Fpctif |
	while read -r var
	do  case "$var" in
		(p*)	pid="${var#p}";;
		(c*)	cmd="${var#c}";;
		(t*)	typ="${var#t}";;
		(i*)	ino="${var#i}";;
		(f*)	fds="${var#f}";;
	    esac
	    [ "$pid" != "$our_pid" ] || continue

	done)"
}

: "${CNF=127}"
__cnf() {       # equivalent to the default bash command not found behaviour
    echo "$_SH: $1: command not found" >&2
    return "${CNF-127}"
}
__top() {       # tests if current execution environment is a top level shell
    local pid='' cmd='' state='' ppid='' session='' tty_nr='' tpgid='' rest=''
    # not in a pipe, or from MC
    [ -t 0 ] && [ -t 1 ] && [ -z "$MC_SID" ] || return
    # not in a subshell
    local pid cmd state ppid pgrp session tty_nr tpgid rest
    # shellcheck disable=2034	# makes it easier to read
    read -r pid cmd state ppid pgrp session tty_nr tpgid rest </proc/self/stat
    [ $$ -ne "$tpgid" ] || return
    :   # TODO: anything else?
}
__slp() {       # treats $1 as a single letter prefix command
    [ ${#1} -gt 1 ] || return "${CNF-127}"
    local a="${1#?}" p="" c="" t=""; p="${1%$a}"; shift
    c="$(command -v "$p")" || return "${CNF-127}"
    case "$c" in
        $p)             # function or builtin
            set -- "$p" "$a" "$@"
            t=f;;
        "alias $p="*)   # alias
            eval "set -- ${c#alias $p=} \"$a\" \"\$@\""
            t=a;;
        /*/$p)          # executable
            set -- "$c" "$a" "$@"
            t=e;;
    esac
    case "$t" in
        [${SLP_T=fa}])  "$@";;
        *)              return "${CNF-127}";;
    esac
}
command_not_found_handle() {
    # only run in a top-level shell
    #__top || __cnf "$@" || return
    local r=0; unset r
    # try and run <cmd> as <c md>
    __slp "$@"; [ ${r=$?} -eq 127 ] && unset r || return $r
    # TODO: `ll` -> `l -l`?
    # TODO: anything else?
    __cnf "$@"
}

## End functions
######################

