#!/usr/bin/env ruby

# Comprehensive AST Analysis of Ruby Codebases (Error-resistant version)
# This script analyzes Ruby AST nodes used across representative Ruby codebases

require 'parser/current'
require 'find'
require 'json'

# Ruby Essence 13-node hypothesis
RUBY_ESSENCE_NODES = %w[
  send lvar const int str if def args begin return true false nil
].freeze

def analyze_ruby_files(directory, name, max_files = 50)
  puts "Analyzing #{name} (#{directory})..."
  
  node_counts = Hash.new(0)
  file_count = 0
  failed_files = 0
  total_nodes = 0
  
  ruby_files = []
  Find.find(directory) do |path|
    next unless path.end_with?('.rb')
    next if path.include?('vendor/') || path.include?('node_modules/') || path.include?('test/') || path.include?('spec/')
    ruby_files << path
    break if ruby_files.length >= max_files
  end
  
  ruby_files.each do |path|
    begin
      content = File.read(path)
      next if content.strip.empty?
      next if content.length > 50000  # Skip very large files
      
      ast = Parser::CurrentRuby.parse(content)
      next unless ast
      
      file_count += 1
      
      # Traverse AST and count nodes
      traverse_ast(ast) do |node|
        node_counts[node.type] += 1
        total_nodes += 1
      end
      
    rescue => e
      failed_files += 1
      # Skip files that can't be parsed
    end
  end
  
  {
    name: name,
    directory: directory,
    file_count: file_count,
    failed_files: failed_files,
    total_nodes: total_nodes,
    unique_types: node_counts.keys.length,
    node_counts: node_counts,
    essence_coverage: (node_counts.keys & RUBY_ESSENCE_NODES).length,
    essence_percentage: ((node_counts.keys & RUBY_ESSENCE_NODES).length / RUBY_ESSENCE_NODES.length.to_f * 100).round(1)
  }
end

def traverse_ast(node, &block)
  return unless node.is_a?(Parser::AST::Node)
  
  yield node
  
  node.children.each do |child|
    traverse_ast(child, &block)
  end
end

puts "=== COMPREHENSIVE RUBY AST NODE ANALYSIS ==="
puts "============================================="
puts

codebases = []

# Analyze representative Ruby codebases
representative_codebases = [
  ["/mnt/usb/ruby/activeadmin/activeadmin", "ActiveAdmin (Web Framework)"],
  ["/mnt/usb/ruby/DatabaseCleaner/database_cleaner", "Database Cleaner (Testing)"],
  ["/mnt/usb/ruby/Shopify/liquid", "Shopify Liquid (Template Engine)"],
  ["/mnt/usb/ruby/Shopify/bootsnap", "Shopify Bootsnap (Performance)"],
  ["/mnt/usb/ruby/aasm/aasm", "AASM (State Machine)"],
  ["/mnt/usb/ruby/rails/rails", "Rails (Framework)"]
]

representative_codebases.each do |dir, name|
  if Dir.exist?(dir)
    result = analyze_ruby_files(dir, name, 30)  # Limit to 30 files per codebase
    codebases << result if result[:file_count] > 0
  else
    puts "⚠️  Skipping #{name} - directory not found: #{dir}"
  end
end

# Always analyze our MAL implementation
puts
mal_result = analyze_ruby_files(".", "MAL Implementation", 100)
codebases << mal_result

puts
puts "=== ANALYSIS RESULTS ==="
puts "========================"

# Summary table
puts
printf "%-25s %5s %11s %12s %20s\n", "Codebase", "Files", "Total Nodes", "Unique Types", "Ruby Essence Coverage"
puts "-" * 80

codebases.each do |cb|
  coverage = "#{cb[:essence_coverage]}/#{RUBY_ESSENCE_NODES.length} (#{cb[:essence_percentage]}%)"
  printf "%-25s %5d %11d %12d %20s\n", 
    cb[:name].slice(0,24), cb[:file_count], cb[:total_nodes], cb[:unique_types], coverage
end

puts
puts "=== DETAILED NODE TYPE ANALYSIS ==="
puts "=================================="

# Collect ALL unique node types across all codebases
all_node_types = Set.new
codebases.each do |cb|
  all_node_types.merge(cb[:node_counts].keys)
end

puts
puts "TOTAL UNIQUE AST NODE TYPES FOUND: #{all_node_types.length}"
puts

# Check Ruby Essence hypothesis
essence_nodes_found = all_node_types & RUBY_ESSENCE_NODES
missing_essence_nodes = RUBY_ESSENCE_NODES - all_node_types
extra_nodes_used = all_node_types - RUBY_ESSENCE_NODES

puts "RUBY ESSENCE HYPOTHESIS ANALYSIS:"
puts "-" * 40
puts "Ruby Essence nodes found: #{essence_nodes_found.length}/#{RUBY_ESSENCE_NODES.length}"
essence_nodes_found.sort.each { |node| puts "  ✅ #{node}" }

if missing_essence_nodes.any?
  puts
  puts "Ruby Essence nodes NOT found:"
  missing_essence_nodes.sort.each { |node| puts "  ❌ #{node}" }
end

puts
puts "ADDITIONAL NODES BEYOND RUBY ESSENCE (#{extra_nodes_used.length}):"
puts "-" * 40
extra_nodes_used.sort.each { |node| puts "  + #{node}" }

puts
puts "=== FREQUENCY ANALYSIS ==="
puts "=========================="

# Find the most common nodes across all codebases
node_totals = Hash.new(0)
codebases.each do |cb|
  cb[:node_counts].each do |node, count|
    node_totals[node] += count
  end
end

# Sort by frequency
sorted_nodes = node_totals.sort_by { |node, count| -count }
total_usage = node_totals.values.sum

puts "Top 20 most used nodes across all codebases:"
puts
sorted_nodes.first(20).each_with_index do |(node, count), i|
  percentage = (count.to_f / total_usage * 100).round(2)
  essence_marker = RUBY_ESSENCE_NODES.include?(node) ? "🔥" : "  "
  puts "#{i+1}. #{essence_marker} #{node.ljust(15)} #{count.to_s.rjust(8)} (#{percentage.to_s.rjust(5)}%)"
end

puts
puts "=== HYPOTHESIS VALIDATION ==="
puts "============================"

if missing_essence_nodes.empty?
  puts "✅ All 13 Ruby Essence nodes are used across the analyzed codebases"
else
  puts "❌ Ruby Essence hypothesis is INCOMPLETE"
  puts "   Missing nodes: #{missing_essence_nodes.join(', ')}"
end

if extra_nodes_used.length > 20
  puts "❌ Ruby Essence hypothesis is INSUFFICIENT"
  puts "   Real Ruby code uses #{all_node_types.length} unique node types"
  puts "   That's #{extra_nodes_used.length} more than the proposed 13 nodes"
  puts "   Ratio: #{(extra_nodes_used.length.to_f / RUBY_ESSENCE_NODES.length).round(1)}x more nodes needed"
else
  puts "✅ Ruby Essence hypothesis covers most common patterns"
  puts "   Only #{extra_nodes_used.length} additional nodes needed for full coverage"
end

# Find a better minimal set
cumulative_percentage = 0
essential_nodes = []

sorted_nodes.each do |(node, count)|
  percentage = (count.to_f / total_usage * 100)
  cumulative_percentage += percentage
  essential_nodes << node
  break if cumulative_percentage >= 90.0
end

puts
puts "=== REVISED MINIMAL RUBY SUBSET ==="
puts "=================================="
puts "Nodes covering 90% of usage (#{essential_nodes.length} nodes):"
essential_nodes.each_with_index do |node, i|
  essence_marker = RUBY_ESSENCE_NODES.include?(node) ? "🔥" : "  "
  puts "  #{i+1}. #{essence_marker} #{node}"
end

puts
puts "=== CONCLUSION ==="
puts "================="

if essential_nodes.length <= 20
  puts "✅ A practical minimal Ruby subset can be defined with #{essential_nodes.length} nodes"
else
  puts "❌ Ruby requires a substantial number of AST node types (#{essential_nodes.length}) for practical use"
end

puts "Original Ruby Essence (13 nodes) covers #{(essence_nodes_found.length.to_f / all_node_types.length * 100).round(1)}% of all node types used"
puts "Recommended practical subset: #{essential_nodes.length} nodes"

# Save results
output_file = "experiments/002-ruby-ast-analysis/comprehensive-ast-results.json"
File.write(output_file, JSON.pretty_generate({
  analysis_date: Time.now.iso8601,
  ruby_essence_hypothesis: RUBY_ESSENCE_NODES,
  codebases_analyzed: codebases,
  all_node_types_found: all_node_types.sort,
  total_unique_types: all_node_types.length,
  essence_nodes_found: essence_nodes_found.sort,
  missing_essence_nodes: missing_essence_nodes.sort,
  extra_nodes_used: extra_nodes_used.sort,
  revised_ruby_essence: essential_nodes,
  node_frequency_analysis: sorted_nodes.to_h
}))

puts
puts "📄 Detailed results saved to: #{output_file}"