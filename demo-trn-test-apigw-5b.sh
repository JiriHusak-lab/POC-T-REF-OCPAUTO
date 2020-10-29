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

echo " "
echo "COCO GET  ====================="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager
echo " "
echo "====="
curl -H "ibm-sec-token: ${MYTOKEN}" http://apigw-demo-trn.apps-crc.testing/gateway/coco?roles=manager,worker
echo " "
