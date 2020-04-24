#!/bin/sh
if [ -z "$1" ]
then 
  echo "No argument supplied, set registry to prireg:5000"
    REGISTRY="prireg:5000"
  else
    echo "Set registry to $1"
    REGISTRY=$1
fi
NAME=zookeeper
TAG=3.4.10
docker build -t ${REGISTRY}/${NAME}:${TAG} -f Dockerfile.${TAG} . \
  && docker push ${REGISTRY}/${NAME}:${TAG}
