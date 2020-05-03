KIND ?= kind
KUBECTL ?= kubectl

TOP_SRCDIR := ../..

default: help
.PHONY: default

include $(TOP_SRCDIR)/include.mk

MANIFESTS = \
	base/service.yml \
	base/service-headless.yml \
	base/statefulset.yml \
	local/kustomization.yml

manifests: $(MANIFESTS) ## Render all manifest files
.PHONY: all

base/service.yml: $(ENV_FILE) hack/mkservice.sh
	hack/mkservice.sh $< "nfs-ganesha" "" > $@ || (rm -f $@; false)

base/service-headless.yml: $(ENV_FILE) hack/mkservice.sh
	hack/mkservice.sh $< "nfs-ganesha-headless" "clusterIP: None" > $@ || (rm -f $@; false)

base/statefulset.yml: $(ENV_FILE) hack/mkstatefulset.sh
	hack/mkstatefulset.sh $< > $@ || (rm -f $@; false)

local/kustomization.yml: $(ENV_FILE) hack/mkkustomization.sh
	hack/mkkustomization.sh $< > $@ || (rm -f $@; false)

clean: ## Remove all generated files
	rm -f $(MANIFESTS)
.PHONY: clean

kubectl-local-apply: ## Run 'kubectl apply' using the 'local' overlay
	$(KUBECTL) apply -k ./local/
.PHONY: kubectl-local-apply

kubectl-local-delete: ## Run 'kubectl delete' using the 'local' overlay
	$(KUBECTL) delete -k ./local/
.PHONY: kubectl-local-delete

check: kubectl-local-apply ## Run a test-suite
	. $(ENV_FILE) && \
		$(KUBECTL) run \
			--attach=true \
			--image=$${LOCAL_CONTAINED_GANESHA_TEST_IMAGE}:$${LOCAL_CONTAINED_GANESHA_TEST_TAG} \
			--image-pull-policy=Never \
			--restart=Never \
			--rm=true \
			--wait=true \
			contained-ganesha-test -- \
				-test.v \
				-host=nfs-ganesha \
				-portmapper-port=$${PORTMAPPER_PORT} \
				-status-port=$${STATUS_PORT} \
				-nlockmgr-port=$${NLOCKMGR_PORT} \
				-rquotad-port=$${RQUOTAD_PORT} \
				-nfs-port=$${NFS_PORT} \
				-mountd-port=$${MOUNTD_PORT}

.PHONY: check

kind-load-docker-images: | containers ## Build container images, then load local container images into a Kind cluster
	$(MAKE) kind-load-docker-images-nobuild
.PHONY: kind-load-docker-images

kind-load-docker-images-nobuild: $(ENV_FILE)
	@. $<; \
	set -ue; \
	for image in \
		$${LOCAL_RPCBIND_IMAGE}:$${LOCAL_RPCBIND_TAG} \
		$${LOCAL_RPC_STATD_IMAGE}:$${LOCAL_RPC_STATD_TAG} \
		$${LOCAL_DBUS_DAEMON_IMAGE}:$${LOCAL_DBUS_DAEMON_TAG} \
		$${LOCAL_NFS_GANESHA_IMAGE}:$${LOCAL_NFS_GANESHA_TAG} \
		$${LOCAL_GANESHA_CONFIG_RELOAD_IMAGE}:$${LOCAL_GANESHA_CONFIG_RELOAD_TAG} \
		; do \
		echo $(KIND) load docker-image $${image}; \
		$(KIND) load docker-image $${image}; \
	done
.PHONY: kind-load-docker-images-nobuild

kind-load-cgt-image: | container-contained-ganesha-test ## Build 'contained-ganesha-test' image, then load local container image into a Kind cluster
	$(MAKE) kind-load-cgt-image-nobuild
.PHONY: kind-load-cgt-image

kind-load-cgt-image-nobuild: $(ENV_FILE)
	@. $<; \
	set -ue; \
	echo $(KIND) load docker-image $${LOCAL_CONTAINED_GANESHA_TEST_IMAGE}:$${LOCAL_CONTAINED_GANESHA_TEST_TAG}; \
	$(KIND) load docker-image $${LOCAL_CONTAINED_GANESHA_TEST_IMAGE}:$${LOCAL_CONTAINED_GANESHA_TEST_TAG}
.PHONY: kind-load-cgt-image-nobuild

containers:
	$(MAKE) -C $(TOP_SRCDIR) containers
.PHONY: containers

container-contained-ganesha-test:
	$(MAKE) -C $(TOP_SRCDIR) container-contained-ganesha-test
.PHONY: container-contained-ganesha-test
