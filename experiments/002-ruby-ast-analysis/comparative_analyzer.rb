#!/usr/bin/env ruby

# Comparative AST Analysis
# Compare our MAL implementation with other Ruby codebases

require 'parser/current'
require 'json'

class ComparativeAnalyzer
  RUBY_ESSENCE_NODES = %w[
    send lvar const int str if def args begin return true false nil
  ]

  def initialize
    @comparisons = {}
  end

  def analyze_codebase(name, file_patterns, max_files = 50)
    puts "🔍 Analyzing #{name}..."
    
    files = file_patterns.flat_map { |pattern| Dir.glob(pattern) }
                        .select { |f| f.end_with?('.rb') }
                        .first(max_files)
    
    node_counts = Hash.new(0)
    total_files = 0
    failed_files = 0
    
    files.each do |file|
      next unless File.exist?(file)
      
      begin
        source = File.read(file)
        ast = Parser::CurrentRuby.parse(source)
        next unless ast
        
        traverse_and_count(ast, node_counts)
        total_files += 1
        
      rescue Parser::SyntaxError, Encoding::InvalidByteSequenceError => e
        failed_files += 1
      rescue => e
        failed_files += 1
      end
    end
    
    @comparisons[name] = analyze_distribution(node_counts, total_files, failed_files)
    puts "  ✅ #{total_files} files analyzed, #{failed_files} failed"
  end

  private

  def traverse_and_count(node, counts)
    return unless node.is_a?(Parser::AST::Node)
    
    counts[node.type] += 1
    
    node.children.each do |child|
      next unless child.is_a?(Parser::AST::Node)
      traverse_and_count(child, counts)
    end
  end

  def analyze_distribution(node_counts, total_files, failed_files)
    total_nodes = node_counts.values.sum
    unique_types = node_counts.keys.length
    essence_found = (node_counts.keys.map(&:to_s) & RUBY_ESSENCE_NODES).length
    essence_percentage = (essence_found.to_f / RUBY_ESSENCE_NODES.length * 100).round(1)
    
    top_nodes = node_counts.sort_by { |_, count| -count }.first(10)
    
    {
      total_files: total_files,
      failed_files: failed_files,
      total_nodes: total_nodes,
      unique_types: unique_types,
      essence_coverage: essence_found,
      essence_percentage: essence_percentage,
      top_nodes: top_nodes.to_h,
      node_distribution: node_counts
    }
  end

  public

  def generate_comparison_report
    puts "\n" + "=" * 70
    puts "🔬 COMPARATIVE AST ANALYSIS REPORT"
    puts "=" * 70

    # Summary table
    puts "\n📊 SUMMARY COMPARISON"
    puts "-" * 50
    printf "%-20s %8s %8s %8s %10s\n", "Codebase", "Files", "Nodes", "Types", "Essence %"
    puts "-" * 50

    @comparisons.each do |name, data|
      printf "%-20s %8d %8d %8d %9.1f%%\n",
             name.truncate(20),
             data[:total_files],
             data[:total_nodes],
             data[:unique_types],
             data[:essence_percentage]
    end

    # Detailed analysis
    @comparisons.each do |name, data|
      puts "\n" + "=" * 40
      puts "📁 #{name.upcase}"
      puts "=" * 40
      
      puts "\nTop AST Nodes:"
      data[:top_nodes].each_with_index do |(type, count), index|
        essence_mark = RUBY_ESSENCE_NODES.include?(type.to_s) ? "⭐" : "  "
        percentage = (count.to_f / data[:total_nodes] * 100).round(1)
        printf "%2d. %s %-12s %8d %6.1f%%\n", index + 1, essence_mark, type, count, percentage
      end
      
      essence_found = data[:node_distribution].keys.map(&:to_s) & RUBY_ESSENCE_NODES
      essence_missing = RUBY_ESSENCE_NODES - data[:node_distribution].keys.map(&:to_s)
      
      puts "\n✅ Ruby Essence Coverage (#{essence_found.length}/13):"
      essence_found.sort.each do |node|
        count = data[:node_distribution][node.to_sym] || 0
        printf "   %-12s %8d occurrences\n", node, count
      end
      
      if essence_missing.any?
        puts "\n❌ Missing Essence Nodes:"
        essence_missing.each { |node| puts "   #{node}" }
      end
    end

    # Save detailed comparison
    save_comparison_data
  end

  private

  def save_comparison_data
    output_file = "experiments/002-ruby-ast-analysis/comparative_analysis.json"
    File.write(output_file, JSON.pretty_generate(@comparisons))
    puts "\n💾 Comparative analysis saved to: #{output_file}"
  end
end

class String
  def truncate(length)
    self.length > length ? self[0..length-4] + "..." : self
  end
end

if __FILE__ == $0
  analyzer = ComparativeAnalyzer.new
  
  # Analyze our MAL implementation
  analyzer.analyze_codebase("MAL Implementation", [
    "*.rb",
    "test/*.rb"
  ])
  
  # Analyze Rails/ActiveAdmin (web framework)
  analyzer.analyze_codebase("ActiveAdmin (Rails)", [
    "/mnt/usb/ruby/activeadmin/activeadmin/app/**/*.rb",
    "/mnt/usb/ruby/activeadmin/activeadmin/lib/**/*.rb"
  ], 30)
  
  # Analyze a CLI tool
  analyzer.analyze_codebase("Database Cleaner", [
    "/mnt/usb/ruby/DatabaseCleaner/database_cleaner*/lib/**/*.rb"
  ], 20)
  
  # Analyze a DSL/Framework
  analyzer.analyze_codebase("AASM (State Machine)", [
    "/mnt/usb/ruby/aasm/lib/**/*.rb"
  ], 20)
  
  # Analyze Shopify (ecommerce)
  analyzer.analyze_codebase("Shopify Tools", [
    "/mnt/usb/ruby/Shopify/*/lib/**/*.rb"
  ], 40)

  analyzer.generate_comparison_report
end