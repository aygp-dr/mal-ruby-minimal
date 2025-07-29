#!/usr/bin/env ruby

# Test just the functions from step4 without running REPL

require_relative '../reader'
require_relative '../printer'
require_relative '../env'

# Test the step4 implementation by running simple expressions
def test_step4
  puts "Testing Step 4 expressions..."
  puts "============================="
  
  test_expressions = [
    ['(+ 1 2)', '3'],
    ['(if true 1 2)', '1'],
    ['(if false 1 2)', '2'],
    ['(if nil 1 2)', '2'],
    ['(do 1 2 3)', '3'],
    ['((fn* (x) x) 5)', '5'],
    ['((fn* (x) (+ x 1)) 5)', '6'],
    ['((fn* (a b) (+ a b)) 2 3)', '5'],
  ]
  
  passed = 0
  failed = 0
  
  test_expressions.each do |expr, expected|
    result = `echo '#{expr}' | ruby step4_if_fn_do.rb 2>&1 | grep -A1 "user>" | tail -1`.strip
    
    if result == expected
      puts "✓ #{expr} => #{result}"
      passed += 1
    else
      puts "✗ #{expr}"
      puts "  Expected: #{expected}"
      puts "  Got: #{result}"
      failed += 1
    end
  end
  
  puts ""
  puts "#{passed} passed, #{failed} failed"
  exit(failed == 0 ? 0 : 1)
end

test_step4 if __FILE__ == $0