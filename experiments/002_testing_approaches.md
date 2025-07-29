# Experiment 002: Testing Approaches for MAL Implementation

## Overview

Explore different testing methodologies to improve test quality, readability, and coverage for the MAL Ruby implementation.

## Current State

Our tests use basic Ruby with manual assertions:
```ruby
def test(name, expected, actual)
  if expected == actual
    puts "✓ #{name}"
  else
    puts "✗ #{name}"
    puts "  Expected: #{expected}"
    puts "  Actual: #{actual}"
  end
end
```

## Testing Approaches to Evaluate

### 1. RSpec (Behavior-Driven Development)

**Pros:**
- Readable, natural language syntax
- Rich matchers and expectations
- Good for documenting behavior
- Excellent error messages

**Example:**
```ruby
RSpec.describe Reader do
  describe "#read_str" do
    it "parses integers" do
      expect(read_str("42")).to eq(42)
    end
    
    it "parses symbols" do
      result = read_str("foo")
      expect(result).to be_a(Symbol)
      expect(result.name).to eq("foo")
    end
    
    it "parses lists" do
      result = read_str("(+ 1 2)")
      expect(result).to be_list
      expect(car(result).name).to eq("+")
    end
  end
end
```

### 2. Minitest Spec

**Pros:**
- Lightweight, included with Ruby
- Can use spec or unit style
- Fast execution
- Simple setup

**Example:**
```ruby
require 'minitest/autorun'

describe Reader do
  describe "read_str" do
    it "parses integers" do
      _(read_str("42")).must_equal 42
    end
    
    it "handles nested lists" do
      result = read_str("(a (b c))")
      _(car(result)).must_be_kind_of Symbol
      _(car(cdr(result))).must_be :list?
    end
  end
end
```

### 3. Property-Based Testing

**Pros:**
- Finds edge cases automatically
- Tests properties, not just examples
- Great for parsers and evaluators
- Catches bugs example-based tests miss

**Example with Rantly:**
```ruby
require 'rantly'
require 'rantly/minitest_extensions'

class TestReader < Minitest::Test
  # Property: parse(print(ast)) == ast
  def test_print_read_inverse
    property_of {
      Rantly { sized(5) { random_ast } }
    }.check { |ast|
      assert_equal ast, read_str(pr_str(ast))
    }
  end
  
  def random_ast(depth = 3)
    if depth <= 0
      [integer, string, symbol].sample
    else
      case rand(4)
      when 0 then integer
      when 1 then string 
      when 2 then symbol
      when 3 then random_list(depth - 1)
      end
    end
  end
end
```

### 4. Integration Testing with Expect

**Pros:**
- Tests actual REPL interaction
- Catches integration issues
- Documents user experience
- Already partially implemented

**Enhancement Ideas:**
```ruby
# test_mal_integration.rb
require 'expect_test'

class MALIntegrationTest < ExpectTest
  test "basic arithmetic" do
    repl = start_repl("step2_eval.rb")
    
    repl.send_line "(+ 1 2)"
    repl.expect "3"
    
    repl.send_line "(* 3 4)"
    repl.expect "12"
  end
  
  test "function definition and call" do
    repl = start_repl("step4_if_fn_do.rb")
    
    repl.send_line "(def! inc (fn* (x) (+ x 1)))"
    repl.expect "#<function>"
    
    repl.send_line "(inc 5)"
    repl.expect "6"
  end
end
```

### 5. Doctest-Style Testing

**Pros:**
- Tests embedded in documentation
- Examples always stay up-to-date
- Great for learning materials

**Example:**
```ruby
# reader.rb

# Reads a string and returns an AST
#
# Examples:
#   >> read_str("42")
#   => 42
#
#   >> read_str("foo")
#   => #<Symbol:foo>
#
#   >> pr_str(read_str("(+ 1 2)"))
#   => "(+ 1 2)"
#
def read_str(str)
  # ...
end
```

## Evaluation Criteria

1. **Readability**: How clear is test intent?
2. **Maintainability**: How easy to update tests?
3. **Coverage**: Can we test edge cases effectively?
4. **Documentation**: Do tests document behavior well?
5. **Performance**: Test execution speed
6. **Learning Curve**: How easy for contributors?

## Proof of Concept Plan

### Phase 1: Reader Module
1. Implement reader tests in RSpec
2. Implement same tests in Minitest::Spec
3. Add property-based tests for parser invariants
4. Compare clarity and coverage

### Phase 2: Evaluator Testing
1. Test evaluation rules with chosen framework
2. Add integration tests for REPL interaction
3. Property test: `eval(read(print(ast))) == eval(ast)`

### Phase 3: Full Suite Migration
1. Gradually migrate existing tests
2. Add new test types (property, integration)
3. Update CI/CD pipeline

## Recommendation Matrix

| Approach | Readability | Coverage | Documentation | Ease of Use |
|----------|-------------|----------|---------------|-------------|
| Current  | Fair        | Basic    | Poor          | Good        |
| RSpec    | Excellent   | Good     | Excellent     | Good        |
| Minitest | Good        | Good     | Good          | Excellent   |
| Property | Fair        | Excellent| Fair          | Fair        |
| Doctest  | Excellent   | Basic    | Excellent     | Good        |

## Next Steps

1. Get feedback on testing preferences
2. Create proof-of-concept branch
3. Implement reader tests in 2-3 frameworks
4. Measure and compare results
5. Make recommendation for adoption

## Notes

- Consider hybrid approach: RSpec for behavior, property tests for invariants
- Integration tests are crucial for REPL-based system
- Tests should serve as learning material
- Balance between sophistication and simplicity