#!/bin/sh

registry_url="prireg:5000"

if [ -z "$1" ]
then 
  echo "No argument supplied, set registry to ${registry_url}"
    REGISTRY=${registry_url}
  else
    echo "Set registry to $1"
    REGISTRY=$1
fi

NAME=zookeeper
TAG=3.4.10

echo "UID=$(id -u)"
echo "GID=$(id -g)"

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
             -t ${REGISTRY}/${NAME}:${TAG} -f ../Dockerfile.${TAG} ../

