#!/usr/bin/env ruby

# Test step 9 - Try/Catch Exception Handling

require_relative '../step9_try'

$test_count = 0
$pass_count = 0

def test_eval(name, input, expected, env)
  $test_count += 1
  print "Testing #{name}... "
  
  begin
    # Parse and evaluate
    ast = READ(input)
    result = EVAL(ast, env)
    actual = PRINT(result)
    
    # Check result
    if actual == expected
      puts "✓"
      $pass_count += 1
    else
      puts "✗"
      puts "  Expected: #{expected}"
      puts "  Actual: #{actual}"
    end
  rescue => e
    # Handle expected errors
    if expected.start_with?("ERROR:")
      puts "✓ (got expected error: #{e.message})"
      $pass_count += 1
    else
      puts "✗"
      puts "  Expected: #{expected}"
      puts "  Error: #{e.message}"
    end
  end
end

# Initialize environment
env = create_repl_env

puts "Testing Step 9 - Try/Catch Exception Handling..."
puts "==============================================="

# Basic throw and catch
test_eval("throw string", 
  '(try* (throw "error") (catch* e e))', 
  '"error"', env)

test_eval("throw number", 
  '(try* (throw 123) (catch* e e))', 
  '123', env)

test_eval("throw list", 
  '(try* (throw (list 1 2 3)) (catch* e e))', 
  '(1 2 3)', env)

# Catch with handler
test_eval("catch with str", 
  '(try* (throw "oops") (catch* e (str "Error: " e)))', 
  '"Error: oops"', env)

# Try without error
test_eval("try no error", 
  '(try* (+ 1 2) (catch* e "should not run"))', 
  '3', env)

# Nested try
test_eval("nested try inner catch", 
  '(try* 
     (try* (throw "inner") (catch* e (str "Inner: " e))) 
     (catch* e (str "Outer: " e)))', 
  '"Inner: inner"', env)

test_eval("nested try outer catch", 
  '(try* 
     (try* (throw "error") (catch* e (throw e))) 
     (catch* e (str "Outer: " e)))', 
  '"Outer: error"', env)

# Division by zero
test_eval("division by zero", 
  '(try* (/ 1 0) (catch* e "Division by zero!"))', 
  '"Division by zero!"', env)

# Undefined symbol
test_eval("undefined symbol", 
  '(try* undefined-symbol (catch* e "Symbol not found"))', 
  '"Symbol not found"', env)

# Function with throw
test_eval("define throwing function", 
  '(def! throwing-fn (fn* () (throw "from function")))', 
  '#<function>', env)

test_eval("call throwing function", 
  '(try* (throwing-fn) (catch* e (str "Caught: " e)))', 
  '"Caught: from function"', env)

# Multiple catch clauses (only first is used)
test_eval("try with handler body", 
  '(try* 
     (throw "error") 
     (catch* e 
       (do 
         (prn "Handling error:")
         (str "Handled: " e))))', 
  '"Handled: error"', env)

# Catch symbol binding
test_eval("catch binding scope", 
  '(try* 
     (do 
       (def! e "outer") 
       (throw "inner")) 
     (catch* e e))', 
  '"inner"', env)

test_eval("catch binding doesn't leak", 
  '(do 
     (def! e "before")
     (try* (throw "error") (catch* e e))
     e)', 
  '"before"', env)

# Re-throw
test_eval("re-throw", 
  '(try* 
     (try* 
       (throw "original") 
       (catch* e 
         (throw (str "wrapped: " e)))) 
     (catch* e e))', 
  '"wrapped: original"', env)

# Error cases
test_eval("try* no args", 
  '(try*)', 
  'ERROR: try* requires an expression', env)

test_eval("catch* not symbol", 
  '(try* (throw 1) (catch* 123 "fail"))', 
  'ERROR: catch* binding must be a symbol', env)

test_eval("throw no args", 
  '(throw)', 
  'ERROR: throw requires 1 argument', env)

# Macros with try/catch
test_eval("macro with try", 
  '(defmacro! safe-divide (fn* (a b) 
    `(try* (/ ~a ~b) (catch* e "Division error"))))', 
  '#<macro>', env)

test_eval("use safe-divide macro", 
  '(safe-divide 10 2)', 
  '5', env)

test_eval("use safe-divide with zero", 
  '(safe-divide 10 0)', 
  '"Division error"', env)

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)