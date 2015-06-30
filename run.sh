#!/bin/bash

mkdir docker-data

docker pull $1/util-proxy
docker pull $1/util-barrier
docker pull $1/ui-chat
docker pull $1/ui-config
docker pull $1/ui-uplink
docker pull $1/stem-base

docker rm -f frontage
docker run --name frontage \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -p 127.0.0.1:70:80 \
    -p 127.0.0.1:7080:8080 \
    -d $1/util-proxy

docker rm -f ui-config
docker run --name ui-config \
    -e VIRTUAL_HOST=config.$2 \
    -d $1/ui-config

docker rm -f ui-chat
docker run --name ui-chat \
    -e VIRTUAL_HOST=chat.$2 \
    -d $1/ui-chat

docker rm -f ui-uplink
docker run --name ui-uplink \
    -e VIRTUAL_HOST=$2 \
    -e PUBLIC_PORT=8080 \
    -d $1/ui-uplink

docker rm -f rethinkdb
docker run --name rethinkdb \
    -e VIRTUAL_HOST=dive.$2 \
    -e VIRTUAL_PORT=8080 \
    -v "$PWD/docker-data:/data" \
    -d rethinkdb

docker rm -f base
docker run --name base \
    --link rethinkdb:rethinkdb \
    -d $1/stem-base

docker rm -f barrier
docker run --name barrier \
    --link base:base \
    --link frontage:frontage \
    -p 80:70 \
    -p 8080:7080 \
    -v "$PWD/docker-data:/var/nginx" \
    -d $1/util-barrier

docker ps
