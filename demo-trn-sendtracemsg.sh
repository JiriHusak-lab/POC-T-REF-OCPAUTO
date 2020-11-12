#!/bin/sh

USE_MMS_FOR_PUT=true

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
KAFKAPODSTATUS=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $3}'`
MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`
MONGOPODSTATUS=`oc get pods | grep -v coco | grep mongo- | awk '{print $3}'`
WMJPOD=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $1}'`
WMJPODSTATUS=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $3}'`
MMSPOD=`oc get pods | grep mms- | grep -v deploy | grep -v build | grep mms- | awk '{print $1}'`
MMSPODSTATUS=`oc get pods | grep mms- | grep -v deploy | grep -v build | grep mms- | awk '{print $3}'`

echo " "
echo "TASK 001 [ SHOW STATUS OF KEY PODS ] ***********************************************************************************************"
echo "     001a ===== Apache-kafka POD: ${KAFKAPOD} status: ${KAFKAPODSTATUS} ==============================="
echo "     001b ===== MONGO POD: ${MONGOPOD} status: ${MONGOPODSTATUS} ==============================="
echo "     001c ===== WMJ POD: ${WMJPOD} status: ${WMJPODSTATUS} ==============================="
echo "     001d ===== MMS POD: ${MMSPOD} status: ${MMSPODSTATUS} ==============================="


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
if [ "${USE_MMS_FOR_PUT}" == "true" ]
then
	if [ "${MMSPODSTATUS}" != "Running" ]
	then
		echo "${MMSPOD} is not in status running"
		exit
	fi
fi


#echo " "
#echo "STEP 002 ===== Listing kafka topics"
#oc exec -it -c apache-kafka ${KAFKAPOD} -- bin/kafka-topics.sh --list --zookeeper localhost:2181


echo " "
#Wed Oct 28 18:44:01 CET 2020
#MDEN=`date | awk '{print $3}'`
MROK=`date | awk '{print $6}'`
MROKSHORT=`date +"%-y"`
MMES=`date +"%-m"`
MDEN=`date +"%-d"`
MHOD=`date +"%-H"`
MMINRAW=`date +"%-M"`
MMIN=`expr ${MMINRAW} + 1`
MSEC=`date +"%-S"`
MCAS=`echo "${MHOD}${MMIN}"`
MROKCAS=`echo "${MROKSHORT}${MHOD}${MMIN}"`
MCASSEC=`date | awk '{print $4}'`
#MCASSEC=`echo "${MHOD}${MMIN}${MSEC}"`
#MCAS=`date | awk '{print $4}' | awk -F: '{print $1 $2}'`
#SET VALUES --------------------------------
KMAT=`echo "${MROK}${MMES}${MDEN}"`
MVM=stmwh4
MNOZSTVI=${MCAS}
HMOTNOST=`echo "${MDEN}${MMES}"`

echo " "
if [ "${USE_MMS_FOR_PUT}" == "true" ]
then
	echo "TASK 003b [ MMS PUT MESSAGE for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] *****************************************************************"
	echo curl -X PUT  -H "Content-Type: application/json"  -g -d "[{\"kmat\":\"${KMAT}\", \"mvm\":\"${MVM}\",\"mnozstvi\":${MNOZSTVI},\"hmotnost\":${HMOTNOST}}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
	curl -X PUT  -H "Content-Type: application/json"  -g -d "[{\"kmat\":\"${KMAT}\", \"mvm\":\"${MVM}\",\"mnozstvi\":${MNOZSTVI},\"hmotnost\":${HMOTNOST}}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
	#curl -X PUT -d 'kmat=202001140929&mvm=wh8&mnozstvi=50&hmotnost=99' http://mms-demo-trn.apps-crc.testing/Materials/mms
else
	echo "TASK 003a [ CREATE wmj-trace.json file for kmat=${KMAT} mnozstvi=${MNOZSTVI} message ] ***********************************************"
	echo "{ \"id\":${MDEN}${MCAS}, \"kmat\": \"${KMAT}\", \"mvm1\": \"${MVM}\", \"mvm2\": \"wh2\", \"mnozstvi\": ${MNOZSTVI},  \"hmotnost\": ${HMOTNOST}, \"timestamp\":\"${MROK}-${MMES}-${MDEN}T${MCASSEC}.127z\"}" >./wmj-trace.json
	cat ./wmj-trace.json
	echo " "
	echo "TASK 003b [ COPY wmj.sh wmj-trace.json into KAFKA container ] ************************************************************************"
	oc cp wmj-trace.json ${KAFKAPOD}:/opt/kafka -c apache-kafka
	oc cp wmj.sh ${KAFKAPOD}:/opt/kafka -c apache-kafka
	echo "TASK 003b [ EXECUTE wmj.sh wmj-trace.json in KAFKA container ] ***********************************************************************"

	oc exec -it -c apache-kafka ${KAFKAPOD} -- chmod 755 /opt/kafka/wmj.sh
	oc exec -it -c apache-kafka ${KAFKAPOD} -- /opt/kafka/wmj.sh wmj-trace.json
	sleep 5
fi


#echo " "
#echo "TASK 004a [ MMS .../mvms/listall ] **********************************************************************************************************"
#echo curl  http://mms-demo-trn.apps-crc.testing/mvms/listall
#curl  http://mms-demo-trn.apps-crc.testing/mvms/listall

echo " "
echo " "
echo " "
echo "TASK 004 ===== Listing kafka topics messages - for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] *****************************************************"
echo " "
echo "    !!!!!!!!     press CONTROL-C to continue !!!!!! " 
oc exec -it -c apache-kafka $KAFKAPOD -- bin/kafka-console-consumer.sh --bootstrap-server apache-kafka:9092 --topic warehouse-movement --from-beginning 2>/dev/null | grep ${MNOZSTVI} 2>/dev/null | grep ${KMAT}


echo " "
echo "TASK 005a [ MONGO FIND DATABASES ] *********************************************************************************************************"
#    mongo
#    show dbs
#    use wh-journal-docker
#    show collections
#    db.journalrecs.find()
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.getCollectionNames().join('\n')"
echo " "
echo "TASK 005b [ MONGO FIND MESSAGE for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] *********************************************************************"
#echo oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {kmat: \"${KMAT}\"} )" 
#oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {kmat: \"${KMAT}\"} )" 
#echo " "
#echo " "
#sleep 2

echo oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {kmat: \"${KMAT}\"} )" | grep ${MNOZSTVI} 
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {kmat: \"${KMAT}\"} )" 2>/dev/null | grep ${MNOZSTVI} 
echo " "
echo " "
sleep 2

#echo oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {mnozstvi: \"${MNOZSTVI}\"} )" 
#oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( {mnozstvi: \"${MNOZSTVI}\"} )" 
#echo " "
#echo " "
#sleep 2

#echo oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( )" | grep ${KMAT} | grep ${MNOZSTVI}
#oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find( )" | grep ${KMAT} | grep ${MNOZSTVI}
#echo " "
#echo " "
#sleep 2


echo " "
echo "TASK 006 [ CURL WMJ journal/ for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] ***********************************************************************"
echo "curl http://wmj-demo-trn.apps-crc.testing/journal?kmat=${KMAT} 2>/dev/null i\|  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i \"}\"}' \| grep ${MNOZSTVI}"
#curl http://wmj-demo-trn.apps-crc.testing/journal?hmotnost=${HMOTNOST}&kmat=${KMAT}
#curl http://wmj-demo-trn.apps-crc.testing/journal?kmat=${KMAT} |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}'
curl http://wmj-demo-trn.apps-crc.testing/journal?kmat=${KMAT} 2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' | grep ${MNOZSTVI}

echo " "
