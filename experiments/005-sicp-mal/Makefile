# SICP Examples Makefile

.PHONY: all test clean

all: test

test:
	@echo "Running SICP examples in MAL..."
	@cd ../.. && ./stepA_mal.rb experiments/005-sicp-mal/run_tests.mal

individual-tests:
	@echo "Testing Chapter 1..."
	@cd ../.. && ./stepA_mal.rb experiments/005-sicp-mal/chapter1_basics.mal
	@cd ../.. && ./stepA_mal.rb experiments/005-sicp-mal/chapter1_recursion.mal
	@echo "Testing Chapter 2..."
	@cd ../.. && ./stepA_mal.rb experiments/005-sicp-mal/chapter2_church_numerals.mal
	@cd ../.. && ./stepA_mal.rb experiments/005-sicp-mal/chapter2_symbolic.mal

clean:
	@echo "Cleaning generated files..."
	@rm -f *.png

tangle:
	@echo "Tangling org files..."
	@emacs --batch -l org --eval "(org-babel-tangle-file \"SETUP.org\")"
