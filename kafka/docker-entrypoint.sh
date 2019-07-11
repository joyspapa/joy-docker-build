#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [[ "$(id -u)" = '0' ]]; then
    chown -R $KAFKA_USER:$KAFKA_USER $DATA_DIR $LOG4J_LOG_DIR $CONF_DIR
    exec su-exec "$KAFKA_USER" "$0" "$@"
fi

# Generate the config only if it doesn't exist
# set server.properties
export CONF_FILE=$KAFKA_HOME/config/server.properties

if [[ -f "$CONF_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $CONF_FILE ${CONF_FILE}.$currentDate
fi

cp $KAFKA_HOME/config/server.properties.template ${CONF_FILE}

########################
# set configuration
########################
# required configuration
sed -i -e "s/%broker_id%/${BROKER_ID}/" ${CONF_FILE}
sed -i -e "s/%advertised_host_name%/${ADVERTISED_HOST_NAME}/" ${CONF_FILE}
sed -i -e "s/%zookeeper_connect%/${ZK_CONNECT}/" ${CONF_FILE}

replace_data_dir=$(echo "${DATA_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%log_dirs%/${replace_data_dir}/" ${CONF_FILE}

# optional configuration on project
if [ -z ${num_partitions} ]; then
    sed -i "s/%num_partitions%/1/" ${CONF_FILE}
else
    sed -i "s/%num_partitions%/${num_partitions}/" ${CONF_FILE}
fi

if [ -z ${log_retention_hours} ]; then
    sed -i "s/%log_retention_hours%/72/" ${CONF_FILE}
else
    sed -i "s/%log_retention_hours%/${log_retention_hours}/" ${CONF_FILE}
fi

if [ -z ${zookeeper_connection_timeout_ms} ]; then
    sed -i "s/%zookeeper_connection_timeout_ms%/30000/" ${CONF_FILE}
else
    sed -i "s/%zookeeper_connection_timeout_ms%/${zookeeper_connection_timeout_ms}/" ${CONF_FILE}
fi

if [ -z ${default_replication_factor} ]; then
    sed -i "s/%default_replication_factor%/2/" ${CONF_FILE}
else
    sed -i "s/%default_replication_factor%/${default_replication_factor}/" ${CONF_FILE}
fi

if [ -z ${offsets_retention_minutes} ]; then
    sed -i "s/%offsets_retention_minutes%/10080/" ${CONF_FILE}
else
    sed -i "s/%offsets_retention_minutes%/${offsets_retention_minutes}/" ${CONF_FILE}
fi

# set log4j
export LOG4J_CONF_FILE=$KAFKA_HOME/config/log4j.properties

if [[ -f "$LOG4J_CONF_FILE" ]]; then
    currentDate=`date +"%Y-%m-%d_%T"`
    cp $LOG4J_CONF_FILE ${LOG4J_CONF_FILE}.$currentDate
fi

cp $KAFKA_HOME/config/log4j.properties.template ${LOG4J_CONF_FILE}   

replace_log_dir=$(echo "${LOG_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%kafka_logs_dir%/${replace_log_dir}/g" ${LOG4J_CONF_FILE}

exec $@ $CONF_FILE
