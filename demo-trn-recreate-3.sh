#!/bin/sh

oc get pods
KAFKAPOD=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $1}'`
KAFKAPODSTATUS=`oc get pods | grep -v apache-kafka-1-deploy | grep apache-kafka-1- | awk '{print $3}'`

MONGOPOD=`oc get pods | grep -v coco | grep mongo- | awk '{print $1}'`
MONGOPODSTATUS=`oc get pods | grep -v coco | grep mongo- | awk '{print $3}'`

COCOMONGOPOD=`oc get pods | grep coco | grep coco-mongo- | awk '{print $1}'`
COCOMONGOPODSTATUS=`oc get pods | grep coco | grep coco-mongo- | awk '{print $3}'`

WMJPOD=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $1}'`
WMJPODSTATUS=`oc get pods | grep wmj- | grep -v deploy | grep -v build | grep wmj- | awk '{print $3}'`

COCOPOD=`oc get pods | grep coco- | grep -v deploy | grep -v build | grep -v mongo | grep coco- | awk '{print $1}'`
COCOPODSTATUS=`oc get pods | grep coco- | grep -v deploy | grep -v build | grep -v mongo | grep coco- | awk '{print $3}'`

echo " "
echo "STEP 001b ===== MONGO POD: ${MONGOPOD} status: ${MONGOPODSTATUS}==============================="
echo "STEP 001b ===== WMJ POD: ${WMJPOD} status: ${WMJPODSTATUS}==============================="
echo "STEP 001b ===== COCO POD: ${COCOPOD} status: ${COCOPODSTATUS}==============================="
echo "STEP 001b ===== COCOMONGO POD: ${COCOMONGOPOD} status: ${COCOMONGOPODSTATUS}==============================="

if [ "${WMJPODSTATUS}" != "Running" ]
then
	echo "${WMJPOD} is not in status running"
	exit
fi
if [ "${COCOPODSTATUS}" != "Running" ]
then
	echo "${COCOPOD} is not in status running"
	exit
fi


echo " "
echo "STEP 020 ===== Exposing services coco, wmj"
oc expose svc/coco
oc expose svc/wmj
sleep 6


echo " "
echo "STEP 021 ===== using curl to setup coco"
curl -X PUT -H "Content-Type: application/json" -g -d\
"[\
{ \"role\": \"admin\", \"content_id\": \"pwhjj\", \"read\": false, \"write\": false} ,\
{ \"role\": \"admin\", \"content_id\": \"pwhjj-home\", \"read\": true, \"write\": false},\
{ \"role\": \"admin\", \"content_id\": \"pwhjj-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"admin\", \"content_id\": \"pwhjj-agendaAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"admin\", \"content_id\": \"pwhjj-userAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"admin\", \"content_id\": \"pwhjj-roleAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"admin\", \"content_id\": \"rm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"admin\", \"content_id\": \"rm-home\", \"read\": true, \"write\": false},\
{ \"role\": \"admin\", \"content_id\": \"rm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"admin\", \"content_id\": \"sm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"admin\", \"content_id\": \"sm-home\", \"read\": true, \"write\": false} ,\
{ \"role\": \"admin\", \"content_id\": \"sm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"admin\", \"content_id\": \"pm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"admin\", \"content_id\": \"pm-home\", \"read\": true, \"write\": true} ,\
{ \"role\": \"admin\", \"content_id\": \"pm-personalAdministration\", \"read\": true, \"write\": true}\
]" http://coco-demo-trn.apps-crc.testing/coco

curl -X PUT -H "Content-Type: application/json" -g -d\
"[\
{ \"role\": \"manager\", \"content_id\": \"pwhjj\", \"read\": false, \"write\": false} ,\
{ \"role\": \"manager\", \"content_id\": \"pwhjj-home\", \"read\": true, \"write\": false},\
{ \"role\": \"manager\", \"content_id\": \"pwhjj-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"manager\", \"content_id\": \"pwhjj-agendaAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"manager\", \"content_id\": \"pwhjj-userAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"manager\", \"content_id\": \"pwhjj-roleAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"manager\", \"content_id\": \"rm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"manager\", \"content_id\": \"rm-home\", \"read\": true, \"write\": false},\
{ \"role\": \"manager\", \"content_id\": \"rm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"manager\", \"content_id\": \"sm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"manager\", \"content_id\": \"sm-home\", \"read\": true, \"write\": false} ,\
{ \"role\": \"manager\", \"content_id\": \"sm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"manager\", \"content_id\": \"pm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"manager\", \"content_id\": \"pm-home\", \"read\": true, \"write\": true} ,\
{ \"role\": \"manager\", \"content_id\": \"pm-personalAdministration\", \"read\": true, \"write\": true}\
]" http://coco-demo-trn.apps-crc.testing/coco

curl -X PUT -H "Content-Type: application/json" -g -d\
"[\
{ \"role\": \"worker\", \"content_id\": \"pwhjj\", \"read\": false, \"write\": false} ,\
{ \"role\": \"worker\", \"content_id\": \"pwhjj-home\", \"read\": true, \"write\": false},\
{ \"role\": \"worker\", \"content_id\": \"pwhjj-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"worker\", \"content_id\": \"pwhjj-agendaAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"worker\", \"content_id\": \"pwhjj-userAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"worker\", \"content_id\": \"pwhjj-roleAdministration\", \"read\": true, \"write\": true},\
{ \"role\": \"worker\", \"content_id\": \"rm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"worker\", \"content_id\": \"rm-home\", \"read\": true, \"write\": false},\
{ \"role\": \"worker\", \"content_id\": \"rm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"worker\", \"content_id\": \"sm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"worker\", \"content_id\": \"sm-home\", \"read\": true, \"write\": false} ,\
{ \"role\": \"worker\", \"content_id\": \"sm-personalAdministration\", \"read\": true, \"write\": true} ,\
{ \"role\": \"worker\", \"content_id\": \"pm\", \"read\": false, \"write\": false} ,\
{ \"role\": \"worker\", \"content_id\": \"pm-home\", \"read\": true, \"write\": true} ,\
{ \"role\": \"worker\", \"content_id\": \"pm-personalAdministration\", \"read\": true, \"write\": true}\
]" http://coco-demo-trn.apps-crc.testing/coco



echo " "
echo "STEP 100 ===== SANITY TESTS"

echo " "
echo "STEP 101a ===== using curl to test coco setup"
curl http://coco-demo-trn.apps-crc.testing/coco?roles=admin,worker

echo " "
echo "STEP 101b ===== Selecting COCO MONGO records"
oc exec -it ${COCOMONGOPOD} -- mongo coco --eval "db.getCollectionNames().join('\n')"
oc exec -it ${COCOMONGOPOD} -- mongo coco --eval "db.rights.find()"


echo " "
#echo "STEP 008B ===== Copying getMongo.js file"
#oc cp getMongo.js ${MONGOPOD}:/tmp/ 
#oc exec -it ${MONGOPOD} -- chmod 755 /tmp/getMongo.js
#oc exec -it ${MONGOPOD} -- mongo /tmp/getMongo.js


echo " "
echo "STEP 102 ===== Selecting WMJ MONGO records"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.getCollectionNames().join('\n')"
oc exec -it ${MONGOPOD} -- mongo wh-journal-docker --eval "db.journalrecs.find()"


echo " "
echo "STEP 103 ===== using curl to test WMJ read from mongo"
curl http://wmj-demo-trn.apps-crc.testing/journal/
echo " "
curl http://wmj-demo-trn.apps-crc.testing/journal/?kmat=matA
