#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [ "$1" = 'kafka-server-start.sh' -a "$(id -u)" = '0' ]; then
    # When the kafka user, group IDs are different from them of docker executor, replace them"
    if [ $(id -u $KAFKA_USER) -ne $USRID ] || [ $(id -g $KAFKA_USER) -ne $GRPID ]; then
        echo "[INFO] The docker exeutor UID($USRID),GID($GRPID) are different from the $KAFKA_USER."
        echo "[INFO] Replace user and group IDs of the $KAFKA_USER."
        deluser $KAFKA_USER
        addgroup -g $GRPID $KAFKA_USER
        adduser -u $USRID -D -G $KAFKA_USER $KAFKA_USER
        chown -R $KAFKA_USER:$KAFKA_USER /opt/* $DATA_DIR $LOG_DIR
    fi
    # Execute the kafka user
    exec su-exec $KAFKA_USER $0 $@
fi

# Generate the config only if it doesn't exist
# set server.properties
export CONF_FILE=$KAFKA_CONF_DIR/server.properties
cp $KAFKA_CONF_DIR/server.properties.template ${CONF_FILE}

######################################################
# set configuration
######################################################
# required configuration
sed -i -e "s/%broker_port%/${KAFKA_PORT}/g" ${CONF_FILE}
sed -i -e "s/%broker_id%/${BROKER_ID}/g" ${CONF_FILE}
sed -i -e "s/%advertised_host_name%/${ADVERTISED_HOST_NAME}/g" ${CONF_FILE}
sed -i -e "s/%zookeeper_connect%/${ZK_CONNECT}/g" ${CONF_FILE}

replace_data_dir=$(echo "${DATA_DIR}" | sed 's/\//\\\//g')
sed -i -e "s/%log_dirs%/${replace_data_dir}/g" ${CONF_FILE}

# optional configuration on project
if [ -z ${offsets_topic_replication_factor} ]; then
    sed -i "s/%offsets_topic_replication_factor%/3/" ${CONF_FILE}
else
    sed -i "s/%offsets_topic_replication_factor%/${offsets_topic_replication_factor}/" ${CONF_FILE}
fi

if [ -z ${transaction_state_log_replication_factor} ]; then
    sed -i "s/%transaction_state_log_replication_factor%/3/" ${CONF_FILE}
else
    sed -i "s/%transaction_state_log_replication_factor%/${transaction_state_log_replication_factor}/" ${CONF_FILE}
fi

if [ -z ${transaction_state_log_min_isr} ]; then
    sed -i "s/%transaction_state_log_min_isr%/2/" ${CONF_FILE}
else
    sed -i "s/%transaction_state_log_min_isr%/${transaction_state_log_min_isr}/" ${CONF_FILE}
fi

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
    sed -i "s/%offsets_retention_minutes%/5760/" ${CONF_FILE}
else
    sed -i "s/%offsets_retention_minutes%/${offsets_retention_minutes}/" ${CONF_FILE}
fi

######################################################
# set log4j
######################################################
export LOG4J_CONF_FILE=$KAFKA_CONF_DIR/log4j.properties
cp $KAFKA_CONF_DIR/log4j.properties.template ${LOG4J_CONF_FILE}   

# optional configuration on project
if [ -z ${kafkaAppender_log_level} ]; then
    sed -i "s/%kafkaAppender_log_level%/INFO/" ${LOG4J_CONF_FILE}
else
    sed -i "s/%kafkaAppender_log_level%/${kafkaAppender_log_level}/g" ${LOG4J_CONF_FILE}
fi

if [ -z ${controllerAppender_log_level} ]; then
    sed -i "s/%controllerAppender_log_level%/TRACE/" ${LOG4J_CONF_FILE}
else
    sed -i "s/%controllerAppender_log_level%/${controllerAppender_log_level}/" ${LOG4J_CONF_FILE}
fi

if [ -z ${stateChangeAppender_log_level} ]; then
    sed -i "s/%stateChangeAppender_log_level%/TRACE/" ${LOG4J_CONF_FILE}
else
    sed -i "s/%stateChangeAppender_log_level%/${stateChangeAppender_log_level}/" ${LOG4J_CONF_FILE}
fi

#(not used : @Deprecated)
#replace_log_dir=$(echo "${LOG_DIR}" | sed 's/\//\\\//g')
#sed -i -e "s/%kafka_logs_dir%/${replace_log_dir}/g" ${LOG4J_CONF_FILE}


exec $@ $CONF_FILE