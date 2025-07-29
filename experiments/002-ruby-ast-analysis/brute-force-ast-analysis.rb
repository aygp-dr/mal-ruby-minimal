#!/usr/bin/env ruby

# Brute Force Ruby AST Analysis using Ruby's built-in --dump=parsetree
# This script analyzes ALL Ruby files in /mnt/usb/ruby to find all AST node types

require 'find'
require 'json'
require 'tmpdir'

puts "=== BRUTE FORCE RUBY AST ANALYSIS ==="
puts "====================================="
puts

# Ruby Essence 13-node hypothesis
RUBY_ESSENCE_NODES = %w[
  send lvar const int str if def args begin return true false nil
].freeze

def extract_ast_nodes_from_file(file_path)
  # Use Ruby's built-in AST dumper
  ast_output = `ruby --dump=parsetree "#{file_path}" 2>/dev/null`
  
  return [] if ast_output.empty? || $?.exitstatus != 0
  
  # Parse the AST output to extract node types
  # Ruby's AST format looks like: NODE_SEND, NODE_LVAR, etc.
  node_types = ast_output.scan(/NODE_(\w+)/).flatten.map(&:downcase).uniq
  
  node_types
rescue => e
  []
end

def analyze_directory(dir_path, name, max_files = 100)
  puts "Analyzing #{name} (#{dir_path})..."
  
  node_counts = Hash.new(0)
  all_node_types = Set.new
  file_count = 0
  failed_files = 0
  
  ruby_files = []
  
  # Find all Ruby files
  Find.find(dir_path) do |path|
    next unless File.file?(path) && path.end_with?('.rb')
    next if path.include?('vendor/') || path.include?('node_modules/')
    next if path.include?('test/') || path.include?('spec/') # Skip test files for now
    ruby_files << path
    break if ruby_files.length >= max_files
  end
  
  puts "  Found #{ruby_files.length} Ruby files to analyze..."
  
  ruby_files.each_with_index do |file_path, i|
    if i % 10 == 0
      print "  Progress: #{i}/#{ruby_files.length}\r"
    end
    
    begin
      # Skip very large files to avoid timeout
      file_size = File.size(file_path)
      if file_size > 100_000  # Skip files larger than 100KB
        failed_files += 1
        next
      end
      
      node_types = extract_ast_nodes_from_file(file_path)
      
      if node_types.empty?
        failed_files += 1
        next
      end
      
      file_count += 1
      
      node_types.each do |node_type|
        node_counts[node_type] += 1
        all_node_types.add(node_type)
      end
      
    rescue => e
      failed_files += 1
    end
  end
  
  puts "  Completed: #{file_count} files analyzed, #{failed_files} failed"
  
  {
    name: name,
    directory: dir_path,
    file_count: file_count,
    failed_files: failed_files,
    total_unique_types: all_node_types.length,
    node_counts: node_counts,
    all_node_types: all_node_types.to_a.sort,
    essence_coverage: (all_node_types & RUBY_ESSENCE_NODES).length,
    essence_percentage: ((all_node_types & RUBY_ESSENCE_NODES).length / RUBY_ESSENCE_NODES.length.to_f * 100).round(1)
  }
end

# Analyze major Ruby codebases
codebases = []

# Select representative codebases for analysis
major_codebases = [
  ["/mnt/usb/ruby/rails/rails", "Rails Framework"],
  ["/mnt/usb/ruby/activeadmin/activeadmin", "ActiveAdmin"],
  ["/mnt/usb/ruby/Shopify/liquid", "Shopify Liquid"],
  ["/mnt/usb/ruby/Shopify/bootsnap", "Shopify Bootsnap"],
  ["/mnt/usb/ruby/DatabaseCleaner/database_cleaner", "Database Cleaner"],
  ["/mnt/usb/ruby/aasm/aasm", "AASM State Machine"],
  ["/mnt/usb/ruby/rspec/rspec-core", "RSpec Core"],
  ["/mnt/usb/ruby/rubocop/rubocop", "RuboCop"],
  ["/mnt/usb/ruby/puma/puma", "Puma Web Server"],
  ["/mnt/usb/ruby/sidekiq/sidekiq", "Sidekiq"]
]

puts "Analyzing representative Ruby codebases..."
puts

major_codebases.each do |dir, name|
  if Dir.exist?(dir)
    result = analyze_directory(dir, name, 50)  # Limit to 50 files per codebase
    codebases << result if result[:file_count] > 0
  else
    puts "⚠️  Skipping #{name} - directory not found: #{dir}"
  end
end

# Analyze our MAL implementation
puts
mal_result = analyze_directory(".", "MAL Implementation", 100)
codebases << mal_result

puts
puts "=== COMPREHENSIVE RESULTS ==="
puts "============================"

# Collect ALL unique node types across all codebases
all_unique_nodes = Set.new
total_files_analyzed = 0

codebases.each do |cb|
  all_unique_nodes.merge(cb[:all_node_types])
  total_files_analyzed += cb[:file_count]
end

puts
puts "SUMMARY:"
puts "  Total files analyzed: #{total_files_analyzed}"
puts "  Total unique AST node types found: #{all_unique_nodes.length}"
puts

# Results table
printf "%-20s %6s %8s %15s %20s\n", "Codebase", "Files", "Types", "Essence Coverage", "Notes"
puts "-" * 80

codebases.each do |cb|
  coverage = "#{cb[:essence_coverage]}/#{RUBY_ESSENCE_NODES.length} (#{cb[:essence_percentage]}%)"
  printf "%-20s %6d %8d %15s\n", 
    cb[:name].slice(0,19), cb[:file_count], cb[:total_unique_types], coverage
end

puts
puts "=== ALL UNIQUE AST NODE TYPES FOUND ==="
puts "======================================"

all_unique_nodes_sorted = all_unique_nodes.sort

puts "Found #{all_unique_nodes_sorted.length} unique AST node types:"
puts

# Categorize nodes
essence_found = all_unique_nodes_sorted & RUBY_ESSENCE_NODES
missing_essence = RUBY_ESSENCE_NODES - all_unique_nodes_sorted
extra_nodes = all_unique_nodes_sorted - RUBY_ESSENCE_NODES

puts "RUBY ESSENCE NODES FOUND (#{essence_found.length}/#{RUBY_ESSENCE_NODES.length}):"
essence_found.each { |node| puts "  ✅ #{node}" }

if missing_essence.any?
  puts
  puts "RUBY ESSENCE NODES NOT FOUND:"
  missing_essence.each { |node| puts "  ❌ #{node}" }
end

puts
puts "ADDITIONAL NODES BEYOND RUBY ESSENCE (#{extra_nodes.length}):"
extra_nodes.each { |node| puts "  + #{node}" }

puts
puts "=== FREQUENCY ANALYSIS ==="
puts "=========================="

# Calculate total usage across all codebases
node_totals = Hash.new(0)
codebases.each do |cb|
  cb[:node_counts].each do |node, count|
    node_totals[node] += count
  end
end

# Sort by frequency
sorted_by_frequency = node_totals.sort_by { |node, count| -count }
total_node_usage = node_totals.values.sum

puts "Top 25 most frequently used AST nodes:"
puts

sorted_by_frequency.first(25).each_with_index do |(node, count), i|
  percentage = (count.to_f / total_node_usage * 100).round(2)
  essence_marker = RUBY_ESSENCE_NODES.include?(node) ? "🔥" : "  "
  printf "%2d. %s %-15s %8d (%5.2f%%)\n", i+1, essence_marker, node, count, percentage
end

puts
puts "=== HYPOTHESIS VALIDATION ==="
puts "============================"

coverage_percentage = (essence_found.length.to_f / all_unique_nodes_sorted.length * 100).round(1)

puts "Ruby Essence Hypothesis Analysis:"
puts "  - Proposed 13 essential nodes"
puts "  - Found #{essence_found.length}/13 in real codebases (#{(essence_found.length.to_f/13*100).round(1)}%)"
puts "  - Real codebases use #{all_unique_nodes_sorted.length} total unique node types"
puts "  - Ruby Essence covers #{coverage_percentage}% of all node types used"

if missing_essence.empty?
  puts "  ✅ All Ruby Essence nodes are used in practice"
else
  puts "  ❌ Some Ruby Essence nodes are not found in analyzed codebases"
end

if extra_nodes.length > 20
  puts "  ❌ Ruby Essence is insufficient - #{extra_nodes.length} additional nodes needed"
  puts "  📊 Ratio: #{(extra_nodes.length.to_f / RUBY_ESSENCE_NODES.length).round(1)}x more nodes than proposed"
else
  puts "  ✅ Ruby Essence captures most essential patterns"
end

# Propose a revised minimal set
cumulative_percentage = 0
practical_minimal_set = []

sorted_by_frequency.each do |(node, count)|
  percentage = (count.to_f / total_node_usage * 100)
  cumulative_percentage += percentage
  practical_minimal_set << node
  break if cumulative_percentage >= 85.0
end

puts
puts "PRACTICAL MINIMAL RUBY SUBSET (85% coverage):"
puts "#{practical_minimal_set.length} nodes: #{practical_minimal_set.join(', ')}"

# Save comprehensive results
output_file = "experiments/002-ruby-ast-analysis/brute-force-ast-results.json"
results = {
  analysis_date: Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"),
  analysis_method: "Ruby built-in --dump=parsetree",
  ruby_essence_hypothesis: RUBY_ESSENCE_NODES,
  total_files_analyzed: total_files_analyzed,
  codebases_analyzed: codebases,
  all_unique_nodes: all_unique_nodes_sorted,
  total_unique_types: all_unique_nodes_sorted.length,
  essence_nodes_found: essence_found,
  missing_essence_nodes: missing_essence,
  extra_nodes_beyond_essence: extra_nodes,
  node_frequency_ranking: sorted_by_frequency.to_h,
  practical_minimal_set_85_percent: practical_minimal_set,
  coverage_analysis: {
    essence_coverage_percentage: coverage_percentage,
    essence_sufficiency: missing_essence.empty? && extra_nodes.length <= 20
  }
}

File.write(output_file, JSON.pretty_generate(results))

puts
puts "=== CONCLUSION ==="
puts "================="

if coverage_percentage >= 75.0
  puts "✅ Ruby Essence hypothesis has strong empirical support (#{coverage_percentage}% coverage)"
else
  puts "❌ Ruby Essence hypothesis needs revision (only #{coverage_percentage}% coverage)"
end

puts "📊 Empirical findings:"
puts "  - #{total_files_analyzed} Ruby files analyzed across #{codebases.length} major codebases"
puts "  - #{all_unique_nodes_sorted.length} unique AST node types in active use"
puts "  - Practical minimal set: #{practical_minimal_set.length} nodes (85% coverage)"
puts "  - Ruby Essence prediction accuracy: #{(essence_found.length.to_f/13*100).round(1)}%"

puts
puts "📄 Detailed results saved to: #{output_file}"