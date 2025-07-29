# Emacs Integration Test Makefile

.PHONY: all test clean

all: test

test:
	@echo "Running Emacs integration tests..."
	@./run-tests.sh

test-interactive:
	@echo "Starting interactive Emacs test..."
	@emacs -nw -l ../../mal-ruby-minimal.el -l test-paredit-integration.el \
		--eval "(interactive-paredit-test)"

clean:
	@echo "Cleaning test artifacts..."
	@rm -f test-report.txt *.elc

validate-setup:
	@echo "Validating Emacs setup..."
	@emacs --batch --eval "(progn (require 'package) (package-initialize) \
		(dolist (pkg '(paredit rainbow-delimiters inf-ruby)) \
		  (if (package-installed-p pkg) \
		    (message \"✅ %s installed\" pkg) \
		    (message \"❌ %s NOT installed\" pkg))))"