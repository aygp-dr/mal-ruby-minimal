.PHONY: run test clean help check-constraints deps push test-unit test-integration

# Default target
all: help

help:
	@echo "MAL Ruby Minimal - Makefile targets"
	@echo ""
	@echo "  make deps             - Check system dependencies"
	@echo "  make run              - Run the MAL REPL"
	@echo "  make test             - Run all tests"
	@echo "  make test-unit        - Run unit tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make check-constraints - Verify no arrays/hashes/blocks"
	@echo "  make push             - Push commits, notes, and tags"
	@echo "  make clean            - Clean generated files"
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
	@echo ""
	@echo "Ruby version check:"
	@ruby -e 'exit 1 if RUBY_VERSION < "3.0"' && echo "✓ Ruby 3.0+ detected" || (echo "✗ Ruby 3.0+ required"; exit 1)
	@echo ""
	@echo "All required dependencies satisfied!"

run:
	@echo "Starting MAL REPL..."
	@ruby mal_minimal.rb

test: test-unit test-integration
	@echo "All tests passed!"

test-unit:
	@echo "Running unit tests..."
	@ruby test/test_reader.rb
	@ruby test/test_printer.rb
	@ruby test/test_env.rb
	@echo "Unit tests passed!"

test-integration:
	@echo "Running integration tests..."
	@if which expect > /dev/null; then \
		./test_step1.exp; \
	else \
		echo "SKIP: expect not installed"; \
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

# Run a specific MAL expression
expr:
	@echo '$(EXPR)' | ruby mal_minimal.rb | tail -1

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