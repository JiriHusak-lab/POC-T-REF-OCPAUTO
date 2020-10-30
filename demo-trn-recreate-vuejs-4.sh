#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Wrong number of parameters"
        echo "$0 recreate | config"
        exit -1
fi

VUEJSPOD=`oc get pods | grep vuejs- | grep -v deploy | grep -v build | grep vuejs- | awk '{print $1}'`
VUEJSPODSTATUS=`oc get pods | grep vuejs- | grep -v deploy | grep -v build | grep vuejs- | awk '{print $3}'`
echo "STEP 001b ===== VUEJS POD: ${VUEJSPOD} status: ${VUEJSPODSTATUS}==============================="


if [ "$1" == "recreate" ]
then
	echo "recreating app =================="
	oc delete all -l app=vuejs
	sleep 5
	oc new-app --name vuejs https://github.com/jpiovar/poc-tz --strategy=docker

	exit
fi

if [ "$1" == "config" ]
then
	if [ "${VUEJSPODSTATUS}" != "Running" ]
	then
		echo "${VUEJSPOD} is not in status running"
		exit
	fi

	oc delete cm vuejs-config

	#	--from-literal VUE_APP_LOGIN_URL=https://xc4ezcdtcc4z247-gateway-api-poc.eu-de.mybluemix.net/login  \
	oc create configmap vuejs-config \
	--from-literal VUE_APP_TITLE='POC'  \
	--from-literal VUE_APP_AUTHOR='IBM' \
	--from-literal VUE_APP_LOGIN_URL=http://apigw-demo-trn.apps-crc.testing/login \
	--from-literal VUE_APP_JOURNAL_LIMIT=20 \
	--from-literal VUE_APP_JOURNAL_URL=http://wmj-demo-trn.apps-crc.testing/journal \
	--from-literal VUE_APP_JOURNAL_FILTERS_URL=http://wmj-demo-trn.apps-crc.testing/initialjournalFilters \
	--from-literal VUE_APP_MATERIAL_URL=http://mms-demo-trn.apps-crc.testing/Materials/mms \
	--from-literal VUE_APP_MATERIAL_MVMS=http://mms-demo-trn.apps-crc.testing/mvms/listall \
	--from-literal VUE_APP_COCO_URL=http://coco-demo-trn.apps-crc.testing/coco

	#	--from-literal VUE_APP_COCO_URL=http://apigw-demo-trn.apps-crc.testing/gateway/coco

	oc get cm vuejs-config

	oc get cm vuejs-config -o json

	oc set env deployment/vuejs --from configmap/vuejs-config

	oc expose svc/vuejs
fi
