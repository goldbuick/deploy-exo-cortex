#!/bin/bash

mkdir docker-data

docker rm -f rethinkdb
docker run --name rethinkdb \
    -p 127.0.0.1:7777:8080 \
    -p 127.0.0.1:28015:28015 \
    -p 127.0.0.1:29015:29015 \
    -v "$PWD/docker-data:/data" \
    -d rethinkdb

docker rm -f private
docker run --name private \
    -p 127.0.0.1:7080:80 \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -d jwilder/nginx-proxy

docker rm -f base
docker run --name base \
    --link rethinkdb:rethinkdb \
    -p 127.0.0.1:6154:7154 \
    -d goldbuick/stem-config-server

docker rm -f terminal
docker run --name terminal \
    --net="container:base" \
    -p 127.0.0.1:16154:26154 \
    -d goldbuick/stem-terminal-server

docker rm -f barrier
docker run --name barrier \
    --link rethinkdb:rethinkdb \
    --link private:private \
    --link base:base \
    --link terminal:terminal \
    -p 8888:8888 \
    -p 8080:8080 \
    -p 7154:7154 \
    -p 26154:26154 \
    -v "$PWD/docker-data:/var/nginx" \
    -d goldbuick/util-barrier

docker ps
