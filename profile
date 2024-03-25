# ~/.profile
# shellcheck shell=sh disable=1090,2155
# vim: ft=sh

# source any helper scripts for base variables & functions
for s in "$HOME"/.rc.d/_*.sh
do  [ -f "$s" ] && . "$s"
done; unset s

export PATH="$(TEST=true _pathmunge \
    "$HOME/bin" \
    "$HOME/Documents/Code/utils/bin" \
    "$HOME/Documents/Code/scripts/bin" \
    "$HOME/.local/bin" \
    "$HOME/lib/node_modules/bin" \
    "$HOME/go/bin" \
    "$HOME/lib/CPAN/bin" \
    "$HOME/.cargo/bin" \
    "$(_have brew && echo "$(brew --prefix coreutils)/libexec/gnubin")" \
    "$(_have brew && echo "$(brew --prefix curl)/bin")" \
    "$PATH" \
    )"

# set user locale
case "$LANG" in
    en_GB.[uU][tT][fF]8|en_GB.[uU][tT][fF]-8)	:;;
    *)	lang="$(locale -a | grep '^en_GB.[Uu][Tt][Ff]-\?8$')" &&
	    export LANG="${lang%%$_NL*}" ||
	    echo "WARNING: cannot find a UTF8 British locale" >&2
	unset lang;;
esac

# use vim as editor
export EDITOR="vim"

### auth agents
_have 'keychain' &&
    eval "$(keychain --eval --quiet --noask)"

### python variables
export PYTHONPATH="$(_pathmunge \
    "$HOME/Documents/Code/python" \
    "$PYTHONPATH" \
    )"

### perl variables
export PERL5LIB="$(_pathmunge \
    "$HOME/lib/CPAN/lib" \
    "$HOME/lib/CPAN/lib/perl5" \
    "$PERL5LIB" \
    )"

### rust variables
[ -d "$HOME/Documents/Code/rust/src" ] &&
    export RUST_SRC_PATH="$HOME/Documents/Code/rust/src"

### gnuplot variables
export GNUPLOT_FONTPATH="$(_pathmunge \
    "$GNUPLOT_FONTPATH" "/usr/share/fonts/!")"
export GDFONTPATH="$(_pathmunge \
    "$GDFONTPATH" "/usr/share/fonts/!")"
export GNUPLOT_DEFAULT_GDFONT="veranda"

# For Qt's GTK style to work, you need to either export
# the following variable into your environment:
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# or alternatively install gnome-base/libgnomeui

### gnash / lightspark
export GNASH_PLUGIN_DESCRIPTION="Shockwave Flash 10.1 r999"

#export WINEDEBUG="-all"
export INTEL_BATCH=1

# Setup DISPLAY for cygwin XWin server
if [ "${DISPLAY:+set}" != set ] &&
    [ "$(uname -o)" = "Cygwin" ] &&
    ps -u "$(id -un)" -f | grep -q XWin
then	# TODO: work out exactly what DISPLAY should be
    export DISPLAY=:0.0
fi


[ -f "$HOME/.profile.local" ] &&	# If there are local settings,
    . "$HOME/.profile.local"		# source them now

# This file is sourced by bash for login shells. The following line runs your
# .bashrc and is recommended by the bash info pages.
# This has been modified to run the rc file with the name of the shell.
[ -f "$HOME/.${_SH}rc" ] &&	# Source the rc file if it exists.
    . "$HOME/.${_SH}rc"
