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

### export SHM variable pointing to personal tempory storage
shm_dir="$(/bin/sed -ne 's:^shm\s\+\(\S\+\)\s\+tmpfs\s\+.*$:\1:p' /proc/mounts)"
export SHM="${shm_dir:-/tmp}/${USER}"	# default to /tmp if no shared memory
unset shm_dir				# stop environment pollution
[ -d "${SHM}" ] || mkdir "${SHM}"	# no -p as ${shm_dir:-/tmp} must exist
[ -d "${SHM}" ] && chmod 700 "${SHM}"	# only we want to be able to read it
[ -f "${SHM}/.keep" ] || > "${SHM}/.keep" # help persist over suspend/hibernate?

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
read _SH < "/proc/$$/comm"	# Get the name of the current shell.
[ -f "${HOME}/.${_SH}rc" ] &&	# Source the rc file if it exists.
    . "${HOME}/.${_SH}rc"

