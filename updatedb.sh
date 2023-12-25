#!/bin/bash

# Only files in folder /volume1 will be indexed, that is where the Synology NAS folders will be mounted.

flock --nonblock /run/plocate.daily.lock /usr/bin/ionice -c3 nice /usr/sbin/updatedb.plocate -l no --prune-bind-mounts no -U /volume1/ 
echo "Total indexed files: $( locate -c -r '.*' )"

