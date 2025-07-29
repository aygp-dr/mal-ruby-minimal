#!/usr/bin/env ruby

# Step 5: Tail Call Optimization
# Adds TCO to prevent stack overflow in recursive functions

require_relative 'reader'
require_relative 'printer'
require_relative 'env'

def READ(str)
  read_str(str)
end

def EVAL(ast, env)
  # TCO loop - instead of recursion, we loop with updated ast/env
  loop do
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
        return val
        
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
        
        # TCO: Continue loop with new ast and env
        ast = body
        env = let_env
        # Loop continues with new ast/env
        
      when "if"
        # (if condition then-expr else-expr)
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "if requires at least 2 arguments"
        end
        
        condition = EVAL(car(cdr(ast)), env)
        
        # In MAL, only nil and false are falsy
        if condition.nil? || condition == false
          # Evaluate else branch if present
          if !null?(cdr(cdr(cdr(ast))))
            ast = car(cdr(cdr(cdr(ast))))
            # Loop continues with else expression
          else
            return nil
          end
        else
          # Evaluate then branch
          ast = car(cdr(cdr(ast)))
          # Loop continues with then expression
        end
        
      when "fn*"
        # (fn* (params...) body)
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "fn* requires parameters and body"
        end
        
        params = car(cdr(ast))
        body = car(cdr(cdr(ast)))
        
        # Create a MAL function (not Ruby lambda) for TCO
        return make_mal_fn(params, body, env)
        
      when "do"
        # (do expr1 expr2 ... exprN)
        # Evaluate all but last, TCO on last
        exprs = cdr(ast)
        
        if null?(exprs)
          return nil
        end
        
        # Evaluate all but last
        while !null?(cdr(exprs))
          EVAL(car(exprs), env)
          exprs = cdr(exprs)
        end
        
        # TCO on last expression
        ast = car(exprs)
        # Loop continues with last expression
        
      else
        # Not a special form, evaluate as function call
        evaluated = eval_ast(ast, env)
        f = car(evaluated)
        args = cdr(evaluated)
        
        if mal_fn?(f)
          # User function - TCO by updating ast/env
          ast = f.body
          env = Env.new(f.env)
          bind_params(f.params, args, env)
          # Loop continues with function body
        else
          # Built-in function - no TCO needed
          return apply_builtin(f, args)
        end
      end
    else
      # List doesn't start with symbol, evaluate all
      evaluated = eval_ast(ast, env)
      f = car(evaluated)
      args = cdr(evaluated)
      
      if mal_fn?(f)
        # User function - TCO
        ast = f.body
        env = Env.new(f.env)
        bind_params(f.params, args, env)
        # Loop continues
      else
        # Built-in function
        return apply_builtin(f, args)
      end
    end
  end
end

def PRINT(exp)
  pr_str(exp, true)
end

def rep(str, env)
  PRINT(EVAL(READ(str), env))
end

# MAL function type for TCO
def make_mal_fn(params, body, env)
  fn = Object.new
  fn.instance_variable_set(:@params, params)
  fn.instance_variable_set(:@body, body)
  fn.instance_variable_set(:@env, env)
  fn.instance_variable_set(:@is_mal_fn, true)
  
  eval <<-RUBY
    def fn.params; @params; end
    def fn.body; @body; end
    def fn.env; @env; end
    def fn.mal_fn?; true; end
    def fn.to_s; "#<function>"; end
  RUBY
  
  fn
end

def mal_fn?(obj)
  obj.respond_to?(:mal_fn?) && obj.mal_fn?
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

def bind_params(params, args, env)
  # Base case
  if null?(params)
    if !null?(args)
      raise "Too many arguments"
    end
    return
  end
  
  if null?(args)
    raise "Not enough arguments"
  end
  
  # Bind parameter
  param = car(params)
  if !symbol?(param)
    raise "Parameter must be a symbol"
  end
  
  env.set(param.name, car(args))
  
  # Recurse
  bind_params(cdr(params), cdr(args), env)
end

def apply_builtin(f, args)
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
  when "="
    a == b
  when "<"
    raise "Wrong number of arguments for <" if a.nil? || b.nil?
    a < b
  when ">"
    raise "Wrong number of arguments for >" if a.nil? || b.nil?
    a > b
  when "<="
    raise "Wrong number of arguments for <=" if a.nil? || b.nil?
    a <= b
  when ">="
    raise "Wrong number of arguments for >=" if a.nil? || b.nil?
    a >= b
  when "list"
    args
  when "list?"
    list?(a)
  when "empty?"
    null?(a)
  when "count"
    if null?(a)
      0
    elsif list?(a)
      count_list(a)
    else
      raise "count requires a list"
    end
  when "not"
    a.nil? || a == false
  else
    raise "Unknown function: #{f}"
  end
end

def count_list(lst)
  count = 0
  while !null?(lst)
    count += 1
    lst = cdr(lst)
  end
  count
end

# Core functions
def create_core_fns
  core = {}
  
  # Arithmetic
  %w[+ - * /].each { |op| core[op] = op }
  
  # Comparison
  %w[= < > <= >=].each { |op| core[op] = op }
  
  # List operations
  %w[list list? empty? count].each { |op| core[op] = op }
  
  # Logic
  core["not"] = "not"
  
  core
end

# Create the REPL environment
def create_repl_env
  env = Env.new
  
  # Add core functions
  create_core_fns.each do |name, func|
    env.set(name, func)
  end
  
  env
end

# REPL
if __FILE__ == $0
  puts "Step 5: Tail Call Optimization"
  puts "Try: (def! sum2 (fn* (n acc) (if (= n 0) acc (sum2 (- n 1) (+ n acc)))))"
  puts "Then: (sum2 10000 0) - should return 50005000 without stack overflow"
  
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