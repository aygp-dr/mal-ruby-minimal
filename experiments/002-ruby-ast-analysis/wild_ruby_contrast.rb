#!/usr/bin/env ruby

# Quick contrast analysis of wild Ruby files vs our MAL implementation
# Sample analysis of real-world Ruby to highlight differences

require 'pathname'

class WildRubyContrast
  def initialize
    @file_list = File.read("research/mnt-usb-ruby-files.txt").lines.map(&:strip)
    @sample_size = 100
  end

  def analyze_sample
    puts "🌍 Wild Ruby Corpus Analysis (Sample: #{@sample_size} files)"
    puts "=" * 60

    # Take a random sample
    sample_files = @file_list.sample(@sample_size)
    
    all_nodes = Hash.new(0)
    total_files_analyzed = 0
    
    sample_files.each_with_index do |file_path, idx|
      next unless File.exist?(file_path) && File.readable?(file_path)
      
      begin
        # Generate parse tree for this file
        parsetree_output = `ruby --dump=parsetree "#{file_path}" 2>/dev/null`
        next if parsetree_output.empty?
        
        # Extract nodes
        nodes = parsetree_output.scan(/@\s+([A-Z_]+)\s/).flatten
        nodes.each { |node| all_nodes[node] += 1 }
        
        total_files_analyzed += 1
        
        # Progress indicator
        print "\rAnalyzing: #{idx + 1}/#{@sample_size} (#{total_files_analyzed} successful)" if idx % 10 == 0
        
      rescue => e
        # Skip files that can't be parsed
        next
      end
    end
    
    puts "\n"
    puts "Successfully analyzed: #{total_files_analyzed} files"
    puts "Total nodes found: #{all_nodes.values.sum}"
    puts "Unique node types: #{all_nodes.keys.size}"
    
    # Top nodes in wild Ruby
    puts "\n🔥 Top 20 Node Types in Wild Ruby:"
    puts "-" * 40
    
    top_wild = all_nodes.sort_by { |k, v| -v }.first(20)
    top_wild.each_with_index do |(node, count), idx|
      percentage = (count.to_f / all_nodes.values.sum * 100).round(1)
      puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
    end
    
    # Compare with our MAL stepA (most complete)
    puts "\n" + "=" * 60
    puts "🔬 COMPARISON: Wild Ruby vs MAL stepA"
    puts "=" * 60
    
    # Our stepA top nodes (from previous analysis)
    our_top_nodes = [
      "NODE_LIST", "NODE_FCALL", "NODE_LVAR", "NODE_STR", "NODE_CALL", 
      "NODE_DVAR", "NODE_LASGN", "NODE_IF", "NODE_BLOCK", "NODE_OPCALL"
    ]
    
    wild_top_nodes = top_wild.first(10).map(&:first)
    
    puts "\nNode prevalence comparison:"
    puts "Rank | Wild Ruby       | MAL stepA      | Match?"
    puts "-" * 50
    
    10.times do |i|
      wild_node = wild_top_nodes[i] || "N/A"
      our_node = our_top_nodes[i] || "N/A"
      match = wild_node == our_node ? "✓" : "✗"
      
      printf "%4d | %-15s | %-14s | %s\n", i + 1, wild_node, our_node, match
    end
    
    # Unique to wild Ruby
    our_nodes = Set.new(%w[
      NODE_ARGS NODE_BLOCK NODE_BREAK NODE_CALL NODE_DASGN NODE_DEFN NODE_DVAR
      NODE_FCALL NODE_GVAR NODE_IF NODE_ITER NODE_LIST NODE_LVAR NODE_NEXT
      NODE_NIL NODE_OPCALL NODE_SCOPE NODE_STR NODE_VCALL NODE_DSTR NODE_ERRINFO
      NODE_EVSTR NODE_RESBODY NODE_RESCUE NODE_TRUE NODE_CASE NODE_CONST NODE_HASH
      NODE_LASGN NODE_LIT NODE_OR NODE_RETURN NODE_WHEN NODE_AND NODE_FALSE
      NODE_SPLAT NODE_WHILE NODE_ZLIST NODE_ATTRASGN NODE_UNLESS NODE_OPT_ARG
      NODE_CLASS NODE_IASGN NODE_SUPER
    ])
    
    wild_only = Set.new(all_nodes.keys) - our_nodes
    
    puts "\n🆕 Node types in Wild Ruby but NOT in our MAL implementation:"
    puts "(Top 10 by frequency)"
    puts "-" * 50
    
    wild_only_sorted = wild_only.map { |node| [node, all_nodes[node]] }
                                .sort_by { |k, v| -v }
                                .first(10)
    
    wild_only_sorted.each_with_index do |(node, count), idx|
      percentage = (count.to_f / all_nodes.values.sum * 100).round(2)
      puts "  #{idx + 1}. #{node}: #{count} (#{percentage}%)"
    end
    
    puts "\n💡 Analysis Summary:"
    puts "- Wild Ruby uses #{all_nodes.keys.size} unique node types vs our 43"
    puts "- #{(wild_only.size.to_f / all_nodes.keys.size * 100).round(1)}% of wild Ruby nodes are missing from our implementation"
    puts "- Our minimal approach covers #{((our_nodes & Set.new(all_nodes.keys)).size.to_f / all_nodes.keys.size * 100).round(1)}% of wild Ruby node diversity"
  end
end

# Run the analysis
analyzer = WildRubyContrast.new
analyzer.analyze_sample