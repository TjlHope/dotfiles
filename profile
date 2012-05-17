# ~/.profile
# vim: ft=sh

export PATH="${HOME}/Documents/Code/scripts/bin:${PATH}"

# set user locale
export LANG="en_GB.utf8"

# use vim as editor
export EDITOR="vim"

### auth agents
type 'keychain' > /dev/null 2>&1 &&
    eval $(keychain --eval --quiet --noask)

### export SHM_D variable pointing to personal tempory storage
! sed -ne '\:^\s*\S\+\s\+/dev/shm\s\+tmpfs\s\+.*$: q1' /proc/mounts &&
    export SHM_D="/dev/shm/${USER}" ||
    export SHM_D="/tmp/${USER}"	# default to /tmp if no shared memory
[ -d "${SHM_D}" ] || mkdir "${SHM_D}"	# no -p as ${shm_dir:-/tmp} must exist
[ -d "${SHM_D}" ] && chmod 700 "${SHM_D}"	# user read only

### python variables
pypath="${HOME}/Documents/Code/python:"
export PYTHONPATH="${pypath}${PYTHONPATH#${pypath}}"
unset pypath

### gnuplot variables
GNUPLOT_FONTPATH="${GNUPLOT_FONTPATH%:}${GNUPLOT_FONTPATH:+:}/usr/share/fonts/!"
GDFONTPATH="${GDFONTPATH%:}${GDFONTPATH:+:}/usr/share/fonts/!"
GNUPLOT_DEFAULT_GDFONT="veranda"

### gnash / lightspark
export GNASH_PLUGIN_DESCRIPTION="Shockwave Flash 10.1 r999"

#export WINEDEBUG="-all"
export INTEL_BATCH=1

# This file is sourced by bash for login shells. The following line runs your
# .bashrc and is recommended by the bash info pages.  This has been modified to
# run the rc file with the name of the shell. I could have checked shell
# dependent variables, but thought this simpler and more elegant. This is
# required as it's not infrequent for me to drop (from bash) into a dash shell
# to play with constructs for scripts, and if testing a login dash sourcing my
# bashrc would play havoc. This is also why just testing the ${SHELL} variable
# is insufficient, as that reports the ${USER}s default login shell, not the
# current one.
[ -f "/proc/$$/comm" ] && {	# only available in later kernels.
    read _SH < "/proc/$$/comm"
} || {
    _SH="$(sed -ne "s:^-\?\([^\x00]\+\)\x00.*:\1:p" "/proc/$$/cmdline")"
    _SH="${_SH##*/}"
}
[ -f "${HOME}/.${_SH}rc" ] &&	# Source the rc file if it exists.
    . "${HOME}/.${_SH}rc"
