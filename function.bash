#!/bin/bash

###############################
## Definition of bash functions

ls_pager () {
    ls ${@} | ${PAGER:-less}
}

## End functions
######################

