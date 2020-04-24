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

PULL_IMAGE=registry:2
NAME=registry
TAG=2

docker pull $PULL_IMAGE \
  && docker tag $PULL_IMAGE ${REGISTRY}/${NAME}:${TAG} \
  && docker rmi $PULL_IMAGE

