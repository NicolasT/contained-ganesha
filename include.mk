AWK ?= awk
GREP ?= grep
PRINTF ?= printf
SORT ?= sort

ENV_FILE = $(TOP_SRCDIR)/.env

PROJECT_NAME = contained-ganesha

help:
	@$(PRINTF) "\033[94m%s\n%s\n\033[0m" "Targets" "-------"
	@$(GREP) '^[a-zA-Z]' Makefile | \
		$(AWK) -F ':.*?## ' 'NF==2 {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'
.PHONY: help
