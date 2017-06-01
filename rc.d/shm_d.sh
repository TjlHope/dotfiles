#!/bin/sh
# ~/.profile.d/shell_name.sh
# Setup the ${SHM_D} env var (user temporary storage)

{ [ -f /proc/mounts ] && cat /proc/mounts || mount; } |
    egrep -q '^\s*\S+\s+/dev/shm\s+tmpfs\s+' &&
    export SHM_D="/dev/shm/${USER}" ||
    export SHM_D="/tmp/${USER}"	# default to /tmp if no shared memory

{
    [ -d "${SHM_D}" ] || mkdir "${SHM_D}"
} && {			#^ no -p as /dev/shm and /tmp must exist
    [ "$(stat -c'%Mp%Lp' "$SHM_D")" = "1700" ] || chmod 1700 "$SHM_D"
} || {					#^ user read only and sticky
    unset SHM_D
    false
}
