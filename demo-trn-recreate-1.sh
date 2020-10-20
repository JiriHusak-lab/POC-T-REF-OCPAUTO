#!/bin/sh


echo " "
#echo "STEP 000 ===== Deleting project demo-trn"
#oc delete project demo-trn

echo " "
echo "STEP 001 ===== Creating project demo-trn"
oc new-project demo-trn


echo " "
echo "STEP 002 ===== Selecting project demo-trn"
oc project demo-trn


echo " "
echo "STEP 003 ===== Deleting template apache-kafka"
oc delete template apache-kafka

echo " "
echo "STEP 004 ===== Creaing template apache-kafka"
oc create -f https://raw.githubusercontent.com/JiriHusak-lab/POC-T-REF-APACHE-KAFKA/master/resources-no-pvc.yaml


echo " "
echo "STEP 005 ===== Listing templates"
oc get templates


echo " "
echo "STEP 006 ===== Describe template apache-kafka"
oc describe template apache-kafka


echo " "
echo "STEP 007 ===== Deleting apache-kafka app"
oc delete all -l app=apache-kafka

echo " "
echo "STEP 007b ===== Creating apache-kafka app"
oc new-app --name apache-kafka apache-kafka


echo " "
echo "STEP 008 ===== Deleting mongo app"
oc delete all -l app=mongo

echo " "
echo "STEP 008b ===== Creating mongo app"
oc new-app --name mongo mongo


echo " "
echo "STEP 009 ===== Listing pods"
oc get pods
