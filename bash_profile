# /etc/skel/.bash_profile

export PATH="~/bin:${PATH}"

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[[ -f ~/.bashrc ]] && . ~/.bashrc

# home tmpfs vars
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.claws-mail"
#export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.firefox"
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.config/midori"
export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.opera"
#export TMPFS_LINK_POINTS="$TMPFS_LINK_POINTS /home/tom/.thunderbird"
# start home_tmpfs
nohup /usr/local/share/home_tmpfs.sh start &>/dev/null &

# auth agents
eval $(keychain --eval --quiet --noask)

# start Dropbox
#/usr/local/share/wrappers/Xdropbox.sh &

