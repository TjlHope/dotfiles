#!/bin/sh
# vi: sw=4 sts=4 ts=8 et
# eval docker-machine env if it's running

if _have docker-machine
then
    case "$(docker-machine status)" in
        Running)    eval "$(docker-machine env)";;
        Stopped)    :;;     # don't bother with anything
    esac
fi

