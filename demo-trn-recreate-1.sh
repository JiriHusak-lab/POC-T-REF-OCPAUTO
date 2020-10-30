#!/bin/sh

if [ $# -ne 1 ]
then
	echo "Wrong number of parameters"
        echo "$0 nopersist | persist"
        exit -1
fi

#echo " "
#echo "STEP 000 ===== Deleting project demo-trn"
#oc delete project demo-trn
#sleep 5

echo " "
echo "STEP 001 ===== Creating project demo-trn"
oc new-project demo-trn


echo " "
echo "STEP 002 ===== Selecting project demo-trn"
oc project demo-trn


echo " "
echo "STEP 003 ===== Deleting template apache-kafka"
oc delete template apache-kafka
oc delete template apache-kafka-pv

echo " "
echo "STEP 004 ===== Creaing template apache-kafka"
oc create -f https://raw.githubusercontent.com/JiriHusak-lab/POC-T-REF-APACHE-KAFKA/master/resources-no-pvc.yaml
oc create -f https://raw.githubusercontent.com/JiriHusak-lab/POC-T-REF-APACHE-KAFKA/master/resources-no-pv.yaml


echo " "
echo "STEP 005 ===== Listing templates"
oc get templates


#echo " "
#echo "STEP 006 ===== Describe template apache-kafka"
#oc describe template apache-kafka

echo " "
echo "STEP 007 ===== Deleting apache-kafka app"
oc delete all -l app=apache-kafka

echo " "
echo "STEP 007b ===== Creating apache-kafka app"
if [ "$1" == "nopersist" ]
then
	echo "recreating Kafka without persistance =================="
	oc new-app --name apache-kafka apache-kafka
fi
if [ "$1" == "persist" ]
then

	KAFKAPVC=`oc get pvc | grep apache-kafka | awk '{print $1}'`
	KAFKAPVCSTATUS=`oc get pvc | grep apache-kafka | awk '{print $2}'`
	ZOOKEEPERPVC=`oc get pvc | grep apache-zookeeper | awk '{print $1}'`
	ZOOKEEPERPVCSTATUS=`oc get pvc | grep apache-zookeeper | awk '{print $2}'`
	echo "===== APACHE_KAFKA PVC: ${KAFKAPVC} status: ${KAFKAPVCSTATUS}==============================="
	echo "===== APACHE_ZOOKEEPER PVC: ${ZOOKEEPERPVC} status: ${ZOOKEEPERPVCSTATUS}==============================="

	if [ "${KAFKAPVCSTATUS}" != "Bound" ]
	then
		echo "${KAFKAPVC} is not in status Bound"
		exit
	fi
	if [ "${ZOOKEEPERPVCSTATUS}" != "Bound" ]
	then
		echo "${ZOOKEEPERPVC} is not in status Bound"
		exit
	fi

	echo "recreating Kafka with persistance =================="
	oc new-app --name apache-kafka apache-kafka-pv
fi

echo " "
echo "STEP 008 ===== Deleting mongo app"
oc delete all -l app=mongo

echo " "
echo "STEP 008b ===== Creating mongo app"
oc new-app --name mongo mongo


echo " "
echo "STEP 009 ===== Listing pods"
oc get pods
