#!/bin/bash

cat /opt/kafka/wmj.json | bin/kafka-console-producer.sh --broker-list apache-kafka:9092 --topic warehouse-movement
