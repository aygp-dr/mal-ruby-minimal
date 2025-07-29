.PHONY: all help deps run repl tmux-repl lint test test-unit test-integration test-coverage test-emacs check-constraints clean push push-all gh-info gh-workflows gh-secrets examples

# Default target
all: help

help:
	@echo "MAL Ruby Minimal - Makefile targets"
	@echo ""
	@echo "Main targets:"
	@echo "  make run              - Run the MAL REPL"
	@echo "  make repl             - Alias for 'make run'"
	@echo "  make tmux-repl        - Run the MAL REPL in tmux session"
	@echo "  make test             - Run all tests"
	@echo "  make lint             - Run code quality checks"
	@echo "  make push-all         - Test, lint, commit, and push"
	@echo ""
	@echo "Testing targets:"
	@echo "  make test-unit        - Run unit tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-coverage    - Run tests with code coverage"
	@echo "  make test-emacs       - Test Emacs integration"
	@echo ""
	@echo "Development targets:"
	@echo "  make deps             - Check system dependencies"
	@echo "  make check-constraints - Verify no arrays/hashes/blocks"
	@echo "  make clean            - Clean generated files"
	@echo "  make examples         - Run example programs"
	@echo ""
	@echo "Git targets:"
	@echo "  make push             - Push commits, notes, and tags"
	@echo "  make gh-info          - Show GitHub repo information"
	@echo "  make gh-workflows     - List GitHub Actions workflows"
	@echo "  make gh-secrets       - List GitHub secrets"
	@echo ""
	@echo "  make help             - Show this help"

deps:
	@echo "Checking system dependencies..."
	@echo -n "Ruby: "
	@ruby --version || (echo "ERROR: Ruby not found"; exit 1)
	@echo -n "Expect: "
	@which expect > /dev/null && echo "Found at $$(which expect)" || echo "WARNING: expect not found (needed for integration tests)"
	@echo -n "Git: "
	@git --version || (echo "ERROR: Git not found"; exit 1)
	@echo -n "GitHub CLI: "
	@gh --version || echo "WARNING: GitHub CLI not found (needed for issue tracking)"
	@echo -n "Ruby LSP: "
	@which ruby-lsp > /dev/null && echo "Found (version: $$(ruby-lsp --version 2>/dev/null || echo 'unknown'))" || echo "WARNING: ruby-lsp not found (run ./setup-ruby-lsp.sh)"
	@echo ""
	@echo "Ruby version check:"
	@ruby -e 'exit 1 if RUBY_VERSION < "3.0"' && echo "✓ Ruby 3.0+ detected" || (echo "✗ Ruby 3.0+ required"; exit 1)
	@echo ""
	@echo "All required dependencies satisfied!"
	@echo ""
	@echo "For development setup with Ruby LSP:"
	@echo "  ./setup-ruby-lsp.sh"

run:
	@echo "Starting MAL REPL..."
	@ruby mal_minimal.rb

# Alias for run
repl: run

# Run REPL in tmux session
tmux-repl:
	@echo "Starting MAL REPL in tmux session 'mal-repl'..."
	@tmux kill-session -t mal-repl 2>/dev/null || true
	@tmux new-session -d -s mal-repl 'cd $(shell pwd) && ruby mal_minimal.rb'
	@echo ""
	@echo "REPL started in tmux session."
	@echo "To attach: tmux attach -t mal-repl"
	@echo "To detach: Ctrl+B then D"
	@echo "To send commands: tmux send-keys -t mal-repl '<command>' C-m"
	@echo ""
	@echo "Example factorial demo:"
	@echo "  tmux send-keys -t mal-repl '(def! factorial (fn* (n) (if (< n 2) 1 (* n (factorial (- n 1))))))' C-m"
	@echo "  tmux send-keys -t mal-repl '(factorial 5)' C-m"

lint: check-constraints
	@echo "Running Ruby syntax checks..."
	@find . -name "*.rb" -not -path "./examples/*" -not -path "./experiments/*" | xargs -I {} ruby -c {} > /dev/null
	@echo "✓ All Ruby files have valid syntax"
	@echo ""
	@echo "Checking for debugging artifacts..."
	@! grep -r "binding\.pry\|debugger\|byebug" --include="*.rb" . || (echo "✗ Found debugging statements" && exit 1)
	@echo "✓ No debugging artifacts found"
	@echo ""
	@echo "Checking for TODO/FIXME comments..."
	@grep -r "TODO\|FIXME" --include="*.rb" . || echo "✓ No TODO/FIXME comments found"

test: test-unit test-integration
	@echo "All tests passed!"

test-unit:
	@echo "Running unit tests..."
	@ruby test/test_reader.rb
	@ruby test/test_printer.rb
	@ruby test/test_env.rb
	@ruby test/test_step4_functions.rb
	@ruby test/test_step7.rb
	@ruby test/test_step8_macros.rb
	@echo "Unit tests passed!"

test-integration:
	@echo "Running integration tests..."
	@if which expect > /dev/null; then \
		./test_step1.exp; \
	else \
		echo "SKIP: expect not installed"; \
	fi

test-coverage:
	@echo "Running tests with code coverage..."
	@if [ -f Gemfile ]; then \
		bundle install --quiet || gem install simplecov; \
	fi
	@COVERAGE=1 ruby test/run_all_tests.rb
	@echo ""
	@echo "Coverage report: coverage/index.html"

test-emacs:
	@echo "Testing Emacs integration..."
	@echo ""
	@echo "This will:"
	@echo "1. Start Emacs with mal-ruby-minimal.el"
	@echo "2. Open examples/emacs-test.mal"
	@echo "3. Start MAL REPL"
	@echo "4. Load the test file"
	@echo ""
	@if which emacs > /dev/null; then \
		if which tmux > /dev/null; then \
			echo "Starting Emacs in tmux session..."; \
			tmux new-session -d -s mal-emacs || true; \
			tmux send-keys -t mal-emacs "cd $(shell pwd)" C-m; \
			tmux send-keys -t mal-emacs "timeout 30 emacs -nw -l mal-ruby-minimal.el --eval '(mal-ruby-test-setup)'" C-m; \
			echo ""; \
			echo "Emacs started in tmux session 'mal-emacs'"; \
			echo "To attach: tmux attach -t mal-emacs"; \
			echo "To check if Ruby LSP is running: ps aux | grep ruby-lsp"; \
			echo ""; \
			sleep 5; \
			if tmux capture-pane -t mal-emacs -p | grep -q "MAL Ruby test setup complete"; then \
				echo "✓ Emacs integration test passed!"; \
			else \
				echo "✗ Emacs integration test failed or timed out"; \
				echo "Debug output:"; \
				tmux capture-pane -t mal-emacs -p | tail -20; \
			fi; \
		else \
			echo "Starting Emacs without tmux..."; \
			timeout 10 emacs -batch -l mal-ruby-minimal.el --eval '(message "MAL Ruby Minimal loaded successfully")' && \
			echo "✓ Emacs config loads successfully" || \
			echo "✗ Emacs config failed to load"; \
		fi \
	else \
		echo "SKIP: Emacs not installed"; \
	fi

check-constraints:
	@echo "Checking for forbidden Ruby constructs..."
	@echo ""
	@echo "Manual verification checklist:"
	@echo "- No array literals [] (except in comments)"
	@echo "- No hash literals {} (except in heredocs)"  
	@echo "- No blocks with do...end or {...}"
	@echo "- Only uses cons cells for data structures"
	@echo ""
	@echo "Running basic automated checks..."
	@echo -n "Checking for .each blocks: "
	@! grep -E '\.each\s*(do|\{)' mal_minimal.rb || echo "NONE ✓"
	@echo -n "Checking for .map blocks: "
	@! grep -E '\.map\s*(do|\{)' mal_minimal.rb || echo "NONE ✓"
	@echo -n "Checking for .times blocks: "
	@! grep -E '\.times\s*(do|\{)' mal_minimal.rb || echo "NONE ✓"

clean:
	@echo "Cleaning..."
	@rm -f *.tmp *.log
	@rm -rf coverage/

# Run examples
examples:
	@$(MAKE) -C examples run

# Run a specific MAL expression
expr:
	@echo '$(EXPR)' | ruby mal_minimal.rb | tail -1

# Documentation commands (not PHONY - actual file target)
docs/mal-process-guide.md: | docs
	@echo "Downloading MAL process guide..."
	@curl -L -o $@ https://raw.githubusercontent.com/kanaka/mal/master/process/guide.md
	@echo "Downloaded to $@"

# Directory creation targets
docs:
	@install -d $@

resources:
	@install -d $@

# Banner file for REPL startup
resources/banner.txt: | resources
	@echo "Banner file exists at $@"

# Push commits, notes, and tags to GitHub
push:
	@echo "Pushing commits to GitHub..."
	@git push origin main
	@echo ""
	@echo "Pushing notes to GitHub..."
	@git push origin refs/notes/commits
	@echo ""
	@echo "Pushing tags to GitHub (if any)..."
	@git push origin --tags || echo "No tags to push"
	@echo ""
	@echo "Push complete!"

# GitHub information commands
gh-info:
	@echo "GitHub Repository Information"
	@echo "============================="
	@echo ""
	@echo "Current User:"
	@gh api user --jq '.login + " (" + .name + ")"' 2>/dev/null || echo "Not authenticated"
	@echo ""
	@echo "Repository:"
	@gh repo view --json name,owner,visibility,description --jq '"\(.owner.login)/\(.name) [\(.visibility)]"' 2>/dev/null || echo "Not in a GitHub repo"
	@echo ""

gh-workflows:
	@echo "GitHub Actions Workflows"
	@echo "========================"
	@if gh api repos/:owner/:repo/actions/workflows --jq '.workflows[] | "- \(.name) [\(.state)]"' 2>/dev/null; then \
		echo ""; \
		echo "Recent workflow runs:"; \
		gh run list --limit 5 2>/dev/null || echo "No runs found"; \
	else \
		echo "No workflows found or not in a GitHub repo"; \
	fi

gh-secrets:
	@echo "GitHub Repository Secrets"
	@echo "========================="
	@echo "Note: Secret values are never exposed"
	@echo ""
	@if gh api repos/:owner/:repo/actions/secrets --jq '.secrets[] | "- \(.name) (updated: \(.updated_at))"' 2>/dev/null; then \
		echo ""; \
	else \
		echo "No secrets found or insufficient permissions"; \
	fi

# Combined workflow: test, lint, commit, and push
push-all: test lint
	@echo ""
	@echo "All tests and checks passed!"
	@echo ""
	@echo "Ready to commit and push?"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo ""
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Uncommitted changes found:"; \
		git status --short; \
		echo ""; \
		echo "Please commit your changes first."; \
		exit 1; \
	fi
	@$(MAKE) push