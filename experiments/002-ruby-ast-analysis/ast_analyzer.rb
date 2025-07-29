#!/usr/bin/env ruby

# Ruby AST Analysis Tool
# Analyzes the AST nodes used in our MAL implementation

require 'parser/current'
require 'json'

class ASTAnalyzer
  # Ruby Essence "essential 13" node types
  RUBY_ESSENCE_NODES = %w[
    send lvar const int str if def args begin return true false nil
  ]

  def initialize
    @node_counts = Hash.new(0)
    @file_nodes = Hash.new { |h, k| h[k] = Hash.new(0) }
    @control_flow_patterns = []
    @method_definitions = []
    @complexity_metrics = Hash.new(0)
  end

  def analyze_files(file_patterns)
    files = file_patterns.flat_map { |pattern| Dir.glob(pattern) }
    
    puts "Analyzing #{files.length} Ruby files..."
    puts "=" * 50
    
    files.each do |file|
      next unless File.exist?(file) && file.end_with?('.rb')
      analyze_file(file)
    end
    
    generate_report
  end

  private

  def analyze_file(filename)
    puts "📁 #{filename}"
    
    begin
      source = File.read(filename)
      ast = Parser::CurrentRuby.parse(source)
      return unless ast
      
      traverse_node(ast, filename)
      
    rescue Parser::SyntaxError => e
      puts "  ⚠️  Syntax error: #{e.message}"
    rescue => e
      puts "  ❌ Error: #{e.message}"
    end
  end

  def traverse_node(node, filename, depth = 0)
    return unless node.is_a?(Parser::AST::Node)
    
    node_type = node.type
    @node_counts[node_type] += 1
    @file_nodes[filename][node_type] += 1
    
    # Track complexity
    case node_type
    when :if, :case, :while, :until, :for
      @complexity_metrics[:conditionals] += 1
    when :def, :defs
      @complexity_metrics[:methods] += 1
      analyze_method_definition(node, filename)
    when :class, :module
      @complexity_metrics[:classes] += 1
    when :send
      analyze_method_call(node, filename, depth)
    end
    
    # Recursively analyze children
    node.children.each do |child|
      next unless child.is_a?(Parser::AST::Node)
      traverse_node(child, filename, depth + 1)
    end
  end

  def analyze_method_definition(node, filename)
    method_name = node.children[0]
    args_node = node.children[1]
    body_node = node.children[2]
    
    arg_count = count_arguments(args_node)
    body_complexity = calculate_complexity(body_node)
    
    @method_definitions << {
      file: filename,
      name: method_name,
      args: arg_count,
      complexity: body_complexity
    }
  end

  def analyze_method_call(node, filename, depth)
    receiver = node.children[0]
    method_name = node.children[1]
    args = node.children[2..-1]
    
    # Track important patterns
    if method_name == :eval && receiver.nil?
      @control_flow_patterns << {
        type: :eval_usage,
        file: filename,
        depth: depth
      }
    end
    
    if method_name == :instance_variable_set
      @control_flow_patterns << {
        type: :metaprogramming,
        file: filename,
        method: method_name,
        depth: depth
      }
    end
  end

  def count_arguments(args_node)
    return 0 unless args_node&.type == :args
    args_node.children.length
  end

  def calculate_complexity(node)
    return 0 unless node
    
    complexity = 0
    complexity += 1 if [:if, :case, :while, :until, :for].include?(node.type)
    
    if node.is_a?(Parser::AST::Node)
      node.children.each do |child|
        complexity += calculate_complexity(child)
      end
    end
    
    complexity
  end

  def generate_report
    puts "\n" + "=" * 60
    puts "🔍 RUBY AST ANALYSIS REPORT"
    puts "=" * 60
    
    generate_summary
    generate_node_frequency_report
    generate_ruby_essence_analysis  
    generate_complexity_report
    generate_file_breakdown
    generate_control_flow_report
    generate_method_analysis
    
    save_detailed_data
  end

  def generate_summary
    total_nodes = @node_counts.values.sum
    unique_types = @node_counts.keys.length
    essence_nodes = (@node_counts.keys.map(&:to_s) & RUBY_ESSENCE_NODES).length
    essence_percentage = (essence_nodes.to_f / unique_types * 100).round(1)
    
    puts "\n📊 SUMMARY"
    puts "-" * 20
    puts "Total AST nodes analyzed: #{total_nodes.to_s.rjust(8)}"
    puts "Unique node types found:  #{unique_types.to_s.rjust(8)}"
    puts "Ruby Essence coverage:    #{essence_nodes.to_s.rjust(8)}/13 (#{essence_percentage}%)"
  end

  def generate_node_frequency_report
    puts "\n📈 NODE FREQUENCY (Top 15)"
    puts "-" * 30
    
    sorted_nodes = @node_counts.sort_by { |_, count| -count }.first(15)
    max_count = sorted_nodes.first[1]
    
    sorted_nodes.each_with_index do |(type, count), index|
      essence_mark = RUBY_ESSENCE_NODES.include?(type.to_s) ? "⭐" : "  "
      percentage = (count.to_f / @node_counts.values.sum * 100).round(1)
      bar_length = (count.to_f / max_count * 20).round
      bar = "█" * bar_length
      
      printf "%2d. %s %-12s %6d %5.1f%% %s\n", 
             index + 1, essence_mark, type, count, percentage, bar
    end
  end

  def generate_ruby_essence_analysis
    puts "\n⭐ RUBY ESSENCE ANALYSIS"
    puts "-" * 25
    
    found_essence = @node_counts.keys.map(&:to_s) & RUBY_ESSENCE_NODES
    missing_essence = RUBY_ESSENCE_NODES - @node_counts.keys.map(&:to_s)
    non_essence = @node_counts.keys.map(&:to_s) - RUBY_ESSENCE_NODES
    
    puts "✅ Found essence nodes (#{found_essence.length}/13):"
    found_essence.sort.each do |node|
      count = @node_counts[node.to_sym]
      printf "   %-12s %6d occurrences\n", node, count
    end
    
    if missing_essence.any?
      puts "\n❌ Missing essence nodes (#{missing_essence.length}/13):"
      missing_essence.sort.each { |node| puts "   #{node}" }
    end
    
    if non_essence.any?
      puts "\n🔧 Additional nodes used (beyond essence):"
      non_essence.sort.each do |node|
        count = @node_counts[node.to_sym]
        printf "   %-12s %6d occurrences\n", node, count
      end
    end
  end

  def generate_complexity_report
    puts "\n🧮 COMPLEXITY METRICS"
    puts "-" * 20
    puts "Methods defined:    #{@complexity_metrics[:methods].to_s.rjust(6)}"
    puts "Conditionals:       #{@complexity_metrics[:conditionals].to_s.rjust(6)}"
    puts "Classes/modules:    #{@complexity_metrics[:classes].to_s.rjust(6)}"
    
    if @method_definitions.any?
      avg_complexity = @method_definitions.map { |m| m[:complexity] }.sum.to_f / @method_definitions.length
      puts "Avg method complexity: #{avg_complexity.round(2).to_s.rjust(6)}"
    end
  end

  def generate_file_breakdown
    puts "\n📁 FILE BREAKDOWN"
    puts "-" * 17
    
    @file_nodes.each do |file, nodes|
      total = nodes.values.sum
      unique = nodes.keys.length
      essence_count = (nodes.keys.map(&:to_s) & RUBY_ESSENCE_NODES).length
      
      puts "#{File.basename(file).ljust(20)} #{total.to_s.rjust(5)} nodes, #{unique.to_s.rjust(2)} types, #{essence_count.to_s.rjust(2)}/13 essence"
    end
  end

  def generate_control_flow_report
    return if @control_flow_patterns.empty?
    
    puts "\n🔀 CONTROL FLOW PATTERNS"
    puts "-" * 24
    
    pattern_counts = Hash.new(0)
    @control_flow_patterns.each { |p| pattern_counts[p[:type]] += 1 }
    
    pattern_counts.each do |type, count|
      puts "#{type.to_s.ljust(20)} #{count.to_s.rjust(3)} occurrences"
    end
  end

  def generate_method_analysis
    return if @method_definitions.empty?
    
    puts "\n🔧 METHOD ANALYSIS"
    puts "-" * 17
    
    puts "Most complex methods:"
    top_complex = @method_definitions.sort_by { |m| -m[:complexity] }.first(5)
    top_complex.each do |method|
      puts "  #{method[:name]} (#{File.basename(method[:file])}) - complexity: #{method[:complexity]}"
    end
    
    arg_distribution = Hash.new(0)
    @method_definitions.each { |m| arg_distribution[m[:args]] += 1 }
    
    puts "\nArgument count distribution:"
    arg_distribution.sort.each do |args, count|
      puts "  #{args} args: #{count} methods"
    end
  end

  def save_detailed_data
    data = {
      summary: {
        total_nodes: @node_counts.values.sum,
        unique_types: @node_counts.keys.length,
        ruby_essence_coverage: (@node_counts.keys.map(&:to_s) & RUBY_ESSENCE_NODES).length
      },
      node_frequencies: @node_counts,
      file_breakdown: @file_nodes,
      ruby_essence_analysis: {
        found: @node_counts.keys.map(&:to_s) & RUBY_ESSENCE_NODES,
        missing: RUBY_ESSENCE_NODES - @node_counts.keys.map(&:to_s),
        additional: @node_counts.keys.map(&:to_s) - RUBY_ESSENCE_NODES
      },
      complexity_metrics: @complexity_metrics,
      method_definitions: @method_definitions,
      control_flow_patterns: @control_flow_patterns
    }
    
    output_file = "experiments/002-ruby-ast-analysis/analysis_results.json"
    File.write(output_file, JSON.pretty_generate(data))
    puts "\n💾 Detailed results saved to: #{output_file}"
  end
end

if __FILE__ == $0
  analyzer = ASTAnalyzer.new
  
  # Analyze all Ruby files in the project
  file_patterns = [
    "*.rb",
    "test/*.rb", 
    "examples/*.rb"
  ]
  
  analyzer.analyze_files(file_patterns)
end