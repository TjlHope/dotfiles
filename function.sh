#!/bin/sh

###############################
## Definition of shell functions

pager () {
    [ -n "${*}" ] &&
	"${@}" | ${PAGER:-less} ||
	${PAGER:-less}
}

ls_pager () {
    ls "${@}" | ${PAGER:-less}
}

cpu_usage () {
    # Get the total cpu line from /proc/stat: "IDLE|T1 T2 T3 T4 IDLE T5 ... TN"
    cpu="$(sed -n /proc/stat -e \
	's/^cpu\s\+\(\([0-9]\+\s\+\)\{4\}\)\([0-9]\+\)\(.*\)$/\3|\1\3\4/p')"
    # Sum all the values after the bar to get the total
    for v in ${cpu#*|}
    do
	t=$(( ${t-0} + ${v}))			# total time (cs)
    done
    a=$(( ${t} - ${cpu%%|*} ))			# active time (cs)
    p=$(( (1000 * ${a} / ${t} + 5) / 10 ))	# percent use
    # Output the percentage
    [ "${1}" = '-v' ] &&
	echo "${a} / ${t} = ${p}" ||
	echo "${p}"
}

mem_usage () {
    # Get the total and active mem values from /proc/meminfo: ACTIVE|TOTAL
    mem="$(sed -n /proc/meminfo -e \
	':new
	N
	s/.*MemTotal:\s\+\([0-9]\+\)\+\s\+.*\nActive:\s\+\([0-9]\+\)\s\+.*$/\2|\1/p
	T new')"
    a="$(( ${mem%|*} / 1024 ))"		# Active memory (MB)
    t="$(( ${mem#*|} / 1024 ))"		# Active memory (MB)
    p=$(( (1000 * ${a} / ${t} + 5) / 10 ))	# percent used
    # Output the percentage
    [ "${1}" = '-v' ] &&
	echo "${a} / ${t} = ${p}" ||
	echo "${p}"
}

## End functions
######################

