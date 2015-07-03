#!/bin/bash

docker rm -f $2
docker run --name $2 \
    --net="container:base" \
    -d $1/stem-$2
