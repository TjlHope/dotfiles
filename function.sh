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

## End functions
######################

