# Quasar Makefile

.PHONY: help install uninstall test docs clean lint format check-deps

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

# SuperCollider directories
SCLANG := $(shell which sclang)
SC_EXT_DIR_MAC := $(HOME)/Library/Application\ Support/SuperCollider/Extensions
SC_EXT_DIR_LINUX := $(HOME)/.local/share/SuperCollider/Extensions
SC_EXT_DIR_WIN := $(APPDATA)/SuperCollider/Extensions

# Detect OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    SC_EXT_DIR := $(SC_EXT_DIR_MAC)
    OS := macos
endif
ifeq ($(UNAME_S),Linux)
    SC_EXT_DIR := $(SC_EXT_DIR_LINUX)
    OS := linux
endif

help: ## Show this help message
	@echo "$(GREEN)Quasar Makefile Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

install: check-deps ## Install Quasar to SuperCollider Extensions
	@echo "$(GREEN)Installing Quasar...$(NC)"
	@mkdir -p "$(SC_EXT_DIR)"
	@if [ -L "$(SC_EXT_DIR)/Quasar" ]; then \
		echo "$(YELLOW)Removing existing symlink...$(NC)"; \
		rm "$(SC_EXT_DIR)/Quasar"; \
	fi
	@ln -s "$(PWD)" "$(SC_EXT_DIR)/Quasar"
	@echo "$(GREEN)Quasar installed successfully!$(NC)"
	@echo "$(YELLOW)Remember to recompile the class library in SuperCollider$(NC)"

install-klotho: ## Install Klotho Python dependencies
	@echo "$(GREEN)Installing Klotho dependencies...$(NC)"
	@if [ ! -f Klotho/Klotho/requirements.txt ]; then \
		echo "$(RED)Error: Klotho not found$(NC)"; \
		exit 1; \
	fi
	@cd Klotho/Klotho && pip install -r requirements.txt
	@cd Klotho/Klotho && pip install -e .
	@echo "$(GREEN)Klotho installed successfully!$(NC)"

uninstall: ## Uninstall Quasar from SuperCollider Extensions
	@echo "$(YELLOW)Uninstalling Quasar...$(NC)"
	@if [ -L "$(SC_EXT_DIR)/Quasar" ]; then \
		rm "$(SC_EXT_DIR)/Quasar"; \
		echo "$(GREEN)Quasar uninstalled successfully!$(NC)"; \
	else \
		echo "$(YELLOW)Quasar not found in Extensions$(NC)"; \
	fi

test: ## Run all tests
	@echo "$(GREEN)Running Quasar tests...$(NC)"
	@sclang scripts/run_tests.scd

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	@sclang scripts/run_unit_tests.scd

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(NC)"
	@sclang scripts/run_integration_tests.scd

docs: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	@sclang scripts/generate_docs.scd
	@echo "$(GREEN)Documentation generated in docs/_build/$(NC)"

clean: ## Clean build artifacts and temporary files
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@find . -name "*~" -delete
	@find . -name ".DS_Store" -delete
	@find . -name "*.tmp" -delete
	@rm -rf docs/_build
	@rm -rf test_output
	@echo "$(GREEN)Clean complete!$(NC)"

lint: ## Check code style (basic checks)
	@echo "$(GREEN)Linting SuperCollider code...$(NC)"
	@bash scripts/lint.sh

format: ## Format code (placeholder for future formatter)
	@echo "$(YELLOW)Code formatting not yet implemented$(NC)"

check-deps: ## Check if required dependencies are installed
	@echo "$(GREEN)Checking dependencies...$(NC)"
	@command -v sclang >/dev/null 2>&1 || \
		{ echo "$(RED)Error: SuperCollider (sclang) not found$(NC)"; exit 1; }
	@echo "  $(GREEN)✓$(NC) SuperCollider found"
	@command -v python3 >/dev/null 2>&1 || \
		{ echo "$(YELLOW)Warning: Python3 not found (needed for Klotho)$(NC)"; }
	@if command -v python3 >/dev/null 2>&1; then \
		echo "  $(GREEN)✓$(NC) Python3 found"; \
	fi
	@echo "$(GREEN)Dependency check complete!$(NC)"

examples: ## List available examples
	@echo "$(GREEN)Available Examples:$(NC)"
	@ls -1 examples/*.scd 2>/dev/null | \
		sed 's/examples\//  - /' | \
		sed 's/.scd//' || \
		echo "  $(YELLOW)No examples found yet$(NC)"

version: ## Show Quasar version
	@echo "$(GREEN)Quasar Version:$(NC)"
	@grep 'version:' Quasar.quark | awk '{print "  " $$2}'

status: ## Show project status
	@echo "$(GREEN)Quasar Project Status$(NC)"
	@echo ""
	@echo "  Version:    $$(grep 'version:' Quasar.quark | awk '{print $$2}')"
	@echo "  Classes:    $$(find src -name "*.sc" | wc -l | xargs)"
	@echo "  Tests:      $$(find tests -name "Test*.sc" | wc -l | xargs)"
	@echo "  Examples:   $$(find examples -name "*.scd" | wc -l | xargs)"
	@echo "  Docs:       $$(find docs -name "*.md" | wc -l | xargs)"
	@echo ""

dev: ## Set up development environment
	@echo "$(GREEN)Setting up development environment...$(NC)"
	@$(MAKE) install
	@$(MAKE) check-deps
	@echo "$(GREEN)Development environment ready!$(NC)"

# Alias targets
i: install ## Alias for install
u: uninstall ## Alias for uninstall
t: test ## Alias for test
d: docs ## Alias for docs
c: clean ## Alias for clean

# Default target
.DEFAULT_GOAL := help
