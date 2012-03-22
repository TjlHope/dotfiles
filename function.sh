#!/bin/sh

###############################
## Definition of shell functions

pushpopd () {
    # Combine pushd and popd, empty dir, or '-' is a pop, otherwise push.
    # Thought is that popd will rarely use arguments, pushd nearly always has a 
    # path, and so they can be easily combined in this way.
    if [ -z "${1}" -o "${1}" = '-' ]
    then
	popd
    else
	pushd "${@}"
    fi
}

pgr () {
    [ -n "${*}" ] || [ "${*}" = '-' ] &&
	"${@}" | ${PAGER:-less} ||
	${PAGER:-less} "${@}"
}

ls_pgr () {
    ls "${@}" | ${PAGER:-less}
}

## End functions
######################

