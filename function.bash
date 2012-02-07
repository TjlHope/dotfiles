#!/bin/bash

###############################
## Definition of bash functions

# Prevent tests for commands getting aliases/functions when re-sourcing.
which_bin="$(which --skip-alias --skip-functions which)"
eval "_which () { ${which_bin} \${@} > /dev/null 2>&1 ; }"
unset which_bin

ls_pager () {
    ls ${@} | ${PAGER:-less}
}

## End functions
######################

