#!/bin/bash

docker pull $1/ui-$2

docker rm -f ui-$2
docker run --name ui-$2 \
    -e VIRTUAL_HOST=$2.$3 \
    -d $1/ui-$2
