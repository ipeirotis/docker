SHELL = /bin/bash
DOCKER_PATH=class-tools-infrastructure/docker/
IMG_VERSION?=latest
GCLOUD_DATA?=shared_dataset_bucket
DEPLOYMENT_PATH=class-tools-infrastructure/deployment
PREFIX?=class-tools-infrastructure/
KUBE_EXEC?=oc
PROVIDER?=oc
export DEPLOYMENT_PATH

.PHONY: build-image push-image build-base push-base build-kubernets-su push-kubernetes-su \
	build-hub push-hub check-registry check-namespace deploy-nfs-server teardown-nfs-server \
	build-db push-db build-local-su push-local-su build-proxy push-proxy build-all push-all \
	deploy-grading-proxy teardown-grading-proxy

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

build-proxy:
	make ARG="--build-arg PREFIX=${PREFIX}" IMAGE="proxy" build-image

push-proxy: build-proxy
	make ARG="--build-arg PREFIX=${PREFIX}" IMAGE="proxy" push-image

build-all:
	make build-base
	make build-local-su

push-all: build-all
	make push-base
	make push-local-su

deploy-nfs-server: check-namespace
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/provisioner/nfs-server-gce-pv.yaml
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-server-rc.yaml
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-server-service.yaml
	${DEPLOYMENT_PATH}/${PROVIDER}/nfs/srv_ip.sh
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-pv.yaml
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-pvc.yaml

teardown-nfs-server: check-namespace
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/provisioner/nfs-server-gce-pv.yaml
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-server-rc.yaml
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-server-service.yaml
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-pv.yaml
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/${PROVIDER}/nfs/nfs-pvc.yaml

deploy-grading-proxy: check-namespace
	${DEPLOYMENT_PATH}/proxy/setup.sh
	${KUBE_EXEC} create --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/proxy/Proxy.yaml

teardown-grading-proxy: check-namespace
	${KUBE_EXEC} delete --namespace=${NAMESPACE} -f ${DEPLOYMENT_PATH}/proxy/Proxy.yaml
