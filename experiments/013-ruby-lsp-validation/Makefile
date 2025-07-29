.PHONY: all test validate install clean help submodules

all: help

help:
	@echo "Ruby LSP Validation Experiment"
	@echo ""
	@echo "  make install   - Install Ruby LSP"
	@echo "  make validate  - Run validation tests"
	@echo "  make test      - Alias for validate"
	@echo "  make submodules - Initialize submodules for deep analysis"
	@echo "  make clean     - Remove test files"

install:
	@echo "Installing Ruby LSP..."
	@gem install ruby-lsp || (echo "Failed to install ruby-lsp"; exit 1)
	@echo ""
	@echo "Ruby LSP installed successfully!"

validate: 
	@bash validate-ruby-lsp.sh

test: validate

clean:
	@rm -f lsp-test-request.json mal-lsp-test.rb
	@echo "Cleaned up test files"

submodules:
	@echo "Setting up submodules for LSP analysis..."
	@mkdir -p ../../test
	@if [ ! -d "../../test/ruby-lsp-internals" ]; then \
		cd ../.. && git submodule add https://github.com/Shopify/ruby-lsp test/ruby-lsp-internals; \
	else \
		echo "ruby-lsp-internals submodule already exists"; \
	fi
	@if [ ! -d "../../test/emacs-lsp-mode" ]; then \
		cd ../.. && git submodule add https://github.com/emacs-lsp/lsp-mode test/emacs-lsp-mode; \
	else \
		echo "emacs-lsp-mode submodule already exists"; \
	fi
	@cd ../.. && git submodule update --init --recursive
	@echo ""
	@echo "Submodules initialized. You can now explore:"
	@echo "  - test/ruby-lsp-internals/ - Ruby LSP implementation"
	@echo "  - test/emacs-lsp-mode/ - Emacs LSP mode implementation"