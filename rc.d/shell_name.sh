#!/bin/sh
# ~/.profile.d/shell_name.sh
# Find the name of the current shell

# This could have checked shell dependent variables, but I thought this simpler
# and more elegant. This is required (instead of ${SHELL}) as it's not
# infrequent for me to drop (from bash) into a dash shell to play with
# constructs for scripts, and if testing a login dash sourcing my bashrc would
# play havoc.  This is also why just testing the ${SHELL} variable is
# insufficient, as that reports the ${USER}s default login shell, not the
# current one.
if [ -d "/proc/$$" ]
then
    [ -f "/proc/$$/comm" ] && {	# only available in later kernels.
	read _SH < "/proc/$$/comm"
    } || {
	_SH="$(sed -ne "s:^-\?\([^\x00]\+\)\x00.*:\1:p" "/proc/$$/cmdline")"
	_SH="${_SH##*/}"
    }
elif type ps >/dev/null 2>&1
then
    _SH="$(ps -ocomm= "$$")"
    case "$_SH" in
	-*)	_SH="${_SH#-}";;
	/*)	_SH="${_SH##*/}";;
    esac
else
    _SH="$SHELL"	# fall back
fi
