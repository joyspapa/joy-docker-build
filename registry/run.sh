#!/bin/sh

registry_url="prireg:5000"
NAME=registry
TAG=2

docker run -d --restart always \
              --name prod-${NAME} \
              --user $(id -u):$(id -g) \
              -e REGISTRY_STORAGE_DELETE_ENABLED=true \
              -p 5000:5000 \
              -v /data/prod/registry:/var/lib/registry \
              -v /etc/localtime:/etc/localtime:ro \
              ${registry_url}/${NAME}:${TAG}

