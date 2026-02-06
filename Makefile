.PHONY: help install brew test check-tool check-deps update-aliases measure-startup

DOTFILES_ROOT := $(shell pwd)
SCRIPTS_DIR := .agents/skills/dotfiles-manager/scripts

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Installation

install: ## Install dotfiles (create symlinks)
	@./install.sh

brew: ## Install Homebrew packages from Brewfile
	@brew bundle --file=brew/Brewfile

setup: install brew ## Complete setup (install + brew)
	@echo ""
	@echo "✨ Setup complete! Restart your shell: exec zsh"

##@ Testing & Verification

test: ## Run all tests (syntax + startup speed + symlinks)
	@$(SCRIPTS_DIR)/test.sh

measure-startup: ## Measure detailed startup speed with zprof
	@$(SCRIPTS_DIR)/measure-startup.sh

##@ Tool Management

check-tool: ## Check tool status (usage: make check-tool TOOL=kubectl)
	@if [ -z "$(TOOL)" ]; then \
		echo "Usage: make check-tool TOOL=<tool-name>"; \
		echo "Example: make check-tool TOOL=kubectl"; \
		exit 1; \
	fi
	@$(SCRIPTS_DIR)/check-tool-status.sh $(TOOL)

check-deps: ## Check dependencies before removing (usage: make check-deps TOOL=kubectl)
	@if [ -z "$(TOOL)" ]; then \
		echo "Usage: make check-deps TOOL=<tool-name>"; \
		echo "Example: make check-deps TOOL=colima"; \
		exit 1; \
	fi
	@$(SCRIPTS_DIR)/check-dependencies.sh $(TOOL)

##@ Maintenance

update-aliases: ## Update external alias files (usage: make update-aliases [TARGET=kubectl|gitalias|all])
	@if [ -z "$(TARGET)" ]; then \
		$(SCRIPTS_DIR)/update-aliases.sh all; \
	else \
		$(SCRIPTS_DIR)/update-aliases.sh $(TARGET); \
	fi
