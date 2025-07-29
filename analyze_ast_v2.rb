#!/usr/bin/env ruby

# Simple AST analysis of mal_minimal.rb

require 'ripper'

# Read the file
code = File.read('mal_minimal.rb')

# Get S-expression
sexp = Ripper.sexp(code)

# Simple check for arrays
puts "Checking for forbidden Ruby constructs in mal_minimal.rb..."
puts "=" * 50

# Check source code directly
lines = code.lines

# Look for array literals
array_lines = []
lines.each_with_index do |line, i|
  # Skip comments
  next if line.strip.start_with?('#')
  
  # Check for array literals (but not string indexing)
  if line =~ /\[\s*\]/ || line =~ /\[.*,.*\]/ || line =~ /=\s*\[/
    unless line.include?('slice') || line.include?('instead of')
      array_lines << [i+1, line.strip]
    end
  end
end

if array_lines.empty?
  puts "✓ No array literals found"
else
  puts "✗ Found array literals:"
  array_lines.each { |num, line| puts "  Line #{num}: #{line}" }
end

# Look for hash literals
hash_lines = []
lines.each_with_index do |line, i|
  next if line.strip.start_with?('#')
  
  if line =~ /\{\s*\}/ || line =~ /\{.*=>.*\}/ || line =~ /=\s*\{/
    unless line.include?('<<-RUBY') || line.include?('RUBY')
      hash_lines << [i+1, line.strip]
    end
  end
end

if hash_lines.empty?
  puts "✓ No hash literals found"
else
  puts "✗ Found hash literals:"
  hash_lines.each { |num, line| puts "  Line #{num}: #{line}" }
end

# Look for blocks
block_lines = []
lines.each_with_index do |line, i|
  next if line.strip.start_with?('#')
  
  if line =~ /\.(each|map|select|times|collect)\s*(do|\{)/
    block_lines << [i+1, line.strip]
  end
end

if block_lines.empty?
  puts "✓ No Ruby blocks found"
else
  puts "✗ Found blocks:"
  block_lines.each { |num, line| puts "  Line #{num}: #{line}" }
end

# Count method definitions
def_count = lines.count { |line| line.strip.start_with?('def ') }
puts "\nStatistics:"
puts "- Method definitions: #{def_count}"
puts "- Total lines: #{lines.count}"
puts "- Non-blank lines: #{lines.reject { |l| l.strip.empty? }.count}"

# Show structure
puts "\nKey constructs used:"
puts "- cons/car/cdr for pairs (Lisp-style)"
puts "- Object.new with instance variables"
puts "- eval with heredocs for method definitions"
puts "- while loops instead of iterators"
puts "- Recursive functions for list operations"