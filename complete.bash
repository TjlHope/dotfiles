#!/bin/bash

###############################
## Definition of bash completions

# Use drop in scripts
[ -f "/etc/profile.d/bash-completion.sh" ] && # gentoo style
    . "/etc/profile.d/bash-completion.sh"
[ -f "/etc/profile.d/bash_completion.sh" ] && # ubuntu style
    . "/etc/profile.d/bash_completion.sh"

# And indiviual programs without thier own completion
complete -o dirnames -fX '!*.[Pp][Dd][Ff]' apvlv mupdf
type 'VisualBoyAdvance' > /dev/null 2>&1 &&
    complete -o dirnames -fX '!*.[Gg][Bb]*' VisualBoyAdvance 
type 'desmume' > /dev/null 2>&1 &&
    complete -o dirnames -fX '!*.[Nn][Dd][Ss]' desmume desmume-glade desmume-cli

## End completions
######################

