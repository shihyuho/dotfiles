SHELL := /bin/bash

##@ General

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

source: ## Update settings while avoiding the confirmation prompt.
	set -- -f; source bootstrap.sh

brew: ## Install Homebrew formulas.
	./brew

go-install: ## Install Go executables.
	./go-install.sh
