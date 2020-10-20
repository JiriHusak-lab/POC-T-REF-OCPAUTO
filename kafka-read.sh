#!/bin/sh

if [ $# -ne 1 ]
then
	echo kafka-read.sh topic-name
	exit -1
fi


oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
TOPIC_NAME=$1

echo " "
echo "STEP 000 ===== Listing kafka topics"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181

echo " "
echo "STEP 001 ===== Listing kafka topics messages"
echo "oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic ${TOPIC_NAME} --from-beginning"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic ${TOPIC_NAME} --from-beginning
