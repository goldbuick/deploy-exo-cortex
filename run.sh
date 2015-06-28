#!/bin/bash

mkdir docker-data

docker rm -f rethinkdb
docker run --name rethinkdb \
    -v "$PWD/docker-data:/data" \
    -d rethinkdb

docker rm -f private
docker run --name private \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -d jwilder/nginx-proxy

docker rm -f base
docker run --name base \
    --link rethinkdb:rethinkdb \
    -d goldbuick/stem-config-server

docker rm -f terminal
docker run --name terminal \
    --net="container:base" \
    -d goldbuick/stem-terminal-server

docker rm -f barrier
docker run --name barrier \
    --link private:private \
    --link rethinkdb:rethinkdb \
    --link base:base \
    -p 8080:70 \
    -p 8888:7080 \
    -p 7154:6154 \
    -p 26154:16154 \
    -v "$PWD/docker-data:/var/nginx" \
    -d goldbuick/util-barrier

docker ps
