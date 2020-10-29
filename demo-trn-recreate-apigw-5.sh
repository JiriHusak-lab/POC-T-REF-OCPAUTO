#!/bin/sh

#oc delete all -l app=apigw
#sleep 5
#oc new-app --name apigw https://github.com/JiriHusak-lab/POC-T-REF-APIGW   --strategy=docker

oc delete cm apigw-config

#	--from-literal VUE_APP_LOGIN_URL=https://xc4ezcdtcc4z247-gateway-api-poc.eu-de.mybluemix.net/login  \
oc create configmap apigw-config \
	--from-literal RUNTIME_MODE=container \
	--from-literal APP_ANAT_URL=http://apigw:3005/login  \
	--from-literal APP_ANAT_HOST=apigw  \
	--from-literal APP_JOURNAL_URL=http://wmj-demo-trn.apps-crc.testing/ \
	--from-literal APP_JOURNAL_GET_PATH=journal \
	--from-literal APP_JOURNAL_POST_PATH=xxx \
	--from-literal APP_MATERIAL_URL=http://mms-demo-trn.apps-crc.testing/ \
	--from-literal APP_MATERIAL_GET_PATH=Materials/mms \
	--from-literal APP_MATERIAL_POST_PATH=Materials/mms \
	--from-literal APP_COCO_URL=http://coco-demo-trn.apps-crc.testing/ \
	--from-literal APP_COCO_GET_PATH=coco


oc get cm apigw-config

oc get cm apigw-config -o json

#exit

oc set env deployment/apigw --from configmap/apigw-config

oc expose svc/apigw

