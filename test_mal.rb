#!/usr/bin/env ruby

# Test suite for MAL minimal implementation

require_relative 'mal_minimal'

# Test helper
def test(name, expected, actual)
  if expected == actual
    puts "✓ #{name}"
  else
    puts "✗ #{name}"
    puts "  Expected: #{expected}"
    puts "  Actual: #{actual}"
  end
end

puts "MAL Minimal Test Suite"
puts "=" * 40

# Create environment
env = create_root_env

# Basic arithmetic
test("Addition", "3", rep("(+ 1 2)", env))
test("Subtraction", "5", rep("(- 10 5)", env))
test("Multiplication", "20", rep("(* 4 5)", env))
test("Division", "3", rep("(/ 12 4)", env))

# Variables
rep("(def x 42)", env)
test("Variable definition", "42", rep("x", env))

# Functions
rep("(def inc (fn (n) (+ n 1)))", env)
test("Function definition", "6", rep("(inc 5)", env))

# Lists
rep("(def lst (list 1 2 3))", env)
test("List creation", "(1 2 3)", rep("lst", env))
test("Car", "1", rep("(car lst)", env))
test("Cdr", "(2 3)", rep("(cdr lst)", env))
test("Cons", "(0 1 2 3)", rep("(cons 0 lst)", env))

# Conditionals
test("If true", "yes", rep("(if true (quote yes) (quote no))", env))
test("If false", "no", rep("(if false (quote yes) (quote no))", env))
test("If with comparison", "5", rep("(if (> 5 3) 5 3)", env))

# Recursion
rep("(def fact (fn (n) (if (= n 0) 1 (* n (fact (- n 1))))))", env)
test("Factorial", "120", rep("(fact 5)", env))

# Higher-order functions
rep("(def map (fn (f lst) (if (null? lst) nil (cons (f (car lst)) (map f (cdr lst))))))", env)
test("Map with inc", "(2 3 4)", rep("(map inc (list 1 2 3))", env))

# Do form
test("Do form", "42", rep("(do (+ 1 1) (+ 2 2) 42)", env))

# Quote
test("Quote symbol", "hello", rep("(quote hello)", env))
test("Quote list", "(+ 1 2)", rep("(quote (+ 1 2))", env))

puts "\nMAL Features Demonstrated:"
puts "- S-expression parsing without arrays"
puts "- First-class functions and closures"
puts "- Recursive function definitions"
puts "- List processing with cons cells"
puts "- Special forms (def, if, fn, quote, do)"
puts "- Environment-based variable scoping"