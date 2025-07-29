#!/usr/bin/env ruby

# Step 3: Environments
# Adds def! and let* special forms with proper environment handling

require_relative 'reader'
require_relative 'printer'
require_relative 'env'

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
  
  # Check for special forms
  if symbol?(car(ast))
    case car(ast).name
    when "def!"
      # (def! symbol value)
      if null?(cdr(ast)) || null?(cdr(cdr(ast)))
        raise "def! requires 2 arguments"
      end
      
      sym = car(cdr(ast))
      if !symbol?(sym)
        raise "def! first argument must be a symbol"
      end
      
      val = EVAL(car(cdr(cdr(ast))), env)
      env.set(sym.name, val)
      val
      
    when "let*"
      # (let* (bindings...) body)
      if null?(cdr(ast)) || null?(cdr(cdr(ast)))
        raise "let* requires bindings and body"
      end
      
      bindings = car(cdr(ast))
      body = car(cdr(cdr(ast)))
      
      # Create new environment
      let_env = Env.new(env)
      
      # Process bindings
      process_bindings(bindings, let_env)
      
      # Evaluate body in new environment
      EVAL(body, let_env)
      
    else
      # Not a special form, evaluate as function call
      evaluated = eval_ast(ast, env)
      f = car(evaluated)
      args = cdr(evaluated)
      apply_fn(f, args)
    end
  else
    # List doesn't start with symbol, evaluate all
    evaluated = eval_ast(ast, env)
    f = car(evaluated)
    args = cdr(evaluated)
    apply_fn(f, args)
  end
end

def PRINT(exp)
  pr_str(exp, true)
end

def rep(str, env)
  PRINT(EVAL(READ(str), env))
end

# Helper functions
def list?(obj)
  null?(obj) || pair?(obj)
end

def eval_ast(ast, env)
  if symbol?(ast)
    # Look up symbol in environment
    env.get(ast.name)
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

def process_bindings(bindings, env)
  if !list?(bindings) && !vector?(bindings)
    raise "let* bindings must be a list or vector"
  end
  
  # Get the actual list
  bind_list = vector?(bindings) ? bindings.elements : bindings
  
  # Process pairs of symbol/value
  process_binding_pairs(bind_list, env)
end

def process_binding_pairs(lst, env)
  return if null?(lst)
  
  if null?(cdr(lst))
    raise "let* bindings must have even number of elements"
  end
  
  sym = car(lst)
  if !symbol?(sym)
    raise "let* binding name must be a symbol"
  end
  
  val_expr = car(cdr(lst))
  val = EVAL(val_expr, env)
  env.set(sym.name, val)
  
  # Process remaining bindings
  process_binding_pairs(cdr(cdr(lst)), env)
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
def create_repl_env
  env = Env.new
  env.set("+", "+")
  env.set("-", "-")
  env.set("*", "*")
  env.set("/", "/")
  env
end

# REPL
if __FILE__ == $0
  puts "Step 3 ENV - Variables and environments"
  puts "Try: (def! x 5) then (* x 2)"
  puts "Or: (let* (a 6 b 7) (+ a b))"
  
  repl_env = create_repl_env
  
  loop do
    print "user> "
    input = gets
    break if input.nil?  # EOF
    
    input = input.chomp
    next if input.empty?
    
    begin
      puts rep(input, repl_env)
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end