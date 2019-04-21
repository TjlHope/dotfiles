#!/bin/sh
# shellcheck disable=2015
# ~/.profile.d/shm_d.sh
# Setup the $TMP_D and $SHM_D env vars (user temporary storage)

export TMP_D="${TMPDIR:-/tmp}/$USER"

{ [ -f /proc/mounts ] && cat /proc/mounts || mount; } |
    grep -Eq '^\s*\S+\s+/dev/shm\s+tmpfs\s+' &&
    export SHM_D="/dev/shm/$USER" ||
    export SHM_D="$TMP_D"	# default to /tmp if no shared memory

{		# don't use mkdir -p as /dev/shm and /tmp must exist
    [ -d "$SHM_D" ] || mkdir "$SHM_D"
} && {		# make the dir user read only and sticky
    [ "$(stat -c'%Mp%Lp' "$SHM_D")" = "1700" ] || chmod 1700 "$SHM_D"
} && {		# if $TMP_D doesn't already exist, symlink it to SHM_D
    [ -d "$TMP_D" ] || ln -s "$SHM_D" "$TMP_D"
} || {
    # If we've had a failure, always unset $SHM_D as it might not have the
    # permissions we need. But only unset $TMP_D if it doesn't exist.
    unset SHM_D
    [ -d "$TMP_D" ] ||
	{ [ -h "$TMP_D" ] && [ -d "$(readlink "$SHM_D")" ]; } ||
	unset TMP_D
    false
}
