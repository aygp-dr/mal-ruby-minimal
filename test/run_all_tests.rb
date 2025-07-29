#!/usr/bin/env ruby

# Run all tests with code coverage
ENV['COVERAGE'] = '1'

require_relative 'test_helper'

puts "Running all tests with code coverage..."
puts "=" * 50

# List of test files
test_files = [
  'test_reader.rb',
  'test_printer.rb', 
  'test_env.rb',
  'test_step4.rb',
  'test_step7.rb'
]

total_tests = 0
total_passed = 0
total_failed = 0

test_files.each do |test_file|
  puts "\nRunning #{test_file}..."
  puts "-" * 40
  
  # Capture test output
  output = `ruby test/#{test_file} 2>&1`
  puts output
  
  # Extract test results
  if output =~ /(\d+)\/(\d+) tests passed/
    passed = $1.to_i
    tests = $2.to_i
    failed = tests - passed
    
    total_tests += tests
    total_passed += passed
    total_failed += failed
  elsif output =~ /(\d+) passed, (\d+) failed/
    passed = $1.to_i
    failed = $2.to_i
    tests = passed + failed
    
    total_tests += tests
    total_passed += passed
    total_failed += failed
  end
end

puts "\n" + "=" * 50
puts "TOTAL: #{total_passed}/#{total_tests} tests passed"

if total_failed > 0
  puts "#{total_failed} tests failed!"
  exit 1
else
  puts "All tests passed!"
  puts "\nCheck coverage/index.html for code coverage report"
end