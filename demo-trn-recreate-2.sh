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
echo "STEP 003 ===== Creating kafka topic"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic warehouse-movement
sleep 5

echo " "
echo "STEP 003b ===== Copying wmj sh and json files"
oc cp wmj.json ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc cp wmj.sh ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc exec -it -c apache-kafka ${KAFKAPOD} -- chmod 755 /opt/kafka/wmj.sh
oc exec -it -c apache-kafka ${KAFKAPOD} -- /opt/kafka/wmj.sh wmj.json
sleep 5

echo " "
echo "STEP 004 ===== Listing kafka topics"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181

echo " "
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
#echo "STEP 008B ===== Copying getMongo.js file"
#oc cp getMongo.js ${MONGOPOD}:/tmp/ 
#oc exec -it ${MONGOPOD} -- chmod 755 /tmp/getMongo.js
#oc exec -it ${MONGOPOD} -- mongo /tmp/getMongo.js


echo " "
echo "STEP 008C ===== Selecting mongo records"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.getCollectionNames().join('\n')"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find()"


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
