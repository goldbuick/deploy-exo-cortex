#!/bin/bash

mkdir docker-data

docker rm -f frontage
docker run --name frontage \
    -v "$PWD/docker-data:/etc/nginx/htpasswd" \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -p 80:80 \
    -d goldbuick/util-proxy

docker rm -f ui-config
docker run --name ui-config \
    -e VIRTUAL_HOST=config.$1 \
    -d goldbuick/ui-config

docker rm -f ui-chat
docker run --name ui-chat \
    -e VIRTUAL_HOST=chat.$1 \
    -d goldbuick/ui-chat

docker rm -f rethinkdb
docker run --name rethinkdb \
    -e VIRTUAL_HOST=dive.$1 \
    -e VIRTUAL_PORT=8080 \
    -v "$PWD/docker-data:/data" \
    -d rethinkdb

docker rm -f base
docker run --name base \
    --link rethinkdb:rethinkdb \
    -d goldbuick/stem-base

docker rm -f barrier
docker run --name barrier \
    --link base:base \
    -p 7154:6154 \
    -p 26154:16154 \
    -v "$PWD/docker-data:/var/nginx" \
    -d goldbuick/util-barrier

docker ps
