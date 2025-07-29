.PHONY: demo screenshot test clean help

help:
	@echo "MAL Eshell Workflow Experiment"
	@echo ""
	@echo "  make demo       - Run interactive workflow demo"
	@echo "  make screenshot - Capture workflow screenshot"
	@echo "  make test       - Test workflow setup"
	@echo "  make clean      - Remove generated files"

demo:
	@echo "Starting MAL eshell workflow..."
	@emacs -nw -Q -l setup-workflow.el -f mal-eshell-workflow

screenshot:
	@echo "Capturing workflow screenshot..."
	@cd ../.. && bash scripts/capture-eshell-workflow.sh
	@echo "Screenshot saved to screenshots/"

test:
	@echo "Testing workflow setup..."
	@echo ""
	@echo "1. Checking mal-mode.el..."
	@test -f ../../mal-mode.el && echo "   ✓ mal-mode.el found" || echo "   ✗ mal-mode.el missing"
	@echo ""
	@echo "2. Checking MAL interpreter..."
	@test -f ../../mal_minimal.rb && echo "   ✓ mal_minimal.rb found" || echo "   ✗ mal_minimal.rb missing"
	@echo ""
	@echo "3. Testing Elisp functions..."
	@emacs -Q --batch -l setup-workflow.el \
		--eval "(if (fboundp 'mal-eshell-workflow) \
		          (princ \"   ✓ Workflow functions loaded\\n\") \
		          (princ \"   ✗ Workflow functions failed\\n\"))"
	@echo ""
	@echo "4. Checking example file..."
	@test -f workflow.mal && echo "   ✓ workflow.mal exists" || echo "   ✗ workflow.mal missing"

clean:
	@rm -f *~ \#*\#
	@rm -f *.elc
	@echo "Cleaned up temporary files"

# Run a quick non-interactive test
quick-test:
	@tmux new-session -d -s mal-test-$$ -x 80 -y 30 \
		"emacs -nw -Q -l setup-workflow.el -f mal-eshell-workflow"
	@sleep 5
	@tmux capture-pane -t mal-test-$$ -p
	@tmux kill-session -t mal-test-$$