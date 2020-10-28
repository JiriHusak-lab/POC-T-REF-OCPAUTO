#!/bin/bash


if [ $# -ne 1 ]
then
        echo wmj.sh json-file-name
        exit -1
fi

JSON_FILE=$1
TOPIC_NAME=warehouse-movement
APACHE_KAFKA=apache-kafka

cat /opt/kafka/${JSON_FILE} | bin/kafka-console-producer.sh --broker-list ${APACHE_KAFKA}:9092 --topic ${TOPIC_NAME}
