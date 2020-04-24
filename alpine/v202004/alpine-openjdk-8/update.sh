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

IMAGE="../../images/alpine-openjdk8-image.tar"

# by image file
docker build -t ${REGISTRY}/${NAME}:${TAG} -f ./build_image/Dockerfile* . \
#docker load -i $IMAGE \
  && docker push ${REGISTRY}/${NAME}:${TAG} \
  && docker rmi ${REGISTRY}/${NAME}:${TAG}


echo ""
echo "${NAME}:${TAG} image를 Registry(${REGISTRY})에 저장 완료."
echo ""
echo "registry repository 정보 조회"
echo "===================================="
curl -X GET http://${REGISTRY}/v2/_catalog
curl -X GET http://${REGISTRY}/v2/$NAME/tags/list
echo "===================================="
