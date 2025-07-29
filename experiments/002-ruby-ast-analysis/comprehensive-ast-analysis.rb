#!/usr/bin/env ruby

# Comprehensive AST Analysis of ALL Ruby Codebases
# This script analyzes ALL Ruby AST nodes used across multiple Ruby codebases
# to validate or refute the Ruby Essence 13-node hypothesis

require 'parser/current'
require 'find'
require 'json'

puts "=== COMPREHENSIVE RUBY AST NODE ANALYSIS ==="
puts "============================================="
puts

# Ruby Essence 13-node hypothesis
RUBY_ESSENCE_NODES = %w[
  send lvar const int str if def args begin return true false nil
].freeze

def analyze_ruby_files(directory, name)
  puts "Analyzing #{name} (#{directory})..."
  
  node_counts = Hash.new(0)
  file_count = 0
  failed_files = 0
  total_nodes = 0
  
  Find.find(directory) do |path|
    next unless path.end_with?('.rb')
    next if path.include?('vendor/') || path.include?('node_modules/')
    
    begin
      content = File.read(path)
      next if content.strip.empty?
      
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

# Analyze multiple Ruby codebases
codebases = []

# Check what's available in /mnt/usb/ruby
ruby_dir = "/mnt/usb/ruby"
if Dir.exist?(ruby_dir)
  puts "Found Ruby codebases directory: #{ruby_dir}"
  
  # Look for subdirectories that contain Ruby files
  Dir.entries(ruby_dir).each do |entry|
    path = File.join(ruby_dir, entry)
    next unless Dir.exist?(path)
    next if entry.start_with?('.')
    
    # Check if this directory contains Ruby files
    has_ruby_files = false
    Find.find(path) do |file_path|
      if file_path.end_with?('.rb')
        has_ruby_files = true
        break
      end
    end
    
    if has_ruby_files
      puts "  - Found Ruby codebase: #{entry}"
      result = analyze_ruby_files(path, entry)
      codebases << result if result[:file_count] > 0
    end
  end
else
  puts "⚠️  Ruby codebases directory not found: #{ruby_dir}"
  puts "   Analyzing only our MAL implementation"
end

# Always analyze our MAL implementation
puts
mal_result = analyze_ruby_files(".", "MAL Implementation")
codebases << mal_result

puts
puts "=== ANALYSIS RESULTS ==="
puts "========================"

# Summary table
puts
puts "| Codebase | Files | Total Nodes | Unique Types | Ruby Essence Coverage |"
puts "|----------|-------|-------------|--------------|----------------------|"

codebases.each do |cb|
  coverage = "#{cb[:essence_coverage]}/#{RUBY_ESSENCE_NODES.length} (#{cb[:essence_percentage]}%)"
  puts "| #{cb[:name].ljust(18)} | #{cb[:file_count].to_s.rjust(5)} | #{cb[:total_nodes].to_s.rjust(11)} | #{cb[:unique_types].to_s.rjust(12)} | #{coverage.ljust(20)} |"
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
essence_nodes_found.each { |node| puts "  ✅ #{node}" }

if missing_essence_nodes.any?
  puts
  puts "Ruby Essence nodes NOT found:"
  missing_essence_nodes.each { |node| puts "  ❌ #{node}" }
end

puts
puts "ADDITIONAL NODES BEYOND RUBY ESSENCE (#{extra_nodes_used.length}):"
puts "-" * 40
extra_nodes_used.sort.each { |node| puts "  + #{node}" }

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
else
  puts "✅ Ruby Essence hypothesis covers most common patterns"
  puts "   Only #{extra_nodes_used.length} additional nodes needed for full coverage"
end

puts
puts "=== REVISED RUBY ESSENCE PROPOSAL ==="
puts "===================================="

# Find the most common nodes across all codebases
node_totals = Hash.new(0)
codebases.each do |cb|
  cb[:node_counts].each do |node, count|
    node_totals[node] += count
  end
end

# Sort by frequency and take top nodes that cover 90% of usage
sorted_nodes = node_totals.sort_by { |node, count| -count }
total_usage = node_totals.values.sum
cumulative_percentage = 0
essential_nodes = []

puts "Top nodes by usage frequency:"
puts
sorted_nodes.each_with_index do |(node, count), i|
  percentage = (count.to_f / total_usage * 100).round(2)
  cumulative_percentage += percentage
  
  puts "#{i+1}. #{node.ljust(15)} #{count.to_s.rjust(8)} (#{percentage.to_s.rjust(5)}%) [cumulative: #{cumulative_percentage.round(1)}%]"
  
  essential_nodes << node
  break if cumulative_percentage >= 90.0
end

puts
puts "REVISED RUBY ESSENCE (#{essential_nodes.length} nodes covering 90% of usage):"
puts essential_nodes.join(' ')

puts
puts "=== CONCLUSION ==="
puts "================="

puts "The original 13-node Ruby Essence hypothesis is:"
if missing_essence_nodes.empty? && extra_nodes_used.length <= 10
  puts "✅ MOSTLY CORRECT - covers essential patterns with minimal additions needed"
else
  puts "❌ INSUFFICIENT - real Ruby code requires significantly more node types"
end

puts
puts "Recommended minimal Ruby subset: #{essential_nodes.length} nodes"
puts "This covers 90% of actual Ruby AST node usage patterns."

# Save detailed results
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