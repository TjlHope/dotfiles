# ~/.profile
# vim: ft=sh

export PATH="${HOME}/bin:${PATH}"

# set user locale
export LANG="en_GB.utf8"

# use vim as editor
export EDITOR="vim"

### auth agents
eval $(keychain --eval --quiet --noask)

### python vars
pypath="${HOME}/Documents/Code/python"
export PYTHONPATH="${pypath}:${PYTHONPATH#${pypath}}"
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
[ ${SHELL##*/} = "bash" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# home tmpfs vars
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.claws-mail"
#export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.firefox"
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.config/midori"
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.opera"
#export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.thunderbird"
# start home_tmpfs
#/usr/local/share/home_tmpfs.sh start &>/dev/null &

# start Dropbox
#/usr/local/share/wrappers/Xdropbox.sh &

