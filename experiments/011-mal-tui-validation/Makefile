.PHONY: all validate-repl validate-mode capture-screenshots clean help

# Default target
all: validate-repl validate-mode capture-screenshots

help:
	@echo "MAL TUI Validation Experiment"
	@echo ""
	@echo "  make validate-repl      - Test REPL display and interaction"
	@echo "  make validate-mode      - Test mal-mode.el functionality"
	@echo "  make capture-screenshots - Capture all screenshot types"
	@echo "  make clean              - Remove temporary files"
	@echo "  make all                - Run all validations"

validate-repl:
	@echo "Validating MAL REPL..."
	@sh ../../scripts/validate-mal-repl.sh

validate-mode:
	@echo "Validating mal-mode.el..."
	@sh ../../scripts/validate-mal-mode.sh

capture-screenshots:
	@echo "Capturing screenshots..."
	@mkdir -p ../../screenshots
	@echo "1. Basic screenshot..."
	@sh ../../scripts/capture-mal-screenshot-aha.sh || echo "Note: May need aha/firefox installed"
	@echo ""
	@echo "2. Multiple states..."
	@sh ../../scripts/capture-mal-states.sh || echo "Note: May need dependencies"
	@echo ""
	@echo "3. TUI mockup..."
	@sh ../../scripts/create-mal-tui-mockup.sh || echo "Note: May need dependencies"

test-gif:
	@echo "Creating animated GIF (requires asciinema + agg)..."
	@sh ../../scripts/capture-mal-demo-gif.sh || echo "Note: Requires asciinema and agg"

clean:
	@rm -f capture*.html capture*.ansi recording.cast
	@rm -f test-syntax.mal
	@echo "Cleaned up temporary files"

# Individual script tests
test-aha:
	@which aha >/dev/null 2>&1 && echo "✓ aha installed" || echo "✗ aha not found - install with: sudo pkg install aha"

test-firefox:
	@which firefox >/dev/null 2>&1 && echo "✓ firefox installed" || echo "✗ firefox not found - install with: sudo pkg install firefox"

test-asciinema:
	@which asciinema >/dev/null 2>&1 && echo "✓ asciinema installed" || echo "✗ asciinema not found - install with: sudo pkg install py311-asciinema"

test-agg:
	@which agg >/dev/null 2>&1 && echo "✓ agg installed" || echo "✗ agg not found - install with: sudo pkg install asciinema-agg"

check-deps: test-aha test-firefox test-asciinema test-agg
	@echo ""
	@echo "Dependency check complete"