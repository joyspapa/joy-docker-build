#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [ "$1" = 'zkServer.sh' -a "$(id -u)" = '0' ]; then
    chown -R $ZOO_USER:$ZOO_USER $ZOOKEEPER_HOME $dataLogDir $dataDir $ZOO_CONF_DIR $ZOO_LOG_DIR
    exec su-exec "$ZOO_USER" "$0" "$@"
fi

#################
# set zoo.cfg
export CONF_FILE=$ZOO_CONF_DIR/zoo.cfg

# Generate the config only if it doesn't exist
if [[ -f "$CONF_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $CONF_FILE ${CONF_FILE}.$currentDate
fi

cp $ZOOKEEPER_HOME/conf/zoo.cfg.template ${CONF_FILE}

########################
# set configuration
########################
# required configuration
sed -i -e "s/%clientPort%/${clientPort}/" ${CONF_FILE}

replace_dataDir=$(echo "${dataDir}" | sed 's/\//\\\//g')
sed -i -e "s/%dataDir%/${replace_dataDir}/" ${CONF_FILE}

replace_dataLogDir=$(echo "${dataLogDir}" | sed 's/\//\\\//g')
sed -i -e "s/%dataLogDir%/${replace_dataLogDir}/" ${CONF_FILE}

for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONF_FILE"
done

# optional configuration on project
if [ -z ${tickTime} ]; then
    sed -i "s/%tickTime%/2000/" ${CONF_FILE}
else
    sed -i "s/%tickTime%/${tickTime}/" ${CONF_FILE}
fi

if [ -z ${initLimit} ]; then
    sed -i "s/%initLimit%/10/" ${CONF_FILE}
else
    sed -i "s/%initLimit%/${initLimit}/" ${CONF_FILE}
fi

if [ -z ${syncLimit} ]; then
    sed -i "s/%syncLimit%/5/" ${CONF_FILE}
else
    sed -i "s/%syncLimit%/${syncLimit}/" ${CONF_FILE}
fi

if [ -z ${maxClientCnxns} ]; then
    sed -i "s/%maxClientCnxns%/60/" ${CONF_FILE}
else
    sed -i "s/%maxClientCnxns%/${maxClientCnxns}/" ${CONF_FILE}
fi

if [ -z ${autopurge_snapRetainCount} ]; then
    sed -i "s/%autopurge_snapRetainCount%/3/" ${CONF_FILE}
else
    sed -i "s/%autopurge_snapRetainCount%/${autopurge_snapRetainCount}/" ${CONF_FILE}
fi

if [ -z ${autopurge_snapRetainCount} ]; then
    sed -i "s/%autopurge_purgeInterval%/0/" ${CONF_FILE}
else
    sed -i "s/%autopurge_purgeInterval%/${autopurge_purgeInterval}/" ${CONF_FILE}
fi

#################
# set myid
export MYID_FILE=$dataDir/myid

# Write myid only if it doesn't exist
if [[ -f "$MYID_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $MYID_FILE ${MYID_FILE}.$currentDate
fi

echo "${ZOO_MY_ID:-1}" > "$MYID_FILE"

#################
# set log4j.properties
export LOG_CONF_FILE=$ZOO_CONF_DIR/log4j.properties

# Generate the config only if it doesn't exist
if [[ -f "$LOG_CONF_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $LOG_CONF_FILE ${LOG_CONF_FILE}.$currentDate
fi

cp $ZOOKEEPER_HOME/conf/log4j.properties.template ${LOG_CONF_FILE}

#################
# set java.env
export JAVA_ENV_FILE=$ZOO_CONF_DIR/java.env

# Generate the config only if it doesn't exist
if [[ -f "$JAVA_ENV_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $JAVA_ENV_FILE ${JAVA_ENV_FILE}.$currentDate
fi

cp $ZOOKEEPER_HOME/conf/java.env ${JAVA_ENV_FILE}

exec "$@"

