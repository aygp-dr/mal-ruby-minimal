# Let Over Lambda Examples Makefile

.PHONY: all test clean tangle individual-tests

all: test

test:
	@echo "Running Let Over Lambda examples in MAL..."
	@cd ../.. && ./stepA_mal.rb experiments/006-let-over-lambda-mal/test-lol-patterns.mal

individual-tests:
	@echo "Testing closures..."
	@cd ../.. && ./stepA_mal.rb experiments/006-let-over-lambda-mal/closures-advanced.mal
	@echo "Testing macros..."
	@cd ../.. && ./stepA_mal.rb experiments/006-let-over-lambda-mal/macro-techniques.mal
	@echo "Testing anaphoric macros..."
	@cd ../.. && ./stepA_mal.rb experiments/006-let-over-lambda-mal/anaphoric-macros.mal
	@echo "Testing pandoric closures..."
	@cd ../.. && ./stepA_mal.rb experiments/006-let-over-lambda-mal/pandoric-closures.mal

clean:
	@echo "Cleaning generated files..."
	@rm -f *.png

tangle:
	@echo "Tangling org files..."
	@emacs --batch -l org --eval "(org-babel-tangle-file \"SETUP.org\")"
