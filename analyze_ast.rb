#!/usr/bin/env ruby

# Analyze the AST structure of mal_minimal.rb
# This helps understand which Ruby AST nodes we're using

require 'ripper'
require 'pp'

# Read the MAL implementation
code = File.read('mal_minimal.rb')

# Parse with Ripper
sexp = Ripper.sexp(code)

# Count node types
node_counts = {}

def count_nodes(sexp, counts)
  return unless sexp.is_a?(Array)
  
  if sexp[0].is_a?(Symbol) && sexp[0].to_s.start_with?(':')
    node_type = sexp[0]
    counts[node_type] = (counts[node_type] || 0) + 1
  end
  
  sexp.each do |child|
    count_nodes(child, counts) if child.is_a?(Array)
  end
end

count_nodes(sexp, node_counts)

# Sort by frequency
sorted_counts = node_counts.sort_by { |_, count| -count }

puts "Ruby AST Node Usage in mal_minimal.rb"
puts "=" * 40
puts "Total unique node types: #{sorted_counts.length}"
puts

puts "Top 20 most frequent nodes:"
sorted_counts.first(20).each_with_index do |(node, count), i|
  percentage = (count.to_f / sorted_counts.sum { |_, c| c } * 100).round(2)
  puts "#{i+1}. #{node}: #{count} (#{percentage}%)"
end

# Check for forbidden constructs
forbidden = {
  array_literal: sorted_counts.select { |node, _| node == :array },
  hash_literal: sorted_counts.select { |node, _| node == :hash },
  block: sorted_counts.select { |node, _| [:do_block, :brace_block].include?(node) }
}

puts "\nForbidden constructs check:"
forbidden.each do |construct, nodes|
  if nodes.empty?
    puts "✓ No #{construct} found"
  else
    puts "✗ Found #{construct}: #{nodes}"
  end
end

# Summary stats
total_nodes = sorted_counts.sum { |_, c| c }
def_count = sorted_counts.find { |node, _| node == :def }&.last || 0

puts "\nMethod definitions: #{def_count}"
puts "Total AST nodes: #{total_nodes}"