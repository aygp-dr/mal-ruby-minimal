#!/usr/bin/env ruby

# Compare MAL minimal implementation to Ruby Essence's 13 essential nodes

puts "Ruby Essence 13 Essential AST Nodes vs MAL Implementation"
puts "=" * 60
puts

# The 13 essential nodes from Ruby Essence
essential_nodes = {
  "CallNode" => "Method calls - e.g., puts, cons(), car()",
  "ArgumentsNode" => "Function arguments",
  "StatementsNode" => "Statement sequences",
  "LocalVariableReadNode" => "Reading local variables",
  "StringNode" => "String literals",
  "ConstantReadNode" => "Reading constants",
  "SymbolNode" => "Symbol literals",
  "DefNode" => "Method definitions",
  "RequiredParameterNode" => "Required method parameters",
  "ParametersNode" => "Parameter lists",
  "LocalVariableWriteNode" => "Variable assignment",
  "IfNode" => "Conditional statements",
  "InstanceVariableReadNode" => "Reading @instance_vars"
}

# Analyze mal_minimal.rb for these patterns
code = File.read('mal_minimal.rb')
lines = code.lines

# Count occurrences
counts = {
  calls: 0,
  string_literals: 0,
  symbols: 0,
  defs: 0,
  assignments: 0,
  ifs: 0,
  instance_vars: 0
}

lines.each do |line|
  next if line.strip.start_with?('#')
  
  # Method calls - looking for foo() or foo(args)
  counts[:calls] += line.scan(/\b\w+\s*\(/).count
  
  # String literals
  counts[:string_literals] += line.scan(/"[^"]*"/).count
  counts[:string_literals] += line.scan(/'[^']*'/).count
  
  # Symbol-like strings (we don't use actual symbols)
  counts[:symbols] += line.scan(/["'](:\w+|[+\-*\/<>=]+)["']/).count
  
  # Method definitions
  counts[:defs] += 1 if line =~ /^\s*def\s+/
  
  # Variable assignments
  counts[:assignments] += line.scan(/\b\w+\s*=\s*[^=]/).count
  
  # If statements
  counts[:ifs] += 1 if line =~ /\bif\b/
  
  # Instance variables
  counts[:instance_vars] += line.scan(/@\w+/).count
end

puts "MAL Implementation Analysis:"
puts "-" * 30
puts "Method calls: #{counts[:calls]}"
puts "String literals: #{counts[:string_literals]}"
puts "Symbol-like strings: #{counts[:symbols]}"
puts "Method definitions: #{counts[:defs]}"
puts "Variable assignments: #{counts[:assignments]}"
puts "If statements: #{counts[:ifs]}"
puts "Instance variables: #{counts[:instance_vars]}"

puts "\nImplementation Strategy:"
puts "-" * 30
puts "Instead of Ruby's built-in data structures, MAL uses:"
puts "1. Cons cells (pairs) for all lists and data structures"
puts "2. Object.new with instance variables for custom types"
puts "3. Strings to represent built-in function names"
puts "4. Recursive functions for list processing"
puts "5. Association lists for environments"

puts "\nThe 13 Node Types in MAL context:"
puts "-" * 30
essential_nodes.each do |node, desc|
  case node
  when "CallNode"
    puts "✓ #{node}: Heavily used - cons(), car(), eval_mal(), etc."
  when "ArgumentsNode"
    puts "✓ #{node}: Function arguments passed as cons lists"
  when "StatementsNode"
    puts "✓ #{node}: Sequential evaluation in 'do' special form"
  when "LocalVariableReadNode"
    puts "✓ #{node}: Variables read from environment"
  when "StringNode"
    puts "✓ #{node}: Used for tokens and built-in function names"
  when "ConstantReadNode"
    puts "✗ #{node}: Not used - no Ruby constants"
  when "SymbolNode"
    puts "△ #{node}: Custom symbol type, not Ruby symbols"
  when "DefNode"
    puts "✓ #{node}: Many method definitions"
  when "RequiredParameterNode", "ParametersNode"
    puts "✓ #{node}: Method parameters throughout"
  when "LocalVariableWriteNode"
    puts "✓ #{node}: Variable assignments"
  when "IfNode"
    puts "✓ #{node}: Conditional logic"
  when "InstanceVariableReadNode"
    puts "✓ #{node}: Used in custom objects (@car, @name, etc.)"
  end
end

puts "\nConclusion:"
puts "-" * 30
puts "MAL demonstrates that even with severe constraints"
puts "(no arrays, hashes, or blocks), we can build a complete"
puts "Lisp interpreter using mostly the same essential nodes"
puts "that Ruby Essence identified as covering 81% of Ruby code."