#!/bin/sh
#*****************************************************************************************************
# Created:  10.11.2020
# Updated:  11.11.2020
# Author:   Jiri Husak
#
# Script for automation of OpenShift app build,deployment and configuration
#*****************************************************************************************************


if [ $# -eq 0 ]
then
	echo "Wrong number of parameters"
        echo "use $0 --help"
        exit -1
fi

PROJECT=unknown
RECREATE=false
RECONFIG=false
DOCONFIG=false
REBUILD=false
TEST=false
SEEBUILDLOG=true
REPO_BRANCH=master
APP=unknown
APP_DEPEND=unknown
SLEEPSEC=1
#i=1
#while [ $i -le $# ]
#do
#	echo "${i}.PArameter: \${$i} "
#	break
#done

i=1
while [ $i -le $# ]
do
	#echo "${i}.parameter: \${$i} "
	eval echo "${i}.parameter: \${$i} "
	#eval echo "\${$i}"
	MYPARAM=`eval echo "\\${$i}"`
	#echo "MYPARAM:${MYPARAM}"
	case $MYPARAM in
		-app)
			i=$(( i+1 ))
			APP=`eval echo "\\${$i}"`
			echo "APP set to ${APP}"
			;;
		-project)
			i=$(( i+1 ))
			PROJECT=`eval echo "\\${$i}"`
			echo "PROJECT set to ${PROJECT}"
			;;
		-app-depend)
			i=$(( i+1 ))
			APP_DEPEND=`eval echo "\\${$i}"`
			echo "APP_DEPEND set to ${APP_DEPEND}"
			;;
		-repobranch)
			i=$(( i+1 ))
			REPO_BRANCH=`eval echo "\\${$i}"`
			echo "REPO_BRANCH set to ${REPO_BRANCH}"
			;;
		-recreate)
			RECREATE=true
			echo "RECREATE set to ${RECREATE}"
			;;
		-rebuild)
			REBUILD=true
			echo "REBUILD set to ${REBUILD}"
			;;
		-test)
			TEST=true
			echo "TEST set to ${TEST}"
			;;
		-reconfig)
			RECONFIG=true
			echo "RECONFIG set to ${RECONFIG}"
			;;
		-buildlog)
			SEEBUILDLOG=true
			echo "RECREATE set to ${RECREATE}"
			;;
		-nobuildlog)
			SEEBUILDLOG=false
			echo "RECREATE set to ${RECREATE}"
			;;
		--help)
			echo "${0} "
			echo " -project namespacename   -- set name of project"
			echo " -app appname             -- set name of application"
			echo " -app-depend appname      -- set name of application which is prerequisite"
			echo " -recreate                -- delete app and build/deploy new one"
			echo " -rebuild                 -- rebuild/redeploy app"
			echo " -test                    -- rebuild/redeploy app"
			echo " -reconfig                -- just configure deployed app"
			echo " -buildlog                -- display build log and wait"
			echo " -repobranch              -- Repo branch used - Default is master"
			echo " -nobuildlog              -- does not display build log and doesnt wait"
			echo " --help"
			echo " "
			echo "example:"
			echo "DEMO-RDS:"
			echo "1  BS RECREATE) ${0} -app rds-bs -app-depend apache-kafka -recreate -project demo-rds"
			echo "2a BFF RECREATE) ${0} -app rds-bff -app-depend apache-kafka -recreate -test -project demo-rds"
			echo "2b BFF REBUILD) ${0} -app rds-bff -app-depend apache-kafka -rebuild -test -project demo-rds"
			echo "2c BFF TEST) ${0} -app rds-bff -test -project demo-rds"
			echo "3a FE RECREATE) ${0} -app rds-fe -recreate -project demo-rds -repobranch devel_ibm_liptajova"
			echo "3b FE REBUILD) ${0} -app rds-fe -rebuild -project demo-rds -repobranch devel_ibm_liptajova"
			echo "3c FE RECONFIG) ${0} -app rds-fe -reconfig -project demo-rds"
			echo " "
			echo "DEMO-TRN:"
			echo "3  MMS RECREATE) ${0} -app mms -recreate -project demo-trn"
			echo "4  VUEJS RECREATE) ${0} -app vuejs -recreate -project demo-trn"

			exit
			;;
		*)
			echo "UNKNOWN parameter $MYPARAM"
			;;
	esac
	i=$(( i+1 ))
done


echo " "
echo "STEP 000a [===== SHOW PARAMS SET ]              *************************************************************************************"
echo "PROJECT:${PROJECT}"
echo "RECREATE:${RECREATE}"
echo "RECONFIG:${RECONFIG}"
echo "REBUILD:${REBUILD}"
echo "TEST:${TEST}"
echo "SEEBUILDLOG:${SEEBUILDLOG}"
echo "APP:${APP}"
echo "APP_DEPEND:${APP_DEPEND}"
echo "REPO_BRANCH:${REPO_BRANCH}"
echo "SLEEPSEC:${SLEEPSEC}"


echo " "
echo "STEP 000b [===== SET PROJECT ]                  *************************************************************************************"
if [ "${PROJECT}" = "unknown" ]
then
	echo "-project not set"
	$0 --help
	exit
else
	oc project ${PROJECT}
fi


echo " "
echo "STEP 000c [===== SHOW PODS ]                    *************************************************************************************"
oc get pods


if [ "${APP_DEPEND}" != "unknown" ]
then
	PODSTR="${APP_DEPEND}-"
	PREREQPOD=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $1}'`
	PREREQPODSTATUS=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $3}'`
	sleep ${SLEEPSEC}

	echo " "
	echo "STEP 001 [===== CHECK IF PREREQUISITE POD IS RUNNING] *******************************************************************************"
	if [ "${PREREQPODSTATUS}" != "Running" ]
	then
		echo "     ERROR: ${PREREQPOD} is not in status running"
		exit
	else
		echo "     PREREQ POD: ${PREREQPOD} status: ${PREREQPODSTATUS} "
	fi
fi
sleep ${SLEEPSEC}

echo " "
echo "STEP 002 [===== CHECK IF ${APP} POD IS RUNNING] *******************************************************************************************"
PODSTR="${APP}-"
echo "PODSTR:${PODSTR}"
APPPOD=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $1}'`
APPPODSTATUS=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $3}'`
echo "     ${APP} POD: ${APPPOD} status: ${APPPODSTATUS}"
sleep ${SLEEPSEC}


if [ "${RECREATE}" == "true" ]
then
	echo " "
	echo "STEP 003 [===== DELETING ${APP} APP ] *********************************************************************************************"
	oc delete all -l app=${APP}
	sleep 5

	echo " "
	echo "STEP 004a [===== NEW-APP ${APP} APP ] *********************************************************************************************"
	case ${APP} in
		rds-bs)
			oc new-app git@192.168.224.125:jkulich/adis-2.0-poc-${APP}.git  --source-secret repo-at-gitlab --name ${APP}  -e KAFKA_HOST=apache-kafka -e KAFKA_PORT=9092 -e KAFKA_CLIENT_ID=rds-bff KAFKA_TOPIC_RDS_BFF2BS=RDS_BFF2BS --strategy=docker
			res=$?
			break
			;;
		rds-bff)
			oc new-app git@192.168.224.125:jkulich/adis-2.0-poc-${APP}.git  --source-secret repo-at-gitlab --name ${APP}  -e KAFKA_HOST=apache-kafka -e KAFKA_PORT=9092 -e KAFKA_CLIENT_ID=rds-bff KAFKA_TOPIC_RDS_BFF2BS=RDS_BFF2BS KAFKA_TOPIC_DS_EVENT_LOG=DS_EVENT_LOG --strategy=docker
			res=$?
			break
			;;
		rds-fe)
			echo oc new-app git@192.168.224.125:/jkulich/adis-2.0-poc-FE.git#${REPO_BRANCH} --context-dir=adis20poc --source-secret repo-at-gitlab --name ${APP} --strategy=docker
			oc new-app git@192.168.224.125:/jkulich/adis-2.0-poc-FE.git#${REPO_BRANCH} --context-dir=adis20poc --source-secret repo-at-gitlab --name ${APP} --build-env BUILDMODE=mock -e BUILDMODEENV=mocke --strategy=docker 
			res=$?
			DOCONFIG=true
			break
			;;
#DEMO-TRN
		vuejs)
			echo "oc new-app --name vuejs https://github.com/jpiovar/poc-tz --strategy=docker"
			oc new-app --name vuejs https://github.com/jpiovar/poc-tz --strategy=docker
			res=$?
			DOCONFIG=true
			break
			;;
		mms)
			echo "oc new-app --name mms https://github.com/JiriHusak-lab/POC-T-REF-MAT  -e KAFKA_HOST=apache-kafka  -e KAFKA_PORT=9092  -e KAFKA_TOPIC=warehouse-movement -e NODE_ENV=ocp --strategy=docker"
			oc new-app --name mms https://github.com/JiriHusak-lab/POC-T-REF-MAT  -e KAFKA_HOST=apache-kafka  -e KAFKA_PORT=9092  -e KAFKA_TOPIC=warehouse-movement -e NODE_ENV=ocp --strategy=docker
			res=$?
			break
			;;
		*)
			echo "     ${APP} : new-app command not defined! "
			exit
			;;
	esac
	if [ ${res} -ne 0 ]
	then
		echo "ERROR $?"
		exit
	fi
fi


if [ "${REBUILD}" == "true" ]
then
	echo "STEP 004b [===== ${APP} REBUILD SECTION ] *******************************************************************************************"
	if [ "${APPPODSTATUS}" != "Running" ]
	then
		echo "${APPPOD} is not in status running"
		exit
	fi

	case ${APP} in
		*)
			echo "oc start-build ${APP}"
			oc start-build ${APP}
			break
			;;
	esac
fi

if [ "${RECREATE}" == "true" -o "${REBUILD}" == "true" ]
then
	sleep 5

	echo " "
	echo "STEP 005 [===== ${APP} BUILD LOG ] ************************************************************************************************"
	#PODSTR="${APP}-1-build"
	PODSTR="${APP}"
	i=0
	while [ $i -le 10 ]
	do
		#BUILDPOD=`oc get pods | grep ${PODSTR} | awk '{print $1}'`
		BUILDPOD=`oc get pods | grep ${PODSTR} | grep '\-build' | grep -v Completed | awk '{print $1}'`
		BUILDPODSTATUS=`oc get pods | grep ${PODSTR} | grep '\-build' | grep -v Completed | awk '{print $3}' | awk -F: '{print $1}'`
		echo "     ${APP} BUILD POD: ${BUILDPOD} status: ${BUILDPODSTATUS}"
		
		case ${BUILDPODSTATUS} in
			Running)
				echo "     ${BUILDPOD} is running"
				if [ "${SEEBUILDLOG}" == "true" ]
				then
					oc logs -f ${BUILDPOD}
				fi
				break
				;;
			Init|PodInitializing)
				echo "     ${BUILDPOD} is initializing"
				sleep 5
				;;
			*)
				echo "     ${BUILDPOD} - Unknown status ${BUILDPODSTATUS}"
				exit
				;;
		esac
		i=$(( i+1 ))

		if [ $i -eq 9 ]
		then
			oc logs -f ${BUILDPOD}
		fi
	done

	oc expose svc/${APP}
fi


if [ "${RECREATE}" == "true" -o "${REBUILD}" == "true" ]
then
	echo " "
	echo "STEP 006 [===== ${APP} TEST STATUS ] **********************************************************************************************"
	PODSTR="${APP}-"
	echo "PODSTR:${PODSTR}"
	i=0
	sleep 5
	while [ $i -le 20 ]
	do
		APPPOD=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $1}'`
		APPPODSTATUS=`oc get pods | grep ${PODSTR} | grep -v deploy | grep -v build | awk '{print $3}'`
		echo "     APP POD: ${APPPOD} status: ${APPPODSTATUS}"
		
		case ${APPPODSTATUS} in
			Running)
				echo "     ${APPPOD} is running"
				break
				;;
			PodInitializing)
				echo "     ${APPPOD} is initializing Pod"
				break
				;;
			ContainerCreating)
				echo "     ${APPPOD} is ContainerCreating"
				sleep 7
				;;
			*)
				echo "     ${APPPOD} - Unknown status ${APPPODSTATUS}"
				exit
				;;
		esac
		i=$(( i+1 ))
	done

	TEST=true
	echo " "
	echo "STEP 007 [===== ${APP} TEST CURL  ] ***********************************************************************************************"

fi


if [ "${RECONFIG}" == "true" ]
then
	echo " "
	echo " "
	echo "STEP 008 [===== ${APP} CONFIG SECTION ] *******************************************************************************************"
	if [ "${APPPODSTATUS}" != "Running" ]
	then
		echo "${APPPOD} is not in status running"
		exit
	fi

	oc delete cm ${APP}-config
	case ${APP} in
		vuejs)

			#	--from-literal VUE_APP_LOGIN_URL=https://xc4ezcdtcc4z247-gateway-api-poc.eu-de.mybluemix.net/login  \
			oc create configmap ${APP}-config \
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
			res=$?
			break
			;;
		rds-fe)
			echo "     Configuring rds-fe"

			oc delete route rds-fe
			oc delete route rds-fe-dev
			oc delete route rds-fe-mock

			oc delete service rds-fe
			oc delete service rds-fe-mock
			oc delete service rds-fe-dev

			oc create -f rds-fe.yaml
			oc create -f rds-fe-mock.yaml
			#oc create -f rds-fe-dev.yaml

			oc expose svc/rds-fe
			oc expose svc/rds-fe-mock
			#oc expose svc/rds-fe-dev

			#oc exec ${APPPOD} npm run mock
			#oc exec ${APPPOD} -- http-server -p 8080 dist/adis20poc

			#oc create configmap ${APP}-config \
			#--from-literal BE_ORIGIN='' \
			#--from-literal BE_INITIAL_END_POINT=http://rds-fe-demo-rds.apps-crc.testing:3000/initial \
			#--from-literal BE_ADIS_VERSION_END_POINT=http://rds-fe-demo-rds.apps-crc.testing:3000/adisVersion
			res=$?
			break
			;;
		*)
			echo "     ${APP} : config command(s) not defined! "
			exit
			;;
	esac

	oc get cm ${APP}-config

	oc get cm ${APP}-config -o json

	oc set env deployment/${APP} --from configmap/${APP}-config

	oc expose svc/${APP}
fi

if [ "${TEST}" == "true" -o "${ONLYTEST}" == "true" ]
then
	echo " "
	echo " "
	echo "STEP 009 [===== ${APP} TEST   SECTION ] *******************************************************************************************"
	oc describe build ${APP} | grep Status:
	oc describe build ${APP} | grep Started:
	oc describe build ${APP} | grep Commit:
	oc describe build ${APP} | grep Author
	sleep 5


	if [ "${APPPODSTATUS}" != "Running" ]
	then
		echo "${APPPOD} is not in status running"
		exit
	fi

	case ${APP} in
		rds-bff)
			echo "     Testing ${APP}"
			curl http://${APP}-demo-rds.apps-crc.testing/ping 2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' 
			echo " "
			echo " "
			curl http://rds-bff-demo-rds.apps-crc.testing/frontend-mocks/initial/  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' 
			echo " "
			echo " "
			curl -X GET "http://rds-bff-demo-rds.apps-crc.testing/frontend-mocks/dataTableContent" -H  "accept: */*"  2>/dev/null |  awk -F} '{m=NF;  for(i=1;i<=m;i++) print $i "}"}' 

			break
			;;
		*)
			echo "     ${APP} : TEST command(s) not defined! "
			exit
			;;
	esac
fi
