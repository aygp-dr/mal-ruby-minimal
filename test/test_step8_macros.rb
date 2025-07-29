#!/usr/bin/env ruby

# Test step 8 - Macros

require_relative '../step8_macros'

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

puts "Testing Step 8 - Macros..."
puts "========================="

# Basic macro definition
test_eval("defmacro! basic", 
  '(defmacro! one (fn* () 1))', 
  '#<macro>', env)

test_eval("call basic macro", 
  '(one)', 
  '1', env)

# Macro with arguments
test_eval("defmacro! with args", 
  '(defmacro! unless (fn* (pred a b) (list (quote if) pred b a)))', 
  '#<macro>', env)

test_eval("unless true", 
  '(unless false 7 8)', 
  '7', env)

test_eval("unless false", 
  '(unless true 7 8)', 
  '8', env)

# Macroexpand
test_eval("macroexpand basic", 
  '(macroexpand (one))', 
  '1', env)

test_eval("macroexpand unless", 
  '(macroexpand (unless false 7 8))', 
  '(if false 8 7)', env)

# Nested macro expansion
test_eval("defmacro! or", 
  '(defmacro! or (fn* (a b) (list (quote if) a a b)))', 
  '#<macro>', env)

test_eval("or true false", 
  '(or 1 2)', 
  '1', env)

test_eval("or false true", 
  '(or false 2)', 
  '2', env)

test_eval("or false false", 
  '(or false false)', 
  'false', env)

# Macro using quasiquote
test_eval("defmacro! with quasiquote", 
  '(defmacro! and (fn* (a b) `(if ~a ~b false)))', 
  '#<macro>', env)

test_eval("and true true", 
  '(and true true)', 
  'true', env)

test_eval("and true false", 
  '(and true false)', 
  'false', env)

test_eval("and false true", 
  '(and false true)', 
  'false', env)

# Complex macro
test_eval("defmacro! let", 
  '(defmacro! let (fn* (bindings body) 
    `((fn* ~(map (fn* (b) (car b)) bindings) ~body) 
      ~@(map (fn* (b) (car (cdr b))) bindings))))', 
  '#<macro>', env)

# First define map if not available
test_eval("define map", 
  '(def! map (fn* (f lst) 
    (if (empty? lst) 
      nil 
      (cons (f (car lst)) (map f (cdr lst))))))', 
  '#<function>', env)

# Now test let macro
test_eval("let macro", 
  '(let ((x 2) (y 3)) (+ x y))', 
  '5', env)

# Recursive macro expansion
# (unless false false true) -> (if false true false) -> false
# (unless false 10 20) -> (if false 20 10) -> 10
test_eval("nested unless", 
  '(unless (unless false false true) 10 20)', 
  '10', env)

# Macro that doesn't evaluate args
test_eval("defmacro! quote-args", 
  '(defmacro! quote-args (fn* (a b) (list (quote list) (list (quote quote) a) (list (quote quote) b))))', 
  '#<macro>', env)

test_eval("quote-args test", 
  '(quote-args (+ 1 2) (+ 3 4))', 
  '((+ 1 2) (+ 3 4))', env)

# Error cases
test_eval("defmacro! no args", 
  '(defmacro!)', 
  'ERROR: defmacro! requires 2 arguments', env)

test_eval("defmacro! not symbol", 
  '(defmacro! 123 (fn* () 1))', 
  'ERROR: defmacro! first argument must be a symbol', env)

test_eval("defmacro! not function", 
  '(defmacro! foo 123)', 
  'ERROR: defmacro! value must be a function', env)

# Summary
puts ""
puts "#{$pass_count}/#{$test_count} tests passed"
exit($pass_count == $test_count ? 0 : 1)