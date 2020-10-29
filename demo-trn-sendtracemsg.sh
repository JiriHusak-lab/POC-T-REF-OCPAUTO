#!/bin/sh

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`

echo " "
echo "STEP 001a ===== Apache-kafka POD: ${KAFKAPOD} ==============================="
echo "STEP 001b ===== MONGO POD: ${MONGOPOD} ==============================="

#echo " "
#echo "STEP 002 ===== Listing kafka topics"
#oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181


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

#echo " "
#echo "STEP 004 ===== Listing kafka topics messages - !!!!!!!!     press CONTROL-C to continue !!!!!!"
#oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic warehouse-movement --from-beginning

sleep 2

echo " "
echo "STEP 005 ===== Selecting WMJ MONGO records"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.getCollectionNames().join('\n')"
echo " "
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find()"


echo " "
echo "STEP 006 ===== using curl to test WMJ read from MONGO"
curl http://wmj-demo-trn.apps-crc.testing/journal/
echo " "
