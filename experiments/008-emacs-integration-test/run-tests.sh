#!/bin/bash
# Run Emacs integration tests

echo "Running MAL Ruby Emacs Integration Tests..."
echo "=========================================="

# Run basic integration tests
emacs --batch -l test-emacs-integration.el 2>&1 | grep -E "✅|❌|⚠️|🚀|📄"

# Run paredit-specific tests
emacs --batch -l test-paredit-integration.el 2>&1 | grep -E "✅|❌|🎯"

echo ""
echo "Tests completed. Check test-report.txt for details."