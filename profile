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

### export SHM var pointing to personal tempory storage
shm_dir="$(/bin/sed -ne 's:^shm\s\+\(\S\+\)\s\+tmpfs\s\+.*$:\1:p' /proc/mounts)"
export SHM="${shm_dir:-/tmp}/${USER}"	# default to /tmp if no shared memory
unset shm_dir				# stop environment pollution
[ -d "${SHM}" ] || mkdir "${SHM}"	# no -p as ${shm_dir:-/tmp} must exist
[ -d "${SHM}" ] && chmod 700 "${SHM}"	# only we want to be able to read it
[ -f "${SHM}/.keep" ] || > "${SHM}/.keep" # help persist over suspend/hibernate?

### python vars
pypath="${HOME}/Documents/Code/python:"
export PYTHONPATH="${pypath}${PYTHONPATH#${pypath}}"
unset pypath

### gnuplot vars
GNUPLOT_FONTPATH="${GNUPLOT_FONTPATH}:/usr/share/fonts/!"
GDFONTPATH="${GDFONTPATH}:/usr/share/fonts/!"
GNUPLOT_DEFAULT_GDFONT="veranda"

### gnash / lightspark
export GNASH_PLUGIN_DESCRIPTION="Shockwave Flash 10.1 r999"

#export WINEDEBUG="-all"
export INTEL_BATCH=1

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[ "$(< "/proc/$$/comm")" = "bash" ] && [ -f "${HOME}/.bashrc" ] &&
    . "${HOME}/.bashrc"

