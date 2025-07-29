#!/usr/bin/env ruby

# Missing Functions Analysis for Self-Hosting
# This script analyzes what core functions are needed for MAL-in-MAL self-hosting

require_relative '../../mal_minimal.rb'

puts "=== MAL Self-Hosting Requirements Analysis ==="
puts "==============================================="
puts

# First, let's see what happens when we try to load MAL-in-MAL
puts "1. CURRENT ERROR ANALYSIS"
puts "-" * 30

puts "Attempting to load mal/stepA_mal.mal..."
begin
  result = load_file("mal/stepA_mal.mal")
  puts "✅ SUCCESS: MAL-in-MAL loaded successfully!"
rescue => e
  puts "❌ FAILED: #{e.message}"
  puts
  
  # Try to find the specific symbol that's missing
  if e.message.include?("Unknown symbol:")
    missing_symbol = e.message.match(/Unknown symbol: (.+)/)[1]
    puts "🎯 FIRST MISSING SYMBOL: #{missing_symbol}"
  end
end

puts
puts "2. CORE FUNCTIONS AUDIT"
puts "-" * 30

# Let's check what core functions we currently provide
current_functions = []

# Function to extract function names from our core environment
def extract_core_functions(env)
  functions = []
  
  # Walk through the environment's data (association list)
  current = env.instance_variable_get(:@data)
  while current && !current.nil?
    if current.respond_to?(:car) && current.car.respond_to?(:car)
      symbol_name = current.car.car
      if symbol_name.respond_to?(:name)
        functions << symbol_name.name  
      end
    end
    current = current.respond_to?(:cdr) ? current.cdr : nil
  end
  
  functions.sort
end

# Create a basic environment to see what we have
puts "Our current core functions:"
core_env = create_core_env
current_functions = extract_core_functions(core_env)

current_functions.each_with_index do |func, i|
  puts "  #{i+1}. #{func}"
end

puts
puts "Total current functions: #{current_functions.length}"

puts
puts "3. MAL-IN-MAL REQUIREMENTS ANALYSIS"  
puts "-" * 30

# Let's read the MAL-in-MAL file and look for function calls
mal_in_mal_content = nil
begin
  mal_in_mal_content = File.read("mal/stepA_mal.mal")
  puts "✅ Successfully read mal/stepA_mal.mal (#{mal_in_mal_content.length} bytes)"
rescue => e
  puts "❌ Could not read mal/stepA_mal.mal: #{e.message}"
  puts "   Make sure to run: make mal-deps"
  exit 1
end

# Extract potential function names from the MAL file
# Look for patterns like (function-name ...)
function_patterns = mal_in_mal_content.scan(/\(\s*([a-zA-Z][a-zA-Z0-9\-_?!*+\/=<>]*)/m)
required_functions = function_patterns.map { |match| match[0] }.uniq.sort

puts "Functions referenced in MAL-in-MAL implementation:"
required_functions.each_with_index do |func, i|
  status = current_functions.include?(func) ? "✅" : "❌"
  puts "  #{i+1}. #{status} #{func}"
end

puts
puts "4. MISSING FUNCTIONS ANALYSIS"
puts "-" * 30

missing_functions = required_functions - current_functions
present_functions = required_functions & current_functions

puts "Missing functions (#{missing_functions.length}):"
missing_functions.each_with_index do |func, i|
  puts "  #{i+1}. ❌ #{func}"
end

puts
puts "Present functions (#{present_functions.length}):"
present_functions.each_with_index do |func, i|
  puts "  #{i+1}. ✅ #{func}"
end

puts
puts "5. PRIORITY ANALYSIS"
puts "-" * 30

# Categorize missing functions by likely difficulty
environment_functions = missing_functions.select { |f| f.include?("env") || f.include?("atom") }
meta_functions = missing_functions.select { |f| f.include?("meta") || f.include?("macro") || f == "eval" }
utility_functions = missing_functions.select { |f| f.include?("str") || f.include?("read") || f.include?("pr") }
collection_functions = missing_functions.select { |f| f.include?("vec") || f.include?("map") || f.include?("seq") }
other_functions = missing_functions - environment_functions - meta_functions - utility_functions - collection_functions

puts "Environment/Atom functions (HIGH PRIORITY):"
environment_functions.each { |f| puts "  - #{f}" }

puts
puts "Meta/Eval functions (MEDIUM PRIORITY):"  
meta_functions.each { |f| puts "  - #{f}" }

puts
puts "Utility functions (LOW PRIORITY):"
utility_functions.each { |f| puts "  - #{f}" }

puts
puts "Collection functions (MEDIUM PRIORITY):"
collection_functions.each { |f| puts "  - #{f}" }

puts  
puts "Other functions (VARIES):"
other_functions.each { |f| puts "  - #{f}" }

puts
puts "6. IMPLEMENTATION ROADMAP"
puts "-" * 30

puts "PHASE 1: Environment functions (required for basic operation)"
environment_functions.each { |f| puts "  [ ] #{f}" }

puts
puts "PHASE 2: Essential utilities (needed for MAL parsing/printing)"
essential_utils = utility_functions.select { |f| ["read-string", "str", "pr-str"].include?(f) }
essential_utils.each { |f| puts "  [ ] #{f}" }

puts
puts "PHASE 3: Collection support (for MAL data structures)"
collection_functions.each { |f| puts "  [ ] #{f}" }

puts
puts "PHASE 4: Meta programming (for full MAL compatibility)"
meta_functions.each { |f| puts "  [ ] #{f}" }

puts
puts "PHASE 5: Remaining utilities"
(utility_functions - essential_utils).each { |f| puts "  [ ] #{f}" }

puts
puts "7. IMMEDIATE ACTION ITEMS"
puts "-" * 30

puts "To get basic MAL-in-MAL working tomorrow:"
puts
puts "1. Start with the FIRST missing symbol: #{missing_functions.first}"
puts
puts "2. Implement environment functions in this order:"
environment_functions.first(5).each_with_index do |f, i|
  puts "   #{i+1}. #{f}"
end

puts
puts "3. Test after each implementation:"
puts "   ruby stepA_mal.rb mal/stepA_mal.mal"

puts
puts "4. Once loading succeeds, test basic functionality:"
puts "   echo '(+ 1 2)' | ruby stepA_mal.rb mal/stepA_mal.mal"

puts
puts "=== Analysis Complete ==="
puts "See implementation-roadmap.md for detailed next steps"