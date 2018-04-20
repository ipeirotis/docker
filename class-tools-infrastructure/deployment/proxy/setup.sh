#!/bin/bash

SERVICE_IP=`kubectl describe service --namespace ${NAMESPACE} hub | grep 'IP:' | awk -F ' ' '{print $2}'`
sed -i "s/API_URL_PLACEHOLDER/ http:\/\/$SERVICE_IP:8081\/hub\/api/" $DEPLOYMENT_PATH/proxy/Proxy.yaml
sed -i "s/ HUB_NAMESPACE_PLACEHOLDER/ ${NAMESPACE}/" $DEPLOYMENT_PATH/proxy/Proxy.yaml
