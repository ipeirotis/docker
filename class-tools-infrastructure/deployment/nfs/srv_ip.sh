#!/bin/bash

SERVICE_IP=`kubectl describe service --namespace ${NAMESPACE} nfs-server | grep 'IP:' | awk -F ' ' '{print $2}'`
sed -i "s/.*server: .*/    server: $SERVICE_IP/" $DEPLOYMENT_PATH/nfs/nfs-pv.yaml

