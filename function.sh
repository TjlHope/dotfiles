#!/bin/sh

###############################
## Definition of shell functions

pd () {
    # Combine pushd and popd, empty dir, or '-' is a pop, otherwise push.
    if [ -z "${1}" -o "${1}" = '-' ]
    then
	popd
    else
	pushd "${@}"
    fi
}

pager () {
    [ -n "${*}" ] &&
	"${@}" | ${PAGER:-less} ||
	${PAGER:-less} "${@}"
}

ls_pager () {
    ls "${@}" | ${PAGER:-less}
}

pc_vblock () {	# FIXME: Rounding Errors
    # Output a single unicode block character to (vertically) represent a 
    # percentage. Return values: 0 = OK; 1 = Out of Bounds; 2 = Invalid.
    if [ -z "${1}" ] || [ -n "${1#[0-9]}" -a \
			    -n "${1#[0-9][0-9]}" -a \
			    -n "${1#[0-9][0-9][0-9]}" ]
    then
	return 2
    elif [ ${1} -lt 0 ]; then	# Out of Bounds
	return 1
    elif [ ${1} -lt 6 ]; then	# < 6.25
	echo " "	# <space>
    elif [ ${1} -le 18 ]; then	# < 18.75
	echo "▁"	# u2881
    elif [ ${1} -lt 31 ]; then	# < 31.25
	echo "▂"	# u2882
    elif [ ${1} -le 43 ]; then	# < 43.75
	echo "▃"	# u2583
    elif [ ${1} -lt 56 ]; then	# < 56.25
	echo "▄"	# u2584
    elif [ ${1} -le 68 ]; then	# < 68.75
	echo "▅"	# u2585
    elif [ ${1} -lt 81 ]; then	# < 81.25
	echo "▆"	# u2586
    elif [ ${1} -le 93 ]; then	# < 93.75
	echo "▇"	# u2587
    elif [ ${1} -le 100 ]; then	# <= 100
	echo "█"	# u2588
    else			# Out of Bounds
	return 1
    fi
}

pc_hblock () {	# FIXME: Rounding Errors
    # Output ${2:-4} unicode block characters to (horisontally) represent a 
    # percentage. Return values: 0 = OK; 1 = Out of Bounds; 2 = Invalid.
    local p w n i hblock
    if [ -z "${1}" ] || [ -n "${1#[0-9]}" -a \
			    -n "${1#[0-9][0-9]}" -a \
			    -n "${1#[0-9][0-9][0-9]}" ]
    then
	return 2
    else
	p="${1}"
    fi
    if [ -n "${2#[0-9]}" -a \
	-n "${2#[0-9][0-9]}" -a \
	-n "${2#[0-9][0-9][0-9]}" ]
    then
	return 2
    else
	w="${2:-4}"
    fi
    n=$(( 100 / ${w} ))
    while [ ${i:=${n}} -lt ${p} ]
    do
	hblock="${hblock}█"	# u2588
	i=$(( ${i} + ${n} ))
    done
    p=$(( (${p} - (${i} - ${n})) * ${w} ))
    if [ ${p} -lt 0 ]; then	# Out of Bounds
	return 1
    elif [ ${p} -lt 6 ]; then	# < 6.25
	hblock="${hblock} "	# <space>
    elif [ ${p} -le 18 ]; then	# < 18.75
	hblock="${hblock}▏"	# u258F
    elif [ ${p} -lt 31 ]; then	# < 31.25
	hblock="${hblock}▎"	# u258E
    elif [ ${p} -le 43 ]; then	# < 43.75
	hblock="${hblock}▍"	# u258D
    elif [ ${p} -lt 56 ]; then	# < 56.25
	hblock="${hblock}▌"	# u258C
    elif [ ${p} -le 68 ]; then	# < 68.75
	hblock="${hblock}▋"	# u258B
    elif [ ${p} -lt 81 ]; then	# < 81.25
	hblock="${hblock}▊"	# u258A
    elif [ ${p} -le 93 ]; then	# < 93.75
	hblock="${hblock}▉"	# u2589
    elif [ ${1} -le 100 ]; then	# <= 100
	hblock="${hblock}█"	# u2588
    else			# Out of Bounds
	return 1
    fi
    i=$(( ${i} + ${n} ))
    while [ ${i} -lt $(( 100 + ${n} )) ]
    do
	hblock="${hblock} "	# <space>
	i=$(( ${i} + ${n} ))
    done
    echo "${hblock}"
}

cpu_usage () {
    # Get the total cpu line from /proc/stat: "IDLE|T1 T2 T3 IDLE T5 ... TN"
    local cpu v a t p
    cpu="$(sed -n /proc/stat -e \
	's/^cpu\s\+\(\([0-9]\+\s\+\)\{3\}\)\([0-9]\+\)\(.*\)$/\3|\1\3\4/p')"
    # Sum all the values after the bar to get the total
    [ -f "${SHM}/cpu" ] &&
	read _a _t < "${SHM}/cpu"
    for v in ${cpu#*|}
    do
	t=$(( ${t-0} + ${v}))			# total time (cs)
    done
    a=$(( ${t} - ${cpu%%|*} ))			# active time (cs)
    # percent use
    p=$(( (1000 * (${a} - ${_a:-0}) / (${t} - ${_t:-0}) + 5) / 10 ))
    # Output the percentage
    [ "${1}" = '-v' ] &&
	echo "(${a} - ${_a-0}) / (${t} - ${_t-0}) = ${p}" ||
	echo "${p}"
    echo "${a} ${t}" > "${SHM}/cpu"
}

mem_usage () {
    # Get the total and active mem values from /proc/meminfo: ACTIVE|TOTAL
    local mem v a t p
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

cpu_mem_pc () {
    # Output a block representation of cpu and memory.
    [ -n "${1}" ] && [ ${1} -gt 1 ] &&
	local pc_block="pc_hblock" ||
	local pc_block="pc_vblock"
    echo "$(${pc_block} "$(cpu_usage)" ${1})$(${pc_block} "$(mem_usage)" ${1})"
}

## End functions
######################

