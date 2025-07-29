.PHONY: all help analysis brute-force dump-parsetrees generate-research-rb-files clean

# Default target
all: analysis

help:
	@echo "Ruby AST Analysis Experiment 002"
	@echo "================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make analysis                    - Run comprehensive AST analysis"
	@echo "  make brute-force                 - Run brute force analysis across all codebases"
	@echo "  make dump-parsetrees             - Dump all Ruby parse trees to research/ directory"
	@echo "  make research/mnt-usb-ruby-files.txt - Generate cached list of all Ruby files"
	@echo "  make generate-research-rb-files  - Generate random sample from cached list"
	@echo "  make clean                       - Clean generated files"
	@echo "  make help                        - Show this help"

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

# Generate cached list of all Ruby files in /mnt/usb/ruby
research/mnt-usb-ruby-files.txt: | research
	@echo "Generating cached list of all Ruby files..."
	@echo "This may take a few minutes for 98K+ files..."
	@find /mnt/usb/ruby -path "*/.git" -prune -o -path "*/test/*" -prune -o -path "*/spec/*" -prune -o -type f -name "*.rb" -print > $@
	@echo "Found $$(wc -l < $@) Ruby files"
	@echo "Cached list saved to $@"

# Create research directory
research:
	@mkdir -p research

# Generate random sample of Ruby files for analysis
generate-research-rb-files: research/mnt-usb-ruby-files.txt
	@echo "Generating random sample of Ruby files..."
	@if [ ! -f research/mnt-usb-ruby-files.txt ]; then \
		echo "Error: research/mnt-usb-ruby-files.txt not found. Run 'make research/mnt-usb-ruby-files.txt' first"; \
		exit 1; \
	fi
	@echo "Shuffling $$(wc -l < research/mnt-usb-ruby-files.txt) files and taking sample of 1000..."
	@sort -R research/mnt-usb-ruby-files.txt | head -1000 > research/sample-1000-files.txt
	@echo "Random sample saved to research/sample-1000-files.txt"
	@echo "Sample files:"
	@head -10 research/sample-1000-files.txt
	@echo "... (990 more files)"

clean:
	@echo "Cleaning generated files..."
	@rm -f *.json
	@rm -rf research/
	@echo "Clean complete"