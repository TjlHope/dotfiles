# This file contains a list of commands my bashrc will run at startup, seperate 
# from the desktop autostart mechanism.
# Commands are only run if not running already, and are backgrounded using the 
# 'sudo -b' (with '-u ${USER}' for privs) mechanism, to prevent shell 
# interaction. They are also 'nice'd and 'ionice'd (if possible) to (hopefully) 
# reduce load.

# Lines started with a '#' are recognised as comments

recollindex -m -x

# notifies me the length of time screen saver's been active
track_timeout
