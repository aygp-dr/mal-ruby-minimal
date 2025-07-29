#!/usr/bin/env ruby

# Large-scale analysis of wild Ruby codebases to determine true AST node ceiling
# Uses both Ruby --dump=parsetree and Prism for comparison
# Samples 1000 random files from 50k+ corpus to find maximum node diversity

require 'pathname'
require 'set'

begin
  require 'prism'
  PRISM_AVAILABLE = true
rescue LoadError
  puts "⚠️  Prism not available, will use Ruby --dump=parsetree only"
  PRISM_AVAILABLE = false
end

class LargeScaleWildAnalysis
  def initialize
    @research_dir = Pathname.new(__dir__) / "research"
    @file_list_path = @research_dir / "mnt-usb-ruby-files.txt"
    @sample_size = 500  # Reduced for faster completion
    @results = {
      ruby_parser: { nodes: Hash.new(0), files_analyzed: 0 },
      prism_parser: { nodes: Hash.new(0), files_analyzed: 0 }
    }
  end

  def run_analysis
    puts "🔬 Large-Scale Wild Ruby Analysis"
    puts "=" * 60
    puts "Target: #{@sample_size} random files from #{count_total_files} Ruby files"
    puts "Parsers: Ruby --dump=parsetree" + (PRISM_AVAILABLE ? " + Prism" : "")
    puts "=" * 60

    # First baseline our MAL implementation with both parsers
    baseline_mal_implementation
    
    # Then analyze random sample from wild corpus
    analyze_wild_sample
    
    # Compare and report findings
    generate_comprehensive_report
  end

  private

  def count_total_files
    @total_files ||= File.read(@file_list_path).lines.size
  end

  def baseline_mal_implementation
    puts "\n📊 Baseline: MAL Implementation Analysis"
    puts "-" * 40

    mal_files = [
      "../../step0_repl.rb", "../../step1_read_print.rb", "../../step2_eval.rb",
      "../../step3_env.rb", "../../step4_if_fn_do.rb", "../../step5_tco.rb",
      "../../step6_file.rb", "../../step7_quote.rb", "../../step8_macros.rb", 
      "../../step9_try.rb", "../../stepA_mal.rb",
      "../../reader.rb", "../../printer.rb", "../../env.rb", "../../mal_minimal.rb"
    ]

    @mal_baseline = { ruby_parser: Set.new, prism_parser: Set.new }

    mal_files.each do |file|
      next unless File.exist?(file)
      
      # Ruby parser analysis
      ruby_nodes = extract_ruby_parser_nodes(file)
      @mal_baseline[:ruby_parser].merge(ruby_nodes) if ruby_nodes

      # Prism analysis  
      if PRISM_AVAILABLE
        prism_nodes = extract_prism_nodes(file)
        @mal_baseline[:prism_parser].merge(prism_nodes) if prism_nodes
      end
    end

    puts "MAL Baseline (Ruby parser): #{@mal_baseline[:ruby_parser].size} unique node types"
    puts "MAL Baseline (Prism): #{@mal_baseline[:prism_parser].size} unique node types" if PRISM_AVAILABLE
  end

  def analyze_wild_sample
    puts "\n🌍 Wild Ruby Corpus Analysis"
    puts "-" * 40

    # Generate random sample using shuf
    sample_files = generate_random_sample
    
    puts "Analyzing #{sample_files.size} random files..."
    
    sample_files.each_with_index do |file_path, idx|
      next unless File.exist?(file_path) && File.readable?(file_path)
      next if File.size(file_path) > 1_000_000  # Skip huge files

      begin
        # Ruby parser analysis
        ruby_nodes = extract_ruby_parser_nodes(file_path)
        if ruby_nodes
          ruby_nodes.each { |node| @results[:ruby_parser][:nodes][node] += 1 }
          @results[:ruby_parser][:files_analyzed] += 1
        end

        # Prism analysis
        if PRISM_AVAILABLE
          prism_nodes = extract_prism_nodes(file_path)
          if prism_nodes
            prism_nodes.each { |node| @results[:prism_parser][:nodes][node] += 1 }
            @results[:prism_parser][:files_analyzed] += 1
          end
        end

        # Progress indicator
        if idx % 50 == 0
          puts "Processed: #{idx}/#{sample_files.size} (#{@results[:ruby_parser][:files_analyzed]} successful)"
        end

      rescue => e
        # Skip problematic files
        next
      end
    end

    puts "\nAnalysis complete!"
    puts "Ruby parser: #{@results[:ruby_parser][:files_analyzed]} files analyzed"
    puts "Prism: #{@results[:prism_parser][:files_analyzed]} files analyzed" if PRISM_AVAILABLE
  end

  def generate_random_sample
    puts "Generating random sample of #{@sample_size} files..."
    
    # FreeBSD doesn't have shuf, use Ruby's sample method instead
    all_files = File.read(@file_list_path).lines.map(&:strip).reject(&:empty?)
    sample_files = all_files.sample(@sample_size)
    
    puts "Generated sample of #{sample_files.size} files from #{all_files.size} total"
    
    sample_files
  end

  def extract_ruby_parser_nodes(file_path)
    parsetree_output = `ruby --dump=parsetree "#{file_path}" 2>/dev/null`
    return nil if parsetree_output.empty?
    
    # Extract NODE_ patterns
    nodes = parsetree_output.scan(/@\s+([A-Z_]+)\s/).flatten
    Set.new(nodes)
  rescue
    nil
  end

  def extract_prism_nodes(file_path)
    return nil unless PRISM_AVAILABLE
    
    source = File.read(file_path)
    result = Prism.parse(source)
    
    nodes = Set.new
    collect_prism_nodes(result.value, nodes)
    nodes
  rescue
    nil
  end

  def collect_prism_nodes(node, nodes)
    return unless node
    
    # Get the node class name (e.g., Prism::CallNode -> CallNode)
    node_type = node.class.name.split('::').last
    nodes.add(node_type)
    
    # Recursively collect from child nodes
    if node.respond_to?(:child_nodes)
      node.child_nodes.each { |child| collect_prism_nodes(child, nodes) }
    end
  end

  def generate_comprehensive_report
    puts "\n" + "=" * 80
    puts "📈 COMPREHENSIVE WILD RUBY ANALYSIS RESULTS"
    puts "=" * 80

    # Ruby parser results
    ruby_nodes = @results[:ruby_parser][:nodes]
    puts "\n🔥 Ruby --dump=parsetree Results:"
    puts "-" * 40
    puts "Files analyzed: #{@results[:ruby_parser][:files_analyzed]}"
    puts "Total nodes found: #{ruby_nodes.values.sum}"
    puts "Unique node types: #{ruby_nodes.keys.size}"
    
    puts "\nTop 20 most frequent nodes:"
    ruby_nodes.sort_by { |k, v| -v }.first(20).each_with_index do |(node, count), idx|
      percentage = (count.to_f / ruby_nodes.values.sum * 100).round(2)
      puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
    end

    # Prism results
    if PRISM_AVAILABLE
      prism_nodes = @results[:prism_parser][:nodes]
      puts "\n🔥 Prism Parser Results:"
      puts "-" * 40
      puts "Files analyzed: #{@results[:prism_parser][:files_analyzed]}"
      puts "Total nodes found: #{prism_nodes.values.sum}"
      puts "Unique node types: #{prism_nodes.keys.size}"
      
      puts "\nTop 20 most frequent nodes:"
      prism_nodes.sort_by { |k, v| -v }.first(20).each_with_index do |(node, count), idx|
        percentage = (count.to_f / prism_nodes.values.sum * 100).round(2)
        puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
      end
    end

    # Comparison analysis
    puts "\n" + "=" * 80
    puts "🔬 PARSER COMPARISON & MAL BASELINE"
    puts "=" * 80

    ruby_wild_nodes = Set.new(ruby_nodes.keys)
    
    puts "\n📊 Ruby Parser Analysis:"
    puts "Wild corpus node types: #{ruby_wild_nodes.size}"
    puts "MAL baseline coverage: #{(@mal_baseline[:ruby_parser] & ruby_wild_nodes).size}/#{ruby_wild_nodes.size} (#{((@mal_baseline[:ruby_parser] & ruby_wild_nodes).size.to_f / ruby_wild_nodes.size * 100).round(1)}%)"
    
    # Nodes in wild but not in MAL
    wild_only = ruby_wild_nodes - @mal_baseline[:ruby_parser]
    puts "\nNodes in wild corpus but NOT in MAL implementation:"
    puts "(Showing frequency from wild analysis)"
    wild_only.map { |node| [node, ruby_nodes[node]] }
             .sort_by { |_, count| -count }
             .first(15)
             .each_with_index do |(node, count), idx|
      percentage = (count.to_f / ruby_nodes.values.sum * 100).round(2)
      puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
    end

    if PRISM_AVAILABLE
      prism_wild_nodes = Set.new(prism_nodes.keys)
      
      puts "\n📊 Prism Parser Analysis:"  
      puts "Wild corpus node types: #{prism_wild_nodes.size}"
      puts "MAL baseline coverage: #{(@mal_baseline[:prism_parser] & prism_wild_nodes).size}/#{prism_wild_nodes.size} (#{((@mal_baseline[:prism_parser] & prism_wild_nodes).size.to_f / prism_wild_nodes.size * 100).round(1)}%)"
    end

    # Final analysis
    puts "\n" + "=" * 80
    puts "🎯 FINAL ANALYSIS: Ruby AST Node Ceiling"
    puts "=" * 80
    
    max_nodes = ruby_wild_nodes.size
    max_nodes = [@results[:prism_parser][:nodes].keys.size, max_nodes].max if PRISM_AVAILABLE
    
    puts "\n💡 Key Findings:"
    puts "- Ruby --dump=parsetree reveals #{ruby_wild_nodes.size} unique node types in wild"
    puts "- Prism parser reveals #{@results[:prism_parser][:nodes].keys.size} unique node types in wild" if PRISM_AVAILABLE
    puts "- Our MAL implementation covers #{((@mal_baseline[:ruby_parser] & ruby_wild_nodes).size.to_f / ruby_wild_nodes.size * 100).round(1)}% of wild Ruby diversity"
    puts "- Sample size: #{@sample_size} files from #{count_total_files} total (#{(@sample_size.to_f / count_total_files * 100).round(2)}% coverage)"
    
    if @sample_size >= 1000
      puts "- ✅ Large sample size provides high confidence in node ceiling estimate"
    else
      puts "- ⚠️  Consider larger sample size for more definitive ceiling"
    end

    puts "\n🔥 CONCLUSION: Ruby AST node ceiling appears to be ~#{max_nodes} types for real-world code"
  end
end

# Run the analysis
analyzer = LargeScaleWildAnalysis.new
analyzer.run_analysis