#!/bin/sh

###############################
## Definition of shell functions

ls_pager () {
    ls "${@}" | ${PAGER:-less}
}

## End functions
######################

