.PHONY: all pdf clean help

# Default target
all: pdf

help:
	@echo "MAL Ruby Minimal - Presentation Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make pdf    - Generate PDF presentation from README.org"
	@echo "  make clean  - Remove generated files"
	@echo "  make help   - Show this help"

# Check dependencies
check-deps:
	@echo "Checking LaTeX dependencies..."
	@which pdflatex > /dev/null || (echo "ERROR: pdflatex not found. Install TeXLive or MacTeX"; exit 1)
	@which emacs > /dev/null || (echo "ERROR: emacs not found. Needed for org-mode export"; exit 1)
	@echo "✓ Dependencies satisfied"

# Generate PDF from org-mode file
pdf: check-deps README.org
	@echo "Generating PDF presentation..."
	@emacs --batch \
		--eval "(require 'ox-beamer)" \
		--eval "(setq org-latex-listings 'minted)" \
		--eval "(setq org-latex-minted-options '((\"bgcolor\" \"codegray!10\") (\"fontsize\" \"\\\\scriptsize\") (\"linenos\" \"true\")))" \
		--eval "(setq org-export-with-broken-links t)" \
		--visit README.org \
		--funcall org-beamer-export-to-pdf
	@echo "✓ PDF generated: README.pdf"

# Alternative method using pandoc if available
pdf-pandoc: check-pandoc README.org
	@echo "Generating PDF with pandoc..."
	@pandoc README.org \
		-t beamer \
		--pdf-engine=pdflatex \
		--template=default \
		-V theme:metropolis \
		-V colortheme:seahorse \
		-V fonttheme:professionalfonts \
		-V aspectratio:169 \
		--highlight-style=tango \
		-o README.pdf
	@echo "✓ PDF generated with pandoc: README.pdf"

check-pandoc:
	@which pandoc > /dev/null || (echo "ERROR: pandoc not found"; exit 1)

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -f README.pdf
	@rm -f README.tex
	@rm -f README.aux
	@rm -f README.log
	@rm -f README.nav
	@rm -f README.out
	@rm -f README.snm
	@rm -f README.toc
	@rm -f README.vrb
	@rm -f _minted-README/*
	@rmdir _minted-README 2>/dev/null || true
	@echo "✓ Clean complete"

# Test presentation (open PDF)
test: pdf
	@echo "Opening presentation..."
	@if which open > /dev/null; then \
		open README.pdf; \
	elif which xdg-open > /dev/null; then \
		xdg-open README.pdf; \
	elif which evince > /dev/null; then \
		evince README.pdf & \
	else \
		echo "PDF generated at README.pdf"; \
	fi