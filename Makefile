SHELL = /bin/bash
DOCKER_PATH=class-tools-infrastructure/docker/
IMG_VERSION?=latest
GCLOUD_DATA?=shared_dataset_bucket
DEPLOYMENT_PATH=class-tools-infrastructure/deployment/
export DEPLOYMENT_PATH

.PHONY: build-image push-image build-base push-base build-kubernets-su push-kubernetes-su \
	build-hub push-hub check-registry check-namespace deploy-nfs-server teardown-nfs-server \
	build-db push-db build-local-su push-local-su build-all push-all

check-registry:
ifndef DOCKER_REGISTRY
	$(error DOCKER_REGISTRY not set)
endif

check-namespace:
ifndef NAMESPACE
	$(error NAMESPACE not set)
endif

build-image: check-registry
	docker build -f ${DOCKER_PATH}/${IMAGE}/Dockerfile ${ARG} \
	    --build-arg FILE_PATH=${DOCKER_PATH}/${IMAGE} -t $(DOCKER_REGISTRY):$(IMAGE)-$(IMG_VERSION) .

push-image: check-registry build-image
	docker push $(DOCKER_REGISTRY):$(IMAGE)-$(IMG_VERSION)

build-base:
	make IMAGE="base" build-image

push-base: build-base
	make IMAGE="base" push-image

build-kubernetes-su:
	make ARG="--build-arg GCLOUD_DATA=${GCLOUD_DATA}" IMAGE="kubernetes-su" build-image

push-kubernetes-su: build-kubernetes-su
	make ARG="--build-arg GCLOUD_DATA=${GCLOUD_DATA}" IMAGE="kubernetes-su" push-image

build-local-su:
	make IMAGE="local-su" build-image

push-local-su: build-local-su
	make IMAGE="local-su" push-image

build-hub:
	make IMAGE="hub" build-image

push-hub: build-hub
	make IMAGE="hub" push-image

build-db:
	make IMAGE="db" build-image

push-db: build-db
	make IMAGE="db" push-image

build-all: 
	make build-base 
	make build-kubernetes-su 
	make build-local-su
	make build-db

push-all: build-all
	make push-base 
	make push-kubernetes-su 
	make push-local-su
	make push-db

deploy-nfs-server: check-namespace
	kubectl create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/provisioner/nfs-server-gce-pv.yaml
	kubectl create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-server-rc.yaml
	kubectl create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-server-service.yaml
	${DEPLOYMENT_PATH}nfs/srv_ip.sh
	kubectl create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-pv.yaml
	kubectl create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-pvc.yaml

teardown-nfs-server: check-namespace
	kubectl delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/provisioner/nfs-server-gce-pv.yaml
	kubectl delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-server-rc.yaml
	kubectl delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-server-service.yaml
	kubectl delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-pv.yaml
	kubectl delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}nfs/nfs-pvc.yaml
