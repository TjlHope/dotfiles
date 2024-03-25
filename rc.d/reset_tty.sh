#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# Define a function to reset tty status

# eval to bake in the initial stty settings
eval "reset_tty() {
    stty $(stty -g)
    $(_have tput && echo tput reset || echo reset)
}"

# It only makes sense to source this, as you need stuff baked in.
