#!/usr/bin/env ruby

# Test step4 by loading the step4 file directly
# instead of running it as a separate process

puts "Testing Step 4 functional tests..."
puts "=================================="

# Remove step4 from load path to avoid re-running REPL
old_dollar_zero = $0
$0 = "test"

require_relative '../reader'
require_relative '../printer'
require_relative '../env'

# Load step4 definitions without running REPL
load File.join(File.dirname(__FILE__), '..', 'step4_if_fn_do.rb')

# Restore $0
$0 = old_dollar_zero

# Now run tests
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

env = create_repl_env

test_expressions.each do |expr, expected|
  begin
    result = rep(expr, env)
    
    if result == expected
      puts "✓ #{expr} => #{result}"
      passed += 1
    else
      puts "✗ #{expr}"
      puts "  Expected: #{expected}"
      puts "  Got: #{result}"
      failed += 1
    end
  rescue => e
    puts "✗ #{expr}"
    puts "  Expected: #{expected}"
    puts "  Got error: #{e.message}"
    failed += 1
  end
end

puts ""
puts "#{passed} passed, #{failed} failed"
exit(failed == 0 ? 0 : 1)