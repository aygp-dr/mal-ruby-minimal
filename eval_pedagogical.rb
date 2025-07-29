# Core Evaluator for MAL - The heart of the interpreter
#
# PEDAGOGICAL NOTE: This module shows how evaluation works in Lisp.
# The EVAL function is the core of any Lisp interpreter. It takes
# an Abstract Syntax Tree (AST) and an environment, and returns
# the result of evaluating that AST.
#
# Key insight: Code and data have the same structure in Lisp.
# The evaluator's job is to interpret data structures as code.

require_relative 'reader'
require_relative 'printer'
require_relative 'env'

# ===== THE CORE EVALUATOR =====
# This function implements the evaluation rules of Lisp
def EVAL(ast, env)
  # PEDAGOGICAL NOTE: We use a loop for Tail Call Optimization (TCO).
  # Instead of making recursive calls that grow the stack, we update
  # ast and env and loop back. This prevents stack overflow.
  loop do
    
    # ===== SELF-EVALUATING FORMS =====
    # Some things evaluate to themselves
    if null?(ast)
      return nil
    elsif ast.is_a?(Integer) || ast.is_a?(String) || 
          ast == true || ast == false
      return ast
    elsif keyword?(ast)
      return ast
    end
    
    # ===== SYMBOLS: Variable Lookup =====
    if symbol?(ast)
      return env.get(ast.name)
    end
    
    # ===== VECTORS: Evaluate Each Element =====
    if vector?(ast)
      elements = eval_ast(ast.elements, env)
      vec = Object.new
      vec.instance_variable_set(:@elements, elements)
      eval <<-RUBY
        def vec.vector?; true; end
        def vec.elements; @elements; end
      RUBY
      return vec
    end
    
    # ===== HASH-MAPS: Evaluate Keys and Values =====
    if hash_map?(ast)
      # Evaluate each key-value pair
      new_pairs = nil
      pairs = ast.pairs
      while !null?(pairs)
        pair = car(pairs)
        key = EVAL(car(pair), env)
        val = EVAL(cdr(pair), env)
        new_pairs = cons(cons(key, val), new_pairs)
        pairs = cdr(pairs)
      end
      
      hm = Object.new
      hm.instance_variable_set(:@pairs, reverse_list(new_pairs))
      eval <<-RUBY
        def hm.hash_map?; true; end
        def hm.pairs; @pairs; end
      RUBY
      return hm
    end
    
    # ===== LISTS: Function Application or Special Forms =====
    if !list?(ast)
      # Not a list - shouldn't happen with valid input
      return ast
    end
    
    # Empty list evaluates to itself
    if null?(ast)
      return ast
    end
    
    # ===== CHECK FOR SPECIAL FORMS =====
    # Special forms have custom evaluation rules
    first = car(ast)
    if symbol?(first)
      case first.name
      
      when "def!"
        # ===== DEF!: Define Global Variable =====
        # (def! symbol value)
        # Evaluates value and binds it to symbol in current environment
        
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "def! requires exactly 2 arguments"
        end
        
        sym = car(cdr(ast))
        if !symbol?(sym)
          raise "def! first argument must be a symbol"
        end
        
        # Evaluate the value expression
        val = EVAL(car(cdr(cdr(ast))), env)
        
        # Bind in current environment
        env.set(sym.name, val)
        
        # Return the value
        return val
        
      when "let*"
        # ===== LET*: Local Bindings =====
        # (let* (x 10 y 20) body)
        # Creates new environment with bindings, evaluates body
        
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "let* requires bindings and body"
        end
        
        bindings = car(cdr(ast))
        body = car(cdr(cdr(ast)))
        
        # Create new environment extending current one
        let_env = Env.new(env)
        
        # Process bindings in new environment
        process_bindings(bindings, let_env)
        
        # TCO: Evaluate body in new environment
        ast = body
        env = let_env
        # Loop continues with new ast/env
        
      when "if"
        # ===== IF: Conditional Evaluation =====
        # (if condition then-expr else-expr?)
        # Only evaluates the branch it needs
        
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "if requires at least 2 arguments"
        end
        
        # Evaluate condition
        condition = EVAL(car(cdr(ast)), env)
        
        # Check truthiness (only nil and false are falsy)
        if condition.nil? || condition == false
          # False branch
          if !null?(cdr(cdr(cdr(ast))))
            # Has else expression
            ast = car(cdr(cdr(cdr(ast))))
            # Loop continues with else expression
          else
            # No else expression
            return nil
          end
        else
          # True branch
          ast = car(cdr(cdr(ast)))
          # Loop continues with then expression
        end
        
      when "fn*"
        # ===== FN*: Create Function =====
        # (fn* (params...) body)
        # Creates a closure that captures current environment
        
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "fn* requires parameters and body"
        end
        
        params = car(cdr(ast))
        body = car(cdr(cdr(ast)))
        
        # Create closure
        # PEDAGOGICAL NOTE: The function captures env, creating
        # a closure. This is how we get lexical scoping.
        return make_mal_fn(params, body, env)
        
      when "do"
        # ===== DO: Sequential Evaluation =====
        # (do expr1 expr2 ... exprN)
        # Evaluates all expressions, returns last
        
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
        
      when "quote"
        # ===== QUOTE: Prevent Evaluation =====
        # (quote expr) returns expr without evaluating
        
        if null?(cdr(ast))
          raise "quote requires an argument"
        end
        
        # Return quoted expression unchanged
        return car(cdr(ast))
        
      else
        # ===== FUNCTION CALL =====
        # Not a special form, evaluate as function call
        # (function arg1 arg2 ...)
        
        # Evaluate function and arguments
        evaluated = eval_ast(ast, env)
        f = car(evaluated)
        args = cdr(evaluated)
        
        # Apply function
        if mal_fn?(f)
          # User-defined function - use TCO
          ast = f.body
          env = Env.new(f.env)
          bind_params(f.params, args, env)
          # Loop continues with function body
        else
          # Built-in function - no TCO needed
          return apply_builtin(f, args, env)
        end
      end
      
    else
      # ===== LIST WITHOUT SYMBOL =====
      # First element isn't a symbol, evaluate everything
      # Example: ((if true + -) 2 3)
      
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
        return apply_builtin(f, args, env)
      end
    end
  end
end

# Evaluate each element of a list
# PEDAGOGICAL NOTE: This is a map operation - apply EVAL to each element
def eval_ast(ast, env)
  if null?(ast)
    nil
  else
    cons(EVAL(car(ast), env), eval_ast(cdr(ast), env))
  end
end

# ===== FUNCTION REPRESENTATION =====

# Create a MAL function (closure)
def make_mal_fn(params, body, env)
  fn = Object.new
  fn.instance_variable_set(:@params, params)
  fn.instance_variable_set(:@body, body)
  fn.instance_variable_set(:@env, env)
  
  eval <<-RUBY
    def fn.mal_fn?; true; end
    def fn.params; @params; end
    def fn.body; @body; end
    def fn.env; @env; end
  RUBY
  
  fn
end

# Check if something is a MAL function
def mal_fn?(obj)
  obj.respond_to?(:mal_fn?) && obj.mal_fn?
end

# ===== BUILT-IN FUNCTIONS =====

# Apply a built-in function
# PEDAGOGICAL NOTE: Built-ins are implemented in Ruby, not MAL
def apply_builtin(f, args, env)
  case f
  when "+"
    accumulate_args(args, 0) { |a, b| a + b }
  when "-"
    if null?(args)
      raise "- requires at least 1 argument"
    elsif null?(cdr(args))
      -car(args)
    else
      car(args) - accumulate_args(cdr(args), 0) { |a, b| a + b }
    end
  when "*"
    accumulate_args(args, 1) { |a, b| a * b }
  when "/"
    if null?(args) || null?(cdr(args))
      raise "/ requires at least 2 arguments"
    end
    first = car(args)
    rest = cdr(args)
    while !null?(rest)
      divisor = car(rest)
      raise "Division by zero" if divisor == 0
      first = first / divisor
      rest = cdr(rest)
    end
    first
  when "="
    compare_args(args) { |a, b| a == b }
  when "<"
    compare_args(args) { |a, b| a < b }
  when ">"
    compare_args(args) { |a, b| a > b }
  when "<="
    compare_args(args) { |a, b| a <= b }
  when ">="
    compare_args(args) { |a, b| a >= b }
  when "list"
    args
  when "list?"
    list?(car(args))
  when "empty?"
    null?(car(args))
  when "count"
    count_list(car(args))
  when "not"
    val = car(args)
    val.nil? || val == false
  else
    raise "Unknown function: #{f}"
  end
end

# Helper: accumulate over arguments
def accumulate_args(args, initial)
  result = initial
  while !null?(args)
    result = yield(result, car(args))
    args = cdr(args)
  end
  result
end

# Helper: compare arguments pairwise
def compare_args(args)
  if null?(args) || null?(cdr(args))
    raise "Comparison requires 2 arguments"
  end
  yield(car(args), car(cdr(args)))
end

# ===== VISUALIZATION: See How Evaluation Works =====

# Trace evaluation (for learning)
$trace_eval = false

def trace_indent
  "  " * ($trace_depth || 0)
end

def EVAL_traced(ast, env)
  $trace_depth ||= 0
  $trace_depth += 1
  
  puts "#{trace_indent}EVAL: #{pr_str(ast, true)}"
  
  result = EVAL(ast, env)
  
  puts "#{trace_indent}  => #{pr_str(result, true)}"
  
  $trace_depth -= 1
  result
end

# Example trace:
# (+ 1 (- 3 2))
#   EVAL: (+ 1 (- 3 2))
#     EVAL: +
#       => #<builtin:+>
#     EVAL: 1
#       => 1
#     EVAL: (- 3 2)
#       EVAL: -
#         => #<builtin:->
#       EVAL: 3
#         => 3
#       EVAL: 2
#         => 2
#       => 1
#     => 2