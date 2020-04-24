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

NAME=alpine-openjdk8
TAG=1.8.0_191

docker build -t ${REGISTRY}/${NAME}:${TAG} -f Dockerfile* .
