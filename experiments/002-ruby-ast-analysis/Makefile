.PHONY: all help analysis brute-force dump-parsetrees clean

# Default target
all: analysis

help:
	@echo "Ruby AST Analysis Experiment 002"
	@echo "================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make analysis        - Run comprehensive AST analysis"
	@echo "  make brute-force     - Run brute force analysis across all codebases"
	@echo "  make dump-parsetrees - Dump all Ruby parse trees to research/ directory"
	@echo "  make clean           - Clean generated files"
	@echo "  make help            - Show this help"

analysis:
	@echo "Running comprehensive AST analysis..."
	@ruby comprehensive-ast-analysis-simple.rb

brute-force:
	@echo "Running brute force AST analysis..."
	@ruby brute-force-ast-analysis.rb

dump-parsetrees:
	@echo "Dumping parse trees from Ruby codebases to research/ directory..."
	@mkdir -p research
	@echo "Analyzing MAL implementation..."
	@find ../.. -name "*.rb" -not -path "*/vendor/*" -not -path "*/node_modules/*" | head -50 | while read file; do \
		echo "Processing $$file..."; \
		basename_file=$$(basename "$$file" .rb); \
		ruby --dump=parsetree "$$file" > "research/mal_$${basename_file}.parsetree" 2>/dev/null || true; \
	done
	@echo "Analyzing ActiveAdmin..."
	@if [ -d "/mnt/usb/ruby/activeadmin/activeadmin" ]; then \
		find /mnt/usb/ruby/activeadmin/activeadmin -name "*.rb" -not -path "*/test/*" -not -path "*/spec/*" | head -20 | while read file; do \
			echo "Processing $$file..."; \
			basename_file=$$(basename "$$file" .rb); \
			ruby --dump=parsetree "$$file" > "research/activeadmin_$${basename_file}.parsetree" 2>/dev/null || true; \
		done; \
	fi
	@echo "Analyzing Shopify Liquid..."
	@if [ -d "/mnt/usb/ruby/Shopify/liquid" ]; then \
		find /mnt/usb/ruby/Shopify/liquid -name "*.rb" -not -path "*/test/*" -not -path "*/spec/*" | head -20 | while read file; do \
			echo "Processing $$file..."; \
			basename_file=$$(basename "$$file" .rb); \
			ruby --dump=parsetree "$$file" > "research/liquid_$${basename_file}.parsetree" 2>/dev/null || true; \
		done; \
	fi
	@echo "Analyzing Database Cleaner..."
	@if [ -d "/mnt/usb/ruby/DatabaseCleaner/database_cleaner" ]; then \
		find /mnt/usb/ruby/DatabaseCleaner/database_cleaner -name "*.rb" -not -path "*/test/*" -not -path "*/spec/*" | head -20 | while read file; do \
			echo "Processing $$file..."; \
			basename_file=$$(basename "$$file" .rb); \
			ruby --dump=parsetree "$$file" > "research/database_cleaner_$${basename_file}.parsetree" 2>/dev/null || true; \
		done; \
	fi
	@echo "Parse trees saved to research/ directory"
	@echo "Total files: $$(ls research/*.parsetree 2>/dev/null | wc -l)"

clean:
	@echo "Cleaning generated files..."
	@rm -f *.json
	@rm -rf research/
	@echo "Clean complete"