#!/bin/sh

set -e

registry_url="prireg:5000"

NAME=kafka
TAG=2.12-0.11.0.2
ADVERTISED_HOST_NAME="$(hostname)"
ZK_CONNECT="cent-01:2181,cent-02:2181,cent-03:2181"
#ZK_CONNECT="192.168.10.82:2181,192.168.10.83:2181,192.168.10.84:2181"

# temp id for testing
BROKER_ID=""
if [ $(hostname) == "cent-01" ] ; then
    BROKER_ID=1
elif [ $(hostname) == "cent-02" ] ; then
    BROKER_ID=2
elif [ $(hostname) == "cent-03" ] ; then
    BROKER_ID=3
else
    echo "Usage: failed to set [BROKER_ID] : $(hostname) ";
    exit 1;
fi

echo "BROKER_ID=$BROKER_ID"
echo "ZK_CONNECT=$ZK_CONNECT"
echo "NAME=$NAME"
echo "kafka_docker_image=${registry_url}/${NAME}:${TAG}"

# docker run 을 위해서는 위 변수들을 환경에 맞게 셋팅한다.

docker run -d --restart always \
            --name prod-$NAME \
            --label SERVICE_NAME=$NAME \
            --network host \
            -e BROKER_ID=$BROKER_ID \
            -e ADVERTISED_HOST_NAME=$ADVERTISED_HOST_NAME \
            -e ZK_CONNECT=$ZK_CONNECT \
            -e num_partitions="1" \
            -e log_retention_hours="72" \
            -e zookeeper_connection_timeout_ms="30000" \
            -e default_replication_factor="2" \
            -e offsets_retention_minutes="10080" \
            -p 9092:9092 \
            -v /data/prod/kafka/data:/data \
            -v /data/logs/kafka:/logs \
            -v /etc/localtime:/etc/localtime:ro \
            ${registry_url}/${NAME}:${TAG}
            

# backup - disable conf volume
#-v /data/prod/docker/kafka/conf:/conf \

#            --network host \
