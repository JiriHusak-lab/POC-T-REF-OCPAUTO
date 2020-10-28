#!/bin/sh

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`

echo " "
echo "STEP 001a ===== Apache-kafka POD: ${KAFKAPOD} ==============================="
echo "STEP 001b ===== MONGO POD: ${MONGOPOD} ==============================="

echo " "
echo "STEP 002 ===== Listing kafka topics"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181

echo " "
echo "STEP 003 ===== Creating kafka topic"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic warehouse-movement
sleep 5


echo " "
echo "STEP 003a ===== Creating wmj-trace.json file"
#Wed Oct 28 18:44:01 CET 2020
#MDEN=`date | awk '{print $3}'`
MDEN=`date +"%-d"`
MCAS=`date | awk '{print $4}' | awk -F: '{print $1 $2}'`
MCASSEC=`date | awk '{print $4}'`
MROK=`date | awk '{print $6}'`
MMES=`date +"%-m"`
#MMIN=`date | awk '{print $4}' | awk -F: '{print $2}'`
MMINRAW=`date +"%-M"`
MMIN=`expr ${MMINRAW} + 1`

echo "{ \"id\":${MDEN}${MCAS}, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": ${MMIN},  \"hmotnost\": ${MCAS}, \"timestamp\":\"${MROK}-${MMES}-${MDEN}T${MCASSEC}.127z\"}" >./wmj-trace.json
#echo "{ \"id\":1, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": 50,  \"hmotnost\": 200, \"timestamp\":\"2020-10-20T09:28:00.127Z\"}"
cat ./wmj-trace.json


echo " "
echo "STEP 003b ===== Copying wmj sh and json files"
oc cp wmj-trace.json ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc cp wmj.sh ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc exec -it -c apache-kafka ${KAFKAPOD} -- chmod 755 /opt/kafka/wmj.sh
oc exec -it -c apache-kafka ${KAFKAPOD} -- /opt/kafka/wmj.sh wmj-trace.json
sleep 5

echo " "
echo "STEP 004 ===== Listing kafka topics"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181

echo " "
echo "!!!!!!!!     press CONTROL-C to continue !!!!!! after topic messages are shown"
echo "STEP 004b ===== Listing kafka topics messages - !!!!!!!!     press CONTROL-C to continue !!!!!!"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic warehouse-movement --from-beginning

echo " "
echo "STEP 005 ===== Delete wmj"
oc delete all -l app=wmj
sleep 5

echo " "
echo "STEP 006 ===== Creating wmj"
oc new-app --name wmj https://github.com/JiriHusak-lab/POC-T-REF-WMJ  -e MONGODB_URL=mongodb://mongo:27017/wh-journal-docker -e KAFKA_HOST=apache-kafka -e KAFKA_PORT=9092 -e KAFKA_TOPIC=warehouse-movement --strategy=docker


echo " "
echo "STEP 007 ===== Delete mms"
oc delete all -l app=mms
sleep 5

echo " "
echo "STEP 008 ===== Creating mms"
oc new-app --name mms https://github.com/JiriHusak-lab/POC-T-REF-MAT  -e KAFKA_HOST=apache-kafka  -e KAFKA_PORT=9092  -e KAFKA_TOPIC=warehouse-movement -e NODE_ENV=ocp --strategy=docker


echo " "
echo "STEP 009 ===== Delete coco-mongo"
oc delete all -l app=coco-mongo
sleep 10

echo " "
echo "STEP 010 ===== Creating coco-mongo"
oc new-app --name coco-mongo mongo


echo " "
echo "STEP 011 ===== Delete coco"
oc delete all -l app=coco
sleep 10

echo " "
echo "STEP 012 ===== Creating coco"
oc new-app --name coco https://github.com/JiriHusak-lab/POC-T-REF-COCO  -e MONGODB_URL=mongodb://coco-mongo:27017/coco --strategy=docker
