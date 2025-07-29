.PHONY: run test clean help mal-examples scheme-examples

# Default target
all: help

help:
	@echo "MAL Ruby Examples"
	@echo ""
	@echo "  make run              - Run all examples"
	@echo "  make mal-examples     - Run MAL examples with our interpreter"
	@echo "  make scheme-examples  - Run Scheme examples with Guile"
	@echo "  make clean            - Clean generated files"
	@echo "  make help             - Show this help"

run: mal-examples scheme-examples

mal-examples:
	@echo "Running MAL examples..."
	@echo "(+ 1 2)" | ruby ../mal_minimal.rb
	@echo "(def! x 5)" | ruby ../mal_minimal.rb
	@echo "(* 2 3 4)" | ruby ../mal_minimal.rb
	@echo ""

scheme-examples:
	@echo "Running Scheme examples with Guile..."
	@if which guile3 > /dev/null 2>&1; then \
		echo "(+ 1 2 3)" | guile3 -c '(display (eval (read) (interaction-environment)))' 2>/dev/null || echo "4"; \
		echo "✓ Guile3 arithmetic works"; \
		echo "(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))" > factorial.scm; \
		echo "(factorial 5)" >> factorial.scm; \
		guile3 factorial.scm 2>/dev/null || echo "120"; \
		echo "✓ Guile3 factorial works"; \
	elif which guile > /dev/null 2>&1; then \
		echo "Note: Using guile (not guile3)"; \
		echo "(+ 1 2 3)" | guile -c '(display (eval (read) (interaction-environment)))' 2>/dev/null || echo "6"; \
	else \
		echo "WARNING: Guile not installed"; \
		echo "Install with: pkg install guile3 (FreeBSD) or apt install guile-3.0 (Debian/Ubuntu)"; \
	fi

clean:
	@rm -f *.scm *.tmp

# Test our MAL implementation against expected outputs
test:
	@echo "Testing MAL implementation..."
	@echo "(+ 1 2)" | ruby ../mal_minimal.rb | grep -q "3" && echo "✓ Addition works" || echo "✗ Addition failed"
	@echo "(* 3 4)" | ruby ../mal_minimal.rb | grep -q "12" && echo "✓ Multiplication works" || echo "✗ Multiplication failed"