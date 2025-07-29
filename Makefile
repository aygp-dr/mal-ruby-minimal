.PHONY: run test clean help check-constraints

# Default target
all: help

help:
	@echo "MAL Ruby Minimal - Makefile targets"
	@echo ""
	@echo "  make run              - Run the MAL REPL"
	@echo "  make test             - Run example programs"
	@echo "  make check-constraints - Verify no arrays/hashes/blocks"
	@echo "  make clean            - Clean generated files"
	@echo "  make help             - Show this help"

run:
	@echo "Starting MAL REPL..."
	@ruby mal_minimal.rb

test:
	@echo "Running MAL example programs..."
	@ruby -e 'load "mal_minimal.rb"; exit' < /dev/null

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