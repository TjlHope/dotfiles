#!/bin/bash

###############################
## Definition of bash completions

# Use drop in scripts
[ -f "/etc/profile.d/bash-completion.sh" ] && # gentoo style
    . "/etc/profile.d/bash-completion.sh"
[ -f "/etc/profile.d/bash_completion.sh" ] && # ubuntu style
    . "/etc/profile.d/bash_completion.sh"

# check we have the special _which function:
declare -f _which > /dev/null ||
    _which () { false ; }

# And indiviual programs without thier own completion
complete -o dirnames -fX '!*.[Pp][Dd][Ff]' apvlv mupdf
_which 'VisualBoyAdvance' &&
    complete -o dirnames -fX '!*.[Gg][Bb]*' VisualBoyAdvance 
_which 'desmume' &&
    complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume desmume-glade desmume-cli

## End completions
######################

