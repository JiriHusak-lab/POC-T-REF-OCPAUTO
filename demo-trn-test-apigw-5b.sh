#!/bin/sh

echo " "
echo "TASK [ POST APIGW JANKO  ] *************************************************************************************************************"
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"janko\", \"password\":\"janko\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo "TASK [ POST APIGW KUBO   ] *************************************************************************************************************"
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"kubo\", \"password\":\"kubo\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo "TASK [ POST APIGW HRASKO ] *************************************************************************************************************"
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"hrasko\", \"password\":\"hrasko\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo " "

MYTOKEN=`curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"janko\", \"password\":\"janko\"}" http://apigw-demo-trn.apps-crc.testing/login 2>/dev/null |  awk -F\" '{print $30}'`

echo " "
echo "TOKEN: ${MYTOKEN}"

echo " "
echo "TASK [ VERIFY TOKEN      ] *************************************************************************************************************"
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/login/verify/

echo " "
echo "TASK [ MMS PUT (cmd !!!) ] *************************************************************************************************************"
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
MCASSEC=`date | awk '{print $4}'`
MROKCAS=`echo "${MROKSHORT}${MHOD}${MMIN}"`
#MCASSEC=`echo "${MHOD}${MMIN}${MSEC}"`
#MCAS=`date | awk '{print $4}' | awk -F: '{print $1 $2}'`
#SET VALUES --------------------------------
KMAT=`echo "${MROK}${MMES}${MDEN}"`
MVM=apiwh4
MNOZSTVI=${MCAS}
HMOTNOST=`echo "${MDEN}${MMES}"`

echo "TASK [ MMS PUT (cmd !!!)  MESSAGE for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] **************************************************************"
#curl PUT  -H "Content-Type: application/json" -H "ibm-sec-token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlcyI6WyJtYW5hZ2VyIl0sImlhdCI6MTU3OTcwMjA1MCwiZXhwIjoxNTc5Nzg4NDUwLCJpc3MiOiJhcGlndyIsInN1YiI6ImphbmtvQG9rLm9rIn0.wzmu4qhXSNEYxC3VGzTpxYRAEG7S3f9DlA5oKAsB5UuiYhlDekXwtqbJmR7roCHbzbM4I8GcnHr-cWAxhHhSmA" -g -d "[{\"kmat\":\"202001221604\", \"mvm\":\"wh18\",\"mnozstvi\":80,\"hmotnost\":1200}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
curl -X PUT  -H "Content-Type: application/json" -H "ibm-sec-token: ${MYTOKEN}" -g -d "[{\"kmat\":\"${KMAT}\", \"mvm\":\"${MVM}\",\"mnozstvi\":${MNOZSTVI},\"hmotnost\":${HMOTNOST}}]"  http://apigw-demo-trn.apps-crc.testing/gateway/mms

sleep 5


echo " "
echo "TASK [ WMJ GET MESSAGE for kmat=${KMAT} mnozstvi=${MNOZSTVI} ] *************************************************************************"
#echo "===== .../journal/ "
#url -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal/  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' 

echo " "
#echo "===== .../journal?kmat=mata "
echo " "
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal?kmat=${KMAT}  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' | grep ${MNOZSTVI}

#cho " "
#cho "===== .../journal?hmotnost=2109 "
#cho " "
#url -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal?hmotnost=2109  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' | grep ${MNOZSTVI}


echo " "
echo " "
echo "TASK [ WMJ GET InitialJournalFilters ] *************************************************************************************************"
echo "curl  http://apigw-demo-trn.apps-crc.testing/gateway/initialjournalFilters"
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/initialjournalFilters  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}'


#echo " "
#echo "TASK [ MMS GET           ] *************************************************************************************************************"
#curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/mms
#echo " "
#curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/mms?kmat=mata


#echo "{ \"id\":${MDEN}${MCAS}, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": ${MMIN},  \"hmotnost\": ${MCAS}, \"timestamp\":\"${MROK}-${MMES}-${MDEN}T${MCASSEC}.127z\"}" >./wmj-trace.json
#echo "{ \"id\":1, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": 50,  \"hmotnost\": 200, \"timestamp\":\"2020-10-20T09:28:00.127Z\"}"
#cat ./wmj-trace.json



echo " "
echo "TASK [ COCO GET          ] *************************************************************************************************************"
echo "===== .../coco?roles=manager "
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' 
#echo " "
#echo "===== .../coco?roles=manager,worker "
#echo " "
#curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager,worker
#echo " "
