#!/bin/sh

set -e

registry_url="prireg:5000"
NAME=zookeeper
TAG=3.4.10
ZOO_SERVERS="server.1=cent-01:2888:3888 server.2=cent-02:2888:3888 server.3=cent-03:2888:3888"

# temp id for testing
ZOO_MY_ID=""
if [ $(hostname) == "cent-01" ] ; then
    ZOO_MY_ID=1
elif [ $(hostname) == "cent-02" ] ; then
    ZOO_MY_ID=2
elif [ $(hostname) == "cent-03" ] ; then
    ZOO_MY_ID=3
else
    echo "Usage: failed to set [ZOO_MY_ID] : $(hostname) ";
    exit 1;
fi

echo "ZOO_MY_ID=$ZOO_MY_ID"
echo "ZOO_SERVERS=$ZOO_SERVERS"
echo "NAME=$NAME"
echo "zookeeper_docker_image=${registry_url}/${NAME}:${TAG}"

# docker run 을 위해서는 위 변수들을 환경에 맞게 셋팅한다.

docker run -d --restart always \
      --name prod-$NAME \
      --label SERVICE_NAME=$NAME \
      --network host \
      -e ZOO_MY_ID=$ZOO_MY_ID \
      -e ZOO_SERVERS="$ZOO_SERVERS" \
      -v /data/prod/zookeeper/data:/data \
      -v /data/prod/zookeeper/conf:/conf \
      -v /data/prod/zookeeper/datalog:/datalog \
      -v /data/logs/zookeeper:/logs \
      -v /etc/localtime:/etc/localtime:ro \
      -p 2181:2181 \
      -p 2888:2888 \
      -p 3888:3888 \
      $registry_url/${NAME}:${TAG}


#########################
# optional zoo.cfg
# zoo.cfg의 다른 설정값들을 디폴트 값이 아닌 다른 값으로 대체 할려면 -e 옵션으로 넘겨준다.
# 변수명은 실제설정명과 동일 하며, 단지 '.'이 있는 변수는 '_' 로 대체해주면 된다. 
##########################
# 예)
#-e tickTime="2000" \
#-e initLimit="10" \
#-e syncLimit="5" \
#-e maxClientCnxns="60" \
#-e maxClientCnxns="60" \
#-e autopurge_purgeInterval="0" \

