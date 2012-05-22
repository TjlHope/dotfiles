#!/bin/sh

###############################
## Definition of shell functions

cd () {
    # Function allowing 'cd' to interpret N '.'s to mean the (N-1)th parent 
    # directory; i.e. '..' is up to parent, '...' is grandparent, '....' is 
    # great-grandparent, etc. Complement to '_cdd' completion function.
    local d="$(echo "${1}" | \
	sed -e ':sub
	    s:^\(.*/\)\?\.\.\.:\1../..:g
	    t sub'
	)"
    builtin cd ${d:+"${d}"}	# if empty, no quoting, else quote
}

pushpopd () {
    # Combine pushd and popd, empty dir, or '-' is a pop, otherwise push.
    # The thought is that popd will rarely use arguments, and pushd nearly 
    # always has a path, and so they can be easily combined in this way.
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

