#!/bin/sh

echo " "
echo "POST janko   =================="
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"janko\", \"password\":\"janko\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo "POST kubo    =================="
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"kubo\", \"password\":\"kubo\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo "POST hrasko  =================="
curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"hrasko\", \"password\":\"hrasko\"}" http://apigw-demo-trn.apps-crc.testing/login
echo " "
echo "==============================="

MYTOKEN=`curl -X POST  -H "Content-Type: application/json" -g -d "{\"name\":\"janko\", \"password\":\"janko\"}" http://apigw-demo-trn.apps-crc.testing/login |  awk -F\" '{print $30}'`

echo " "
echo "TOKEN: ${MYTOKEN}"

echo "Verify Token =================="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/login/verify/

echo " "
echo "MMS PUT  ======================"
MROK=`date | awk '{print $6}'`
MMES=`date +"%-m"`
MDEN=`date +"%-d"`
MHOD=`date +"%-H"`
MMINRAW=`date +"%-M"`
MMIN=`expr ${MMINRAW} + 1`
MSEC=`date +"%-S"`
MCAS=`echo "${MHOD}${MMIN}"`
MCASSEC=`date | awk '{print $4}'`
echo "MMS PUT (cmd !!!)"
#curl PUT  -H "Content-Type: application/json" -H "ibm-sec-token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlcyI6WyJtYW5hZ2VyIl0sImlhdCI6MTU3OTcwMjA1MCwiZXhwIjoxNTc5Nzg4NDUwLCJpc3MiOiJhcGlndyIsInN1YiI6ImphbmtvQG9rLm9rIn0.wzmu4qhXSNEYxC3VGzTpxYRAEG7S3f9DlA5oKAsB5UuiYhlDekXwtqbJmR7roCHbzbM4I8GcnHr-cWAxhHhSmA" -g -d "[{\"kmat\":\"202001221604\", \"mvm\":\"wh18\",\"mnozstvi\":80,\"hmotnost\":1200}]"  http://mms-demo-trn.apps-crc.testing/Materials/mms
echo curl -X PUT  -H "Content-Type: application/json" -H "ibm-sec-token: ${MYTOKEN}" -g -d "[{\"kmat\":\"${MCAS}\", \"mvm\":\"mmswh18\",\"mnozstvi\":${MMIN},\"hmotnost\":${MDEN}${MCAS}}]"  http://apigw-demo-trn.apps-crc.testing/gateway/mms
curl -X PUT  -H "Content-Type: application/json" -H "ibm-sec-token: ${MYTOKEN}" -g -d "[{\"kmat\":\"${MCAS}\", \"mvm\":\"mmswh18\",\"mnozstvi\":${MMIN},\"hmotnost\":${MDEN}${MCAS}}]"  http://apigw-demo-trn.apps-crc.testing/gateway/mms

sleep 5


echo " "
echo "WMJ GET  ======================"
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal/
echo " "
echo "====="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal?kmat=mata
echo " "
echo "====="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/journal?hmotnost=2109

echo " "
echo "MMS GET  ======================"
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/mms
echo " "
echo "====="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/mms?kmat=mata


echo "{ \"id\":${MDEN}${MCAS}, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": ${MMIN},  \"hmotnost\": ${MCAS}, \"timestamp\":\"${MROK}-${MMES}-${MDEN}T${MCASSEC}.127z\"}" >./wmj-trace.json
#echo "{ \"id\":1, \"kmat\": \"matA\", \"mvm1\": \"wh1\", \"mvm2\": \"wh2\", \"mnozstvi\": 50,  \"hmotnost\": 200, \"timestamp\":\"2020-10-20T09:28:00.127Z\"}"
cat ./wmj-trace.json



echo " "
echo "COCO GET  ====================="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager
echo " "
echo "====="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager,worker
echo " "
