DOCKER_COMPOSE ?= docker compose

DOCKER_COMPOSE_YML = docker-compose.yml
DOCKER_COMPOSE_LOCAL_YML = docker-compose.local.yml
DOCKER_COMPOSE_TEST_YML = docker-compose.test.yml

TOP_SRCDIR := ../..

TEST_SERVICE = sut

default: help
.PHONY: default

include $(TOP_SRCDIR)/include.mk

docker-compose = $(DOCKER_COMPOSE) \
			--project-name $(PROJECT_NAME) \
			--env-file $(ENV_FILE) \
			$(foreach f,$^,--file $(f))

up: $(DOCKER_COMPOSE_YML) ## Run 'docker-compose up' using public images
	$(call docker-compose) up --no-build
.PHONY: up

up-local: $(DOCKER_COMPOSE_YML) $(DOCKER_COMPOSE_LOCAL_YML) ## Build container images, then run 'docker-compose up' using local images
	$(MAKE) -C $(TOP_SRCDIR) containers
	$(call docker-compose) up --no-build
.PHONY: up-local

down: $(DOCKER_COMPOSE_YML) ## Run 'docker-compose down'
	$(call docker-compose) down
.PHONY: down

ps: $(DOCKER_COMPOSE_YML) ## Run 'docker-compose ps'
	@$(call docker-compose) ps --all
.PHONY: ps

show-ip: $(DOCKER_COMPOSE_YML) ## Show the IP address of the NFS server
	@$(call docker-compose) \
		exec -T	rpcbind \
			/usr/sbin/ip -4 addr show eth0 \
		| $(GREP) -oP '(?<=inet\s)\d+(\.\d+){3}' || (echo "Failed to retrieve 'rpcbind' container address" > /dev/stderr; false)
.PHONY: show-ip

check: | containers container-contained-ganesha-test ## Build container images, then run 'docker-compose up' using local images and run a test-suite
	$(MAKE) check-nobuild
.PHONY: check

check-nobuild: $(DOCKER_COMPOSE_YML) $(DOCKER_COMPOSE_LOCAL_YML) $(DOCKER_COMPOSE_TEST_YML) ## Run 'docker-compose up' using local images and run a test suite. Like 'check' without building.
	$(call docker-compose) up --no-build --abort-on-container-exit --exit-code-from $(TEST_SERVICE) $(TEST_SERVICE)
.PHONY: check-nobuild

containers:
	$(MAKE) -C $(TOP_SRCDIR) containers
.PHONY: containers

container-contained-ganesha-test:
	$(MAKE) -C $(TOP_SRCDIR) container-contained-ganesha-test
.PHONY: container-contained-ganesha-test
