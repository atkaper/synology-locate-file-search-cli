#!/bin/bash

# This command mounts the proper folders to be indexed, and runs a re-index every night.

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"

docker rm -f locate

mkdir -p var_lib_plocate

docker run -d --restart=always --name=locate \
   -v /volume1/download/:/volume1/download/:ro \
   -v /volume1/music/:/volume1/music/:ro \
   -v /volume1/docker/:/volume1/docker/:ro \
   -v $PWD/var_lib_plocate:/var/lib/plocate \
   local/locate

sleep 2

docker logs --tail=100 locate
