#!/usr/bin/env ruby

# Test step A self-hosting capabilities

require_relative 'stepA_mal'

def test_stepA_functions
  env = create_repl_env
  
  puts "Testing Step A Functions"
  puts "========================"
  
  tests = [
    # New list functions
    ["(nth (list 1 2 3) 1)", "2"],
    ["(first (list 1 2 3))", "1"],
    ["(rest (list 1 2 3))", "(2 3)"],
    
    # Apply function
    ["(apply + (list 1 2 3))", "6"],
    ["(apply * (list 2 3 4))", "24"],
    ["(apply list (list 1 2 3))", "(1 2 3)"],
    
    # Map function  
    ["(map (fn* (x) (+ x 1)) (list 1 2 3))", "(2 3 4)"],
    
    # Type predicates
    ["(nil? nil)", "true"],
    ["(nil? 1)", "false"],
    ["(number? 42)", "true"],
    ["(number? \"hello\")", "false"],
    ["(string? \"hello\")", "true"],
    ["(string? 42)", "false"],
    ["(symbol? 'x)", "true"],
    ["(symbol? \"x\")", "false"],
    
    # Vector operations
    ["(vector 1 2 3)", "[1 2 3]"],
    ["(vector? (vector 1 2 3))", "true"],
    ["(vector? (list 1 2 3))", "false"],
    
    # Hash-map operations
    ["(hash-map \"a\" 1 \"b\" 2)", "{\"a\" 1 \"b\" 2}"],
    ["(get (hash-map \"a\" 1 \"b\" 2) \"a\")", "1"],
    ["(contains? (hash-map \"a\" 1) \"a\")", "true"],
    ["(contains? (hash-map \"a\" 1) \"c\")", "false"],
    
    # Sequence operations
    ["(seq (list 1 2 3))", "(1 2 3)"],
    ["(seq nil)", "nil"],
    ["(sequential? (list 1 2 3))", "true"],
    ["(sequential? (vector 1 2 3))", "true"],
    ["(sequential? 42)", "false"],
    
    # Time function
    ["(> (time-ms) 0)", "true"],
  ]
  
  passed = 0
  failed = 0
  
  tests.each do |test_expr, expected|
    begin
      result = rep(test_expr, env)
      if result == expected
        puts "✓ #{test_expr} => #{result}"
        passed += 1
      else
        puts "✗ #{test_expr} => #{result} (expected #{expected})"
        failed += 1
      end
    rescue => e
      puts "✗ #{test_expr} => ERROR: #{e.message}"
      failed += 1
    end
  end
  
  puts ""
  puts "Results: #{passed} passed, #{failed} failed"
  puts ""
  
  if failed == 0
    puts "All Step A functions working correctly!"
    puts "Self-hosting prerequisites satisfied."
  else
    puts "Some functions need fixes before self-hosting."
  end
end

if __FILE__ == $0
  test_stepA_functions
end