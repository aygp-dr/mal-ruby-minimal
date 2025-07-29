#!/usr/bin/env ruby

# Deep dive analysis of AST nodes used at each MAL implementation step
# Extracts specific node types and frequencies from parse tree files

require 'pathname'

class MalAstDeepDive
  def initialize
    @research_dir = Pathname.new(__dir__) / "research"
    @mal_files = Dir.glob(@research_dir / "mal_step*.parsetree").sort
    @results = {}
  end

  def analyze_all_steps
    puts "🔍 MAL AST Deep Dive Analysis"
    puts "=" * 50
    
    @mal_files.each do |file|
      step_name = extract_step_name(file)
      next if step_name.nil?
      
      puts "\n📊 Analyzing #{step_name}..."
      @results[step_name] = analyze_parse_tree(file)
    end
    
    generate_report
  end

  private

  def extract_step_name(file)
    basename = File.basename(file, '.parsetree')
    if basename.match(/mal_step([0-9A]+)_/)
      "step#{$1}"
    elsif basename == "mal_stepA_mal"
      "stepA"
    else
      nil
    end
  end

  def analyze_parse_tree(file)
    content = File.read(file)
    
    # Extract all NODE_ patterns
    nodes = content.scan(/@\s+([A-Z_]+)\s/).flatten
    node_counts = Hash.new(0)
    nodes.each { |node| node_counts[node] += 1 }
    
    # Calculate metrics
    total_nodes = nodes.size
    unique_nodes = node_counts.keys.size
    file_size = File.size(file)
    
    {
      node_counts: node_counts,
      total_nodes: total_nodes,
      unique_nodes: unique_nodes,
      file_size: file_size,
      top_nodes: node_counts.sort_by { |k, v| -v }.first(10)
    }
  end

  def generate_report
    puts "\n" + "=" * 80
    puts "📈 MAL IMPLEMENTATION AST PROGRESSION ANALYSIS"
    puts "=" * 80

    # Step-by-step breakdown
    @results.each do |step, data|
      puts "\n🔥 #{step.upcase}"
      puts "-" * 40
      puts "File size: #{format_bytes(data[:file_size])}"
      puts "Total nodes: #{data[:total_nodes]}"
      puts "Unique node types: #{data[:unique_nodes]}"
      puts "Node density: #{(data[:total_nodes].to_f / data[:file_size] * 1000).round(2)} nodes/KB"
      
      puts "\nTop node types:"
      data[:top_nodes].each_with_index do |(node, count), idx|
        percentage = (count.to_f / data[:total_nodes] * 100).round(1)
        puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
      end
    end

    # Progression analysis
    puts "\n" + "=" * 80
    puts "📊 COMPLEXITY PROGRESSION"
    puts "=" * 80
    
    step_order = ["step0", "step1", "step2", "step3", "step4", "step5", "step6", "step7", "step8", "step9", "stepA"]
    
    puts "\nGrowth metrics:"
    puts "Step      | File Size | Total Nodes | Unique Types | Growth Factor"
    puts "-" * 65
    
    prev_size = nil
    step_order.each do |step|
      next unless @results[step]
      
      data = @results[step]
      growth = prev_size ? (data[:file_size].to_f / prev_size).round(2) : 1.0
      
      printf "%-9s | %9s | %11d | %12d | %s\n",
        step,
        format_bytes(data[:file_size]),
        data[:total_nodes],
        data[:unique_nodes],
        growth == 1.0 ? "baseline" : "#{growth}x"
        
      prev_size = data[:file_size]
    end

    # Node evolution analysis
    puts "\n" + "=" * 80
    puts "🧬 NODE TYPE EVOLUTION"  
    puts "=" * 80
    
    all_nodes = Set.new
    @results.each { |step, data| all_nodes.merge(data[:node_counts].keys) }
    
    # Show when each node type first appears
    node_introduction = {}
    step_order.each do |step|
      next unless @results[step]
      
      @results[step][:node_counts].keys.each do |node|
        node_introduction[node] ||= step
      end
    end
    
    puts "\nNode type introduction timeline:"
    introduction_by_step = node_introduction.group_by { |node, step| step }
    
    step_order.each do |step|
      nodes_in_step = introduction_by_step[step] || []
      next if nodes_in_step.empty?
      
      puts "\n#{step}:"
      nodes_in_step.map(&:first).sort.each do |node|
        puts "  + #{node}"
      end
    end

    # Critical nodes analysis
    puts "\n" + "=" * 80
    puts "⚡ CRITICAL NODES ANALYSIS"
    puts "=" * 80
    
    # Nodes that appear in every step
    universal_nodes = @results.values.map { |data| data[:node_counts].keys }.reduce(:&)
    
    puts "\nUniversal nodes (appear in all steps):"
    universal_nodes.sort.each { |node| puts "  • #{node}" }
    
    # Nodes unique to specific steps
    puts "\nStep-specific unique nodes:"
    step_order.each do |step|
      next unless @results[step]
      
      step_nodes = Set.new(@results[step][:node_counts].keys)
      other_steps_nodes = Set.new
      
      step_order.each do |other_step|
        next if other_step == step || !@results[other_step]
        other_steps_nodes.merge(@results[other_step][:node_counts].keys)
      end
      
      unique_to_step = step_nodes - other_steps_nodes
      
      if unique_to_step.any?
        puts "\n#{step}:"
        unique_to_step.sort.each { |node| puts "  • #{node}" }
      end
    end
  end

  def format_bytes(bytes)
    if bytes < 1024
      "#{bytes}B"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round(1)}KB"
    else
      "#{(bytes / (1024.0 * 1024)).round(1)}MB"
    end
  end
end

# Run the analysis
analyzer = MalAstDeepDive.new
analyzer.analyze_all_steps