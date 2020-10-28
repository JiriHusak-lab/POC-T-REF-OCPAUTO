#!/bin/sh

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`

echo " "
echo "STEP 001 ===== Apache-kafka POD: $KAFKAPODi ==============================="

echo " "
echo "STEP 002 ===== Listing kafka topics"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181

echo " "
echo "STEP 003b ===== Copying wmj sh and json files"
oc cp wmj-trace.json ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc cp wmj.sh ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc exec -it -c apache-kafka ${KAFKAPOD} -- chmod 755 /opt/kafka/wmj.sh
oc exec -it -c apache-kafka ${KAFKAPOD} -- /opt/kafka/wmj.sh
sleep 5

echo " "
echo "STEP 004b ===== Listing kafka topics messages - !!!!!!!!     press CONTROL-C to continue !!!!!!"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic warehouse-movement --from-beginning

echo " "
echo "STEP 008C ===== Selecting mongo records"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.getCollectionNames().join('\n')"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find()"
