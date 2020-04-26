DATE ?= date
DOCKER ?= docker
GIT ?= git

TOP_SRCDIR := .

default: help
.PHONY: default

include $(TOP_SRCDIR)/include.mk

CONTAINERS = \
	dbus-daemon \
	nfs-ganesha \
	rpc.statd \
	rpcbind

containers: $(foreach c,$(CONTAINERS),container-$(c)) ## Build all container images
.PHONY: containers

include $(ENV_FILE)

docker-build = \
	DOCKER_BUILDKIT=1 \
	$(DOCKER) build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg PORTMAPPER_PORT=$(PORTMAPPER_PORT) \
		--build-arg STATUS_PORT=$(STATUS_PORT) \
		--build-arg NLOCKMGR_PORT=$(NLOCKMGR_PORT) \
		--build-arg RQUOTAD_PORT=$(RQUOTAD_PORT) \
		--build-arg NFS_PORT=$(NFS_PORT) \
		--build-arg MOUNTD_PORT=$(MOUNTD_PORT) \
		$(CACHE_FROM) \
		--progress plain \
		--compress \
		--file $< \
		--target $(TARGET) \
		$(LABELS) \
		--pull \
		--tag $(1) \
		$(dir $<)

build-date = $(shell $(DATE) -u +"%Y-%m-%dT%H:%M:%SZ")
git-version = $(shell $(GIT) describe --tags --dirty --broken)
git-rev = $(shell $(GIT) log -n1 --format=%H)

default-labels = \
	--label org.opencontainers.image.created=$(call build-date) \
	--label org.opencontainers.image.version=$(call git-version) \
	--label org.opencontainers.image.revision=$(call git-rev) \
	--label org.opencontainers.image.ref.name=$(1) \
	\
	--label org.label-schema.build-date=$(call build-date) \
	--label org.label-schema.version=$(call git-version) \
	--label org.label-schema.vcs-ref=$(call git-rev)


container-rpcbind: TARGET=rpcbind
container-rpcbind: LABELS=$(call default-labels,$(RPCBIND_IMAGE):$(RPCBIND_TAG))
container-rpcbind: CACHE_FROM= \
			--cache-from $(RPCBIND_IMAGE):$(RPCBIND_TAG) \
			--cache-from $(RPC_STATD_IMAGE):$(RPC_STATD_TAG) \
			--cache-from $(NFS_GANESHA_IMAGE):$(NFS_GANESHA_TAG)
container-rpcbind: \
		Dockerfile \
		images/rpcbind/entrypoint.sh \
		images/rpcbind/healthcheck.sh
	$(call docker-build,$(LOCAL_RPCBIND_IMAGE):$(LOCAL_RPCBIND_TAG))
.PHONY: container-rpcbind

container-rpc.statd: TARGET=rpc.statd
container-rpc.statd: LABELS=$(call default-labels,$(RPC_STATD_IMAGE):$(RPC_STATD_TAG))
container-rpc.statd: CACHE_FROM= \
			--cache-from $(RPCBIND_IMAGE):$(RPCBIND_TAG) \
			--cache-from $(RPC_STATD_IMAGE):$(RPC_STATD_TAG) \
			--cache-from $(NFS_GANESHA_IMAGE):$(NFS_GANESHA_TAG)
container-rpc.statd: \
		Dockerfile \
		images/rpc.statd/entrypoint.sh \
		images/rpc.statd/healthcheck.sh
	$(call docker-build,$(LOCAL_RPC_STATD_IMAGE):$(LOCAL_RPC_STATD_TAG))
.PHONY: container-rpc.statd

container-dbus-daemon: TARGET=dbus-daemon
container-dbus-daemon: LABELS=$(call default-labels,$(DBUS_DAEMON_IMAGE):$(DBUS_DAEMON_TAG))
container-dbus-daemon: CACHE_FROM=--cache-from $(DBUS_DAEMON_IMAGE):$(DBUS_DAEMON_TAG)
container-dbus-daemon: \
		Dockerfile \
		images/dbus-daemon/entrypoint.sh \
		images/dbus-daemon/healthcheck.sh
	$(call docker-build,$(LOCAL_DBUS_DAEMON_IMAGE):$(LOCAL_DBUS_DAEMON_TAG))
.PHONY: container-dbus-daemon

container-nfs-ganesha: TARGET=nfs-ganesha
container-nfs-ganesha: LABELS=$(call default-labels,$(NFS_GANESHA_IMAGE):$(NFS_GANESHA_TAG))
container-nfs-ganesha: CACHE_FROM= \
				--cache-from $(RPCBIND_IMAGE):$(RPCBIND_TAG) \
				--cache-from $(RPC_STATD_IMAGE):$(RPC_STATD_TAG) \
				--cache-from $(NFS_GANESHA_IMAGE):$(NFS_GANESHA_TAG)
container-nfs-ganesha: \
		Dockerfile \
		images/nfs-ganesha/entrypoint.sh \
		images/nfs-ganesha/ganesha.conf.sh \
		images/nfs-ganesha/healthcheck.sh
	$(call docker-build,$(LOCAL_NFS_GANESHA_IMAGE):$(LOCAL_NFS_GANESHA_TAG))
.PHONY: container-nfs-ganesha

container-contained-ganesha-test: TARGET=contained-ganesha-test
container-contained-ganesha-test: LABELS=$(call default-labels,$(CONTAINED_GANESHA_TEST_IMAGE):$(CONTAINED_GANESHA_TEST_TAG))
container-contained-ganesha-test: CACHE_FROM=--cache-from $(CONTAINED_GANESHA_TEST_IMAGE):$(CONTAINED_GANESHA_TEST_TAG)
container-contained-ganesha-test: test/Dockerfile
	$(call docker-build,$(LOCAL_CONTAINED_GANESHA_TEST_IMAGE):$(LOCAL_CONTAINED_GANESHA_TEST_TAG))
.PHONY: container-contained-ganesha-test
