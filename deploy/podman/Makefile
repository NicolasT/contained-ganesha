PODMAN ?= podman

POD := nfs-ganesha

TOP_SRCDIR := ../..

default: help
.PHONY: default

include $(TOP_SRCDIR)/include.mk
include $(ENV_FILE)

podman-play-kube = $(PODMAN) \
			play \
			kube \
			--build=false \
			--replace

MANIFEST = contained-ganesha.yml

manifest: $(MANIFEST) ## Render the manifest files
.PHONY: manifest

$(MANIFEST): $(ENV_FILE) hack/mkmanifest.sh
	hack/mkmanifest.sh $< > $@ || (rm -f $@; false)

clean: ## Remove all generated files
	rm -f $(MANIFEST)
.PHONY: clean

up-local: $(MANIFEST) | containers ## Build container images, then run 'podman play kube' using local images.
	$(podman-play-kube) $<
.PHONY: podman-play

up-local-nobuild: $(MANIFEST) ## Run 'podman play kube' using local images. Like 'podman-play' without building.
	$(podman-play-kube) $<
.PHONY: podman-play-nobuild

down: $(MANIFEST) ## Run 'podman play kube --down'
	$(podman-play-kube) --down $<
.PHONY: down

ps: ## Run 'podman ps' for the pod
	@$(PODMAN) ps --filter pod=$(POD)
.PHONY: ps

check: | containers container-contained-ganesha-test ## Build container images, then run 'podman play kube' using local images and run a test-suite
	$(MAKE) check-nobuild
.PHONY: check

check-nobuild: $(MANIFEST) | up-local-nobuild ## Run 'podman play kube' using local images and run a test suite. Like 'check' without building.
	$(PODMAN) \
		run \
		--rm \
		--pull=never \
		--read-only \
		--cap-drop=ALL \
		--cap-add=NET_BIND_SERVICE \
		--pod=$(POD) \
		localhost/$(LOCAL_CONTAINED_GANESHA_TEST_IMAGE):$(LOCAL_CONTAINED_GANESHA_TEST_TAG) \
			-test.v \
			-host=$(POD) \
			-portmapper-port=$(PORTMAPPER_PORT) \
			-status-port=$(STATUS_PORT) \
			-nlockmgr-port=$(NLOCKMGR_PORT) \
			-rquotad-port=$(RQUOTAD_PORT) \
			-nfs-port=$(NFS_PORT) \
			-mountd-port=$(MOUNTD_PORT)
.PHONY: check-nobuild

containers:
	$(MAKE) -C $(TOP_SRCDIR) containers DOCKER=podman
.PHONY: containers

container-contained-ganesha-test:
	$(MAKE) -C $(TOP_SRCDIR) container-contained-ganesha-test DOCKER=podman
.PHONY: container-contained-ganesha-test
