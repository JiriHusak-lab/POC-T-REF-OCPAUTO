#!/bin/sh

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
KAFKAPODSTATUS=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $3}'`
MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`
MONGOPODSTATUS=`oc get pods | grep -v coco | grep mongo- | awk '{print $3}'`
WMJPOD=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $1}'`
WMJPODSTATUS=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $3}'`

echo " "
echo "STEP 001a ===== Apache-kafka POD: ${KAFKAPOD} status: ${KAFKAPODSTATUS} ==============================="
echo "STEP 001b ===== MONGO POD: ${MONGOPOD} status: ${MONGOPODSTATUS} ==============================="


if [ "${KAFKAPODSTATUS}" != "Running" ]
then
	echo "${KAFKAPOD} is not in status running"
	exit
fi
if [ "${WMJPODSTATUS}" != "Running" ]
then
	echo "${WMJPOD} is not in status running"
	exit
fi
if [ "${MONGOPODSTATUS}" != "Running" ]
then
	echo "${MONGOPOD} is not in status running"
	exit
fi


#echo " "
#echo "STEP 002 ===== Listing kafka topics"
#oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-topics.sh --list --zookeeper localhost:2181


echo " "
echo "STEP 003a ===== Creating wmj-trace.json file"
#Wed Oct 28 18:44:01 CET 2020
#MDEN=`date | awk '{print $3}'`
MROK=`date | awk '{print $6}'`
MMES=`date +"%-m"`
MDEN=`date +"%-d"`
MHOD=`date +"%-H"`
MMINRAW=`date +"%-M"`
MMIN=`expr ${MMINRAW} + 1`
MSEC=`date +"%-S"`
MCAS=`echo "${MHOD}${MMIN}"`
#MCASSEC=`echo "${MHOD}${MMIN}${MSEC}"`
#MCAS=`date | awk '{print $4}' | awk -F: '{print $1 $2}'`
MCASSEC=`date | awk '{print $4}'`

echo "{ \"id\":${MDEN}${MCAS}, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": ${MMIN},  \"hmotnost\": ${MCAS}, \"timestamp\":\"${MROK}-${MMES}-${MDEN}T${MCASSEC}.127z\"}" >./wmj-trace.json
#echo "{ \"id\":1, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": 50,  \"hmotnost\": 200, \"timestamp\":\"2020-10-20T09:28:00.127Z\"}"
cat ./wmj-trace.json

echo "MMS PUT (cmd !!!)"
#curl PUT  -H "Content-Type: application/json" -H "ibm-sec-token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlcyI6WyJtYW5hZ2VyIl0sImlhdCI6MTU3OTcwMjA1MCwiZXhwIjoxNTc5Nzg4NDUwLCJpc3MiOiJhcGlndyIsInN1YiI6ImphbmtvQG9rLm9rIn0.wzmu4qhXSNEYxC3VGzTpxYRAEG7S3f9DlA5oKAsB5UuiYhlDekXwtqbJmR7roCHbzbM4I8GcnHr-cWAxhHhSmA" -g -d "[{\"kmat\":\"202001221604\", \"mvm\":\"wh18\",\"mnozstvi\":80,\"hmotnost\":1200}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
echo curl -X PUT  -H "Content-Type: application/json"  -g -d "[{\"kmat\":\"${MCAS}\", \"mvm\":\"wh18\",\"mnozstvi\":${MMIN},\"hmotnost\":${MDEN}${MCAS}}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
curl -X PUT  -H "Content-Type: application/json"  -g -d "[{\"kmat\":\"${MCAS}\", \"mvm\":\"mmswh18\",\"mnozstvi\":${MMIN},\"hmotnost\":${MDEN}${MCAS}}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
#curl -X PUT -d 'kmat=202001140929&mvm=wh8&mnozstvi=50&hmotnost=99' http://mms-demo-trn.apps-crc.testing/Materials/mms


echo " "
echo "STEP 003b ===== Copying wmj sh and json files"
oc cp wmj-trace.json ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc cp wmj.sh ${KAFKAPOD}:/opt/kafka -c apache-kafka
oc exec -it -c apache-kafka ${KAFKAPOD} -- chmod 755 /opt/kafka/wmj.sh
oc exec -it -c apache-kafka ${KAFKAPOD} -- /opt/kafka/wmj.sh wmj-trace.json
sleep 5

echo " "
echo "STEP 004 ===== Listing kafka topics messages - !!!!!!!!     press CONTROL-C to continue !!!!!!"
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic warehouse-movement --from-beginning

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
