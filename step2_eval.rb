#!/usr/bin/env ruby

# Step 2: Eval
# Adds evaluation of arithmetic expressions

require_relative 'reader'
require_relative 'printer'

def READ(str)
  read_str(str)
end

def EVAL(ast, env)
  if !list?(ast)
    return eval_ast(ast, env)
  end
  
  # Empty list evaluates to itself
  if null?(ast)
    return ast
  end
  
  # Evaluate the list
  evaluated = eval_ast(ast, env)
  f = car(evaluated)
  args = cdr(evaluated)
  
  # Apply the function
  apply_fn(f, args)
end

def PRINT(exp)
  pr_str(exp, true)
end

def rep(str)
  PRINT(EVAL(READ(str), repl_env))
end

# Helper functions
def list?(obj)
  null?(obj) || pair?(obj)
end

def eval_ast(ast, env)
  if symbol?(ast)
    # Look up symbol in environment
    name = ast.name
    if env.key?(name)
      env[name]
    else
      raise "Unknown symbol: #{name}"
    end
  elsif list?(ast)
    # Evaluate each element of the list
    if null?(ast)
      nil
    else
      cons(EVAL(car(ast), env), eval_ast(cdr(ast), env))
    end
  elsif vector?(ast)
    # Evaluate each element of the vector
    vec = Object.new
    vec.instance_variable_set(:@elements, eval_ast(ast.elements, env))
    eval <<-RUBY
      def vec.vector?; true; end
      def vec.elements; @elements; end
    RUBY
    vec
  elsif hash_map?(ast)
    # Evaluate keys and values of hash-map
    hm = Object.new
    hm.instance_variable_set(:@pairs, eval_hash_map_pairs(ast.pairs, env))
    eval <<-RUBY
      def hm.hash_map?; true; end
      def hm.pairs; @pairs; end
    RUBY
    hm
  else
    # Return unchanged for atoms
    ast
  end
end

def eval_hash_map_pairs(pairs, env)
  if null?(pairs)
    nil
  else
    pair = car(pairs)
    key = EVAL(car(pair), env)
    val = EVAL(cdr(pair), env)
    cons(cons(key, val), eval_hash_map_pairs(cdr(pairs), env))
  end
end

def apply_fn(f, args)
  # Extract arguments from list
  a = null?(args) ? nil : car(args)
  b = null?(args) || null?(cdr(args)) ? nil : car(cdr(args))
  
  case f
  when "+"
    raise "Wrong number of arguments for +" if a.nil? || b.nil?
    a + b
  when "-"
    raise "Wrong number of arguments for -" if a.nil? || b.nil?
    a - b
  when "*"
    raise "Wrong number of arguments for *" if a.nil? || b.nil?
    a * b
  when "/"
    raise "Wrong number of arguments for /" if a.nil? || b.nil?
    raise "Division by zero" if b == 0
    a / b
  else
    raise "Unknown function: #{f}"
  end
end

# Create the REPL environment
# Using a simple Ruby hash here since it's for the host environment,
# not part of the Lisp data structures
repl_env = {
  "+" => "+",
  "-" => "-",
  "*" => "*",
  "/" => "/"
}

# REPL
if __FILE__ == $0
  puts "Step 2 EVAL - Basic arithmetic evaluation"
  puts "Try: (+ 1 2) or (* 4 (+ 2 3))"
  
  loop do
    print "user> "
    input = gets
    break if input.nil?  # EOF
    
    input = input.chomp
    next if input.empty?
    
    begin
      puts rep(input)
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end