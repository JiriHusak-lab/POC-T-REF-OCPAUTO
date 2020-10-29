

#oc delete all -l app=vuejs
#sleep 5
#oc new-app --name vuejs https://github.com/jpiovar/poc-tz --strategy=docker

#exit

oc delete cm vuejs-config

#	--from-literal VUE_APP_LOGIN_URL=https://xc4ezcdtcc4z247-gateway-api-poc.eu-de.mybluemix.net/login  \
oc create configmap vuejs-config \
	--from-literal VUE_APP_TITLE='POC'  \
	--from-literal VUE_APP_AUTHOR='IBM' \
	--from-literal VUE_APP_LOGIN_URL=http://apigw-demo-trn.apps-crc.testing/login \
	--from-literal VUE_APP_JOURNAL_LIMIT=20 \
	--from-literal VUE_APP_JOURNAL_URL=http://wmj-demo-trn.apps-crc.testing/journal \
	--from-literal VUE_APP_JOURNAL_FILTERS_URL=http://wmj-demo-trn.apps-crc.testingi/initialjournalFilters \
	--from-literal VUE_APP_MATERIAL_URL=http://mms-demo-trn.apps-crc.testing/Materials/mms \
	--from-literal VUE_APP_MATERIAL_MVMS=http://mms-demo-trn.apps-crc.testing/mvms/listall \
	--from-literal VUE_APP_COCO_URL=http://coco-demo-trn.apps-crc.testing/coco

#	--from-literal VUE_APP_COCO_URL=http://apigw-demo-trn.apps-crc.testing/gateway/coco

oc get cm vuejs-config

oc get cm vuejs-config -o json

oc set env deployment/vuejs --from configmap/vuejs-config

oc expose svc/vuejs
