# Makefile for Church Encoding Experiment 004

.PHONY: help test-all test-booleans test-numerals test-pairs benchmark clean

MAL_RUNNER = ../../mal_minimal.rb

help:
	@echo "Church Encoding Experiment 004"
	@echo "==============================="
	@echo "Available targets:"
	@echo "  test-all       - Run complete Church encoding test suite"
	@echo "  test-booleans  - Test Church boolean encodings"
	@echo "  test-numerals  - Test Church numeral encodings" 
	@echo "  test-pairs     - Test Church pair and list encodings"
	@echo "  benchmark      - Performance benchmarks vs native operations"
	@echo "  validate       - Validate theoretical completeness claims"
	@echo "  clean          - Clean up test artifacts"

# Run complete test suite
test-all: test-booleans test-numerals test-pairs
	@echo "🎉 All Church encoding tests complete!"

# Individual test targets
test-booleans:
	@echo "🔬 Testing Church Boolean Encodings..."
	@ruby $(MAL_RUNNER) church-booleans.mal

test-numerals:
	@echo "🔢 Testing Church Numeral Encodings..."
	@ruby $(MAL_RUNNER) church-numerals.mal

test-pairs:
	@echo "👫 Testing Church Pair Encodings..."
	@ruby $(MAL_RUNNER) church-pairs.mal

# Performance benchmarking
benchmark:
	@echo "⚡ Running Church Encoding Benchmarks..."
	@echo "Comparing Church operations vs MAL native operations..."
	@ruby $(MAL_RUNNER) benchmarks.mal

# Validate theoretical completeness
validate:
	@echo "🎓 Validating Theoretical Completeness..."
	@echo "Testing Y combinator and recursive definitions..."
	@ruby $(MAL_RUNNER) church-combinators.mal

# Comprehensive test with output capture
test-comprehensive:
	@echo "📊 Running Comprehensive Church Encoding Analysis..."
	@echo "Results will be saved to test-results.txt"
	@(echo "Church Encoding Test Results - $$(date)"; \
	  echo "=========================================="; \
	  ruby $(MAL_RUNNER) church-booleans.mal; \
	  echo ""; \
	  ruby $(MAL_RUNNER) church-numerals.mal; \
	  echo ""; \
	  ruby $(MAL_RUNNER) church-pairs.mal) > test-results.txt
	@echo "✅ Results saved to test-results.txt"

# Demo for presentation
demo:
	@echo "🎯 Church Encoding Demo for Architecture Guild..."
	@echo "Demonstrating theoretical completeness of our MAL implementation"
	@ruby $(MAL_RUNNER) -c "(load-file \"church-demo.mal\")"

# Clean up artifacts
clean:
	@echo "🧹 Cleaning up Church encoding test artifacts..."
	@rm -f test-results.txt benchmark-results.txt
	@echo "✅ Cleanup complete"

# Development helpers
check-mal:
	@echo "🔍 Checking MAL interpreter availability..."
	@ruby $(MAL_RUNNER) -c "(println \"MAL interpreter ready for Church encoding tests!\")" || \
		echo "❌ MAL interpreter not found at $(MAL_RUNNER)"

# Status check
status:
	@echo "📊 Church Encoding Experiment Status:"
	@echo "  MAL files: $$(ls -1 *.mal | wc -l)"
	@echo "  Test files ready: $$(ls -1 church-*.mal | wc -l)"
	@echo "  MAL interpreter: $$([ -f "$(MAL_RUNNER)" ] && echo "✅" || echo "❌")"
	@echo ""
	@echo "Ready to run: gmake test-all"