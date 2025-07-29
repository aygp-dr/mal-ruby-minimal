#!/usr/bin/env ruby

# Step A: Self-hosting
# The final step - MAL can run itself

require_relative 'reader'
require_relative 'printer'
require_relative 'env'

# Custom exception class for MAL exceptions
class MalException < StandardError
  attr_reader :value
  
  def initialize(value)
    @value = value
    super(pr_str(value, false))
  end
end

def READ(str)
  read_str(str)
end

# Macro expansion - recursively expand macros in the AST
def macroexpand(ast, env)
  # Keep expanding while we have a macro call
  while true
    # Only lists can be macro calls
    if !list?(ast) || null?(ast)
      return ast
    end
    
    # First element must be a symbol
    first = car(ast)
    if !symbol?(first)
      return ast
    end
    
    # Look up the symbol
    begin
      fn = env.get(first.name)
    rescue
      # Symbol not found - not a macro
      return ast
    end
    
    # Check if it's a macro
    if !mal_fn?(fn) || !fn.is_macro?
      return ast
    end
    
    # Apply the macro to get a new form
    args = cdr(ast)
    macro_env = Env.new(fn.env)
    bind_params(fn.params, args, macro_env)
    ast = EVAL(fn.body, macro_env)
    # Loop to continue expansion
  end
end

def EVAL(ast, env)
  # TCO loop - instead of recursion, we loop with updated ast/env
  loop do
    # Macro expansion
    ast = macroexpand(ast, env)
    
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
        
      when "defmacro!"
        # (defmacro! symbol (fn* ...))
        if null?(cdr(ast)) || null?(cdr(cdr(ast)))
          raise "defmacro! requires 2 arguments"
        end
        
        sym = car(cdr(ast))
        if !symbol?(sym)
          raise "defmacro! first argument must be a symbol"
        end
        
        # Evaluate the function definition
        val = EVAL(car(cdr(cdr(ast))), env)
        
        # Must be a mal function
        if !mal_fn?(val)
          raise "defmacro! value must be a function"
        end
        
        # Create a new macro function with is_macro set to true
        macro = make_mal_fn(val.params, val.body, val.env, true)
        env.set(sym.name, macro)
        return macro
        
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
        
      when "quote"
        # (quote expr) - return expr without evaluation
        if null?(cdr(ast))
          raise "quote requires an argument"
        end
        return car(cdr(ast))
        
      when "quasiquote"
        # (quasiquote expr) - selective evaluation
        if null?(cdr(ast))
          raise "quasiquote requires an argument"
        end
        ast = quasiquote(car(cdr(ast)))
        # Loop continues with expanded form
        
      when "quasiquoteexpand"
        # (quasiquoteexpand expr) - show expansion without eval
        if null?(cdr(ast))
          raise "quasiquoteexpand requires an argument"
        end
        return quasiquote(car(cdr(ast)))
        
      when "macroexpand"
        # (macroexpand expr) - show macro expansion without eval
        if null?(cdr(ast))
          raise "macroexpand requires an argument"
        end
        return macroexpand(car(cdr(ast)), env)
        
      when "try*"
        # (try* expr (catch* symbol handler))
        if null?(cdr(ast))
          raise "try* requires an expression"
        end
        
        begin
          # Try to evaluate the expression
          return EVAL(car(cdr(ast)), env)
        rescue MalException => e
          # Handle MAL exceptions
          if null?(cdr(cdr(ast)))
            # No catch block, re-raise
            raise e
          end
          
          catch_clause = car(cdr(cdr(ast)))
          if !list?(catch_clause) || null?(catch_clause)
            raise "Invalid catch* clause"
          end
          
          if !symbol?(car(catch_clause)) || car(catch_clause).name != "catch*"
            raise "Expected catch* clause"
          end
          
          if null?(cdr(catch_clause)) || null?(cdr(cdr(catch_clause)))
            raise "catch* requires symbol and handler"
          end
          
          # Get exception symbol and handler
          exc_sym = car(cdr(catch_clause))
          if !symbol?(exc_sym)
            raise "catch* binding must be a symbol"
          end
          
          handler = car(cdr(cdr(catch_clause)))
          
          # Create new environment with exception bound
          catch_env = Env.new(env)
          catch_env.set(exc_sym.name, e.value)
          
          # Evaluate handler with TCO
          ast = handler
          env = catch_env
          # Loop continues with handler
        rescue => e
          # Handle Ruby exceptions by converting to MAL string
          if null?(cdr(cdr(ast)))
            # No catch block, re-raise
            raise e
          end
          
          catch_clause = car(cdr(cdr(ast)))
          if !list?(catch_clause) || null?(catch_clause)
            raise "Invalid catch* clause"
          end
          
          if !symbol?(car(catch_clause)) || car(catch_clause).name != "catch*"
            raise "Expected catch* clause"
          end
          
          if null?(cdr(catch_clause)) || null?(cdr(cdr(catch_clause)))
            raise "catch* requires symbol and handler"
          end
          
          # Get exception symbol and handler
          exc_sym = car(cdr(catch_clause))
          if !symbol?(exc_sym)
            raise "catch* binding must be a symbol"
          end
          
          handler = car(cdr(cdr(catch_clause)))
          
          # Create new environment with exception bound
          catch_env = Env.new(env)
          catch_env.set(exc_sym.name, e.message)
          
          # Evaluate handler with TCO
          ast = handler
          env = catch_env
          # Loop continues with handler
        end
        
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
          return apply_builtin(f, args, env)
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
        return apply_builtin(f, args, env)
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

# Quasiquote implementation
def quasiquote(ast)
  if !pair?(ast)
    # Not a list - check if it needs quoting
    if symbol?(ast) || (ast.respond_to?(:vector?) && ast.vector?) || 
       (ast.respond_to?(:hash_map?) && ast.hash_map?)
      # Quote symbols, vectors, and hash-maps
      list2(make_symbol("quote"), ast)
    else
      # Return literals unchanged (numbers, strings, nil, true, false)
      ast
    end
  elsif symbol?(car(ast)) && car(ast).name == "unquote"
    # (unquote expr) -> expr
    if null?(cdr(ast))
      raise "unquote requires an argument"
    end
    car(cdr(ast))
  else
    # Process list elements
    quasiquote_list(ast)
  end
end

def quasiquote_list(lst)
  if null?(lst)
    nil
  elsif !pair?(lst)
    # Not a proper list - quote it
    list2(make_symbol("quote"), lst)
  elsif pair?(car(lst)) && !null?(car(lst)) && 
        symbol?(car(car(lst))) && car(car(lst)).name == "splice-unquote"
    # Handle splice-unquote
    splice_elem = car(lst)
    if null?(cdr(splice_elem))
      raise "splice-unquote requires an argument"
    end
    list3(make_symbol("concat"), 
          car(cdr(splice_elem)), 
          quasiquote_list(cdr(lst)))
  else
    # Regular element
    list3(make_symbol("cons"), 
          quasiquote(car(lst)), 
          quasiquote_list(cdr(lst)))
  end
end

# MAL function type for TCO
def make_mal_fn(params, body, env, is_macro = false)
  fn = Object.new
  fn.instance_variable_set(:@params, params)
  fn.instance_variable_set(:@body, body)
  fn.instance_variable_set(:@env, env)
  fn.instance_variable_set(:@is_mal_fn, true)
  fn.instance_variable_set(:@is_macro, is_macro)
  
  eval <<-RUBY
    def fn.params; @params; end
    def fn.body; @body; end
    def fn.env; @env; end
    def fn.mal_fn?; true; end
    def fn.is_macro?; @is_macro; end
    def fn.to_s; @is_macro ? "#<macro>" : "#<function>"; end
  RUBY
  
  fn
end

def mal_fn?(obj)
  obj.respond_to?(:mal_fn?) && obj.mal_fn?
end

# Atom type for mutable state
def make_atom(value)
  atom = Object.new
  atom.instance_variable_set(:@value, value)
  
  eval <<-RUBY
    def atom.value; @value; end
    def atom.value=(v); @value = v; end
    def atom.atom?; true; end
    def atom.to_s; "(atom " + @value.to_s + ")"; end
  RUBY
  
  atom
end

def atom?(obj)
  obj.respond_to?(:atom?) && obj.atom?
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
  # Check for variadic parameter (&)
  if !null?(params) && !null?(cdr(params))
    if symbol?(car(params)) && car(params).name == "&"
      # Variadic: bind first param to consumed args, second to remaining
      if null?(cdr(cdr(params)))
        # & rest-param
        rest_param = car(cdr(params))
        if !symbol?(rest_param)
          raise "Variadic parameter must be a symbol"
        end
        env.set(rest_param.name, args)
        return
      else
        raise "& must be followed by exactly one parameter"
      end
    end
  end
  
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

def apply_builtin(f, args, env)
  # Extract arguments from list
  a = null?(args) ? nil : car(args)
  b = null?(args) || null?(cdr(args)) ? nil : car(cdr(args))
  c = null?(args) || null?(cdr(args)) || null?(cdr(cdr(args))) ? nil : car(cdr(cdr(args)))
  
  case f
  when "+"
    # Sum all arguments
    result = 0
    lst = args
    while !null?(lst)
      val = car(lst)
      raise "All arguments to + must be numbers" unless val.is_a?(Integer) || val.is_a?(Float)
      result += val
      lst = cdr(lst)
    end
    result
  when "-"
    raise "- requires at least 1 argument" if null?(args)
    if null?(cdr(args))
      # Single argument: negate
      -car(args)
    else
      # Multiple arguments: subtract rest from first
      result = car(args)
      lst = cdr(args)
      while !null?(lst)
        result -= car(lst)
        lst = cdr(lst)
      end
      result
    end
  when "*"
    # Multiply all arguments
    result = 1
    lst = args
    while !null?(lst)
      val = car(lst)
      raise "All arguments to * must be numbers" unless val.is_a?(Integer) || val.is_a?(Float)
      result *= val
      lst = cdr(lst)
    end
    result
  when "/"
    raise "/ requires at least 1 argument" if null?(args)
    if null?(cdr(args))
      # Single argument: reciprocal
      raise "Division by zero" if car(args) == 0
      1.0 / car(args)
    else
      # Multiple arguments: divide first by rest
      result = car(args).to_f
      lst = cdr(args)
      while !null?(lst)
        divisor = car(lst)
        raise "Division by zero" if divisor == 0
        result /= divisor
        lst = cdr(lst)
      end
      result.to_i == result ? result.to_i : result
    end
  when "%"
    raise "Wrong number of arguments for %" if a.nil? || b.nil?
    raise "Modulo by zero" if b == 0
    a % b
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
  when "throw"
    raise MalException.new(a)
  when "pr-str"
    # Join all args with space, print readably
    strs = []
    lst = args
    while !null?(lst)
      strs << pr_str(car(lst), true)
      lst = cdr(lst)
    end
    strs.join(" ")
  when "str"
    # Join all args, no spaces, not readable
    strs = []
    lst = args
    while !null?(lst)
      strs << pr_str(car(lst), false)
      lst = cdr(lst)
    end
    strs.join("")
  when "prn"
    # Print with spaces, readable, then newline
    strs = []
    lst = args
    while !null?(lst)
      strs << pr_str(car(lst), true)
      lst = cdr(lst)
    end
    puts strs.join(" ")
    nil
  when "println"
    # Print with spaces, not readable, then newline
    strs = []
    lst = args
    while !null?(lst)
      strs << pr_str(car(lst), false)
      lst = cdr(lst)
    end
    puts strs.join(" ")
    nil
  when "read-string"
    raise "read-string requires a string" unless a.is_a?(String)
    read_str(a)
  when "slurp"
    raise "slurp requires a string filename" unless a.is_a?(String)
    File.read(a)
  when "atom"
    make_atom(a)
  when "atom?"
    atom?(a)
  when "deref"
    raise "deref requires an atom" unless atom?(a)
    a.value
  when "reset!"
    raise "reset! requires an atom" unless atom?(a)
    a.value = b
    b
  when "swap!"
    raise "swap! requires an atom and function" unless atom?(a)
    # Get current value
    old_val = a.value
    # Build args list for function
    fn_args = cons(old_val, cdr(cdr(args)))
    # Apply function
    if mal_fn?(b)
      # Need to eval the function with args
      fn_env = Env.new(b.env)
      bind_params(b.params, fn_args, fn_env)
      new_val = EVAL(b.body, fn_env)
    else
      new_val = apply_builtin(b, fn_args, env)
    end
    # Update atom
    a.value = new_val
    new_val
  when "eval"
    EVAL(a, env)
  when "cons"
    # cons needs exactly 2 arguments - check if we have at least 2 items in args list
    if null?(args) || null?(cdr(args))
      raise "cons requires 2 arguments"
    end
    cons(a, b)
  when "car"
    if null?(a)
      nil
    else
      car(a)
    end
  when "cdr"
    if null?(a)
      nil
    else
      cdr(a)
    end
  when "concat"
    # Concatenate lists
    concat_lists(args)
  when "nth"
    # Get nth element of list
    raise "nth requires list and index" if null?(args) || null?(cdr(args))
    lst = a
    n = b
    raise "nth requires a number index" unless n.is_a?(Integer)
    raise "nth index out of range" if n < 0
    i = 0
    while i < n && !null?(lst)
      lst = cdr(lst)
      i += 1
    end
    raise "nth index out of range" if null?(lst)
    car(lst)
  when "first"
    # Get first element of list (or nil)
    if null?(a)
      nil
    else
      car(a)
    end
  when "rest"
    # Get all but first element of list
    if null?(a)
      nil
    else
      cdr(a)
    end
  when "apply"
    # Apply function to list of arguments
    raise "apply requires at least 2 arguments" if null?(args) || null?(cdr(args))
    f = a
    # If only 2 args (function and list), use the list directly
    if null?(cdr(cdr(args)))
      final_args = b
    else
      # Multiple args: collect all but last, then append last list
      mid_args = []
      lst = cdr(args)
      while !null?(cdr(lst))
        mid_args << car(lst)
        lst = cdr(lst)
      end
      # Last arg should be a list
      last_list = car(lst)
      # Build final args list: mid_args + last_list
      final_args = last_list
      i = mid_args.length - 1
      while i >= 0
        final_args = cons(mid_args[i], final_args)
        i -= 1
      end
    end
    # Apply the function
    if mal_fn?(f)
      fn_env = Env.new(f.env)
      bind_params(f.params, final_args, fn_env)
      EVAL(f.body, fn_env)
    else
      apply_builtin(f, final_args, env)
    end
  when "map"
    # Map function over list
    raise "map requires function and list" if null?(args) || null?(cdr(args))
    f = a
    lst = b
    map_list(f, lst, env)
  when "nil?"
    null?(a)
  when "true?"
    a == true
  when "false?"
    a == false
  when "string?"
    a.is_a?(String)
  when "symbol"
    # Convert string to symbol
    raise "symbol requires a string" unless a.is_a?(String)
    make_symbol(a)
  when "symbol?"
    symbol?(a)
  when "keyword"
    # Convert string to keyword
    raise "keyword requires a string" unless a.is_a?(String)
    make_keyword(a)
  when "keyword?"
    keyword?(a)
  when "number?"
    a.is_a?(Integer) || a.is_a?(Float)
  when "fn?"
    # Check if it's a function (not macro)
    mal_fn?(a) && !a.is_macro?
  when "macro?"
    mal_fn?(a) && a.is_macro?
  when "vector"
    # Create vector from arguments
    make_vector(args)
  when "vector?"
    vector?(a)
  when "hash-map"
    # Create hash-map from arguments
    make_hash_map(args)
  when "map?"
    hash_map?(a)
  when "assoc"
    # Associate key-value pairs with hash-map
    raise "assoc requires hash-map" unless hash_map?(a)
    new_pairs = assoc_pairs(a.pairs, cdr(args))
    make_hash_map_from_pairs(new_pairs)
  when "dissoc"
    # Remove keys from hash-map
    raise "dissoc requires hash-map" unless hash_map?(a)
    new_pairs = dissoc_keys(a.pairs, cdr(args))
    make_hash_map_from_pairs(new_pairs)
  when "get"
    # Get value from hash-map
    if hash_map?(a) && !null?(cdr(args))
      key = b
      lookup_hash_map(a.pairs, key)
    elsif null?(a)
      nil
    else
      nil
    end
  when "contains?"
    # Check if hash-map contains key
    if hash_map?(a) && !null?(cdr(args))
      key = b
      !lookup_hash_map(a.pairs, key).nil?
    else
      false
    end
  when "keys"
    # Get keys from hash-map
    raise "keys requires hash-map" unless hash_map?(a)
    get_hash_map_keys(a.pairs)
  when "vals"
    # Get values from hash-map
    raise "vals requires hash-map" unless hash_map?(a)
    get_hash_map_vals(a.pairs)
  when "sequential?"
    list?(a) || vector?(a)
  when "readline"
    # Read line from input with prompt
    prompt = a.is_a?(String) ? a : "user> "
    print prompt
    line = gets
    line ? line.chomp : nil
  when "meta"
    # Get metadata
    if a.respond_to?(:meta)
      a.meta
    else
      nil
    end
  when "with-meta"
    # Attach metadata to object
    raise "with-meta requires 2 arguments" if null?(args) || null?(cdr(args))
    obj = a
    meta = b
    with_meta(obj, meta)
  when "time-ms"
    # Current time in milliseconds
    (Time.now.to_f * 1000).to_i
  when "conj"
    # Add elements to collection
    raise "conj requires at least 1 argument" if null?(args)
    coll = a
    elements = cdr(args)
    if list?(coll)
      # Add to front of list
      result = coll
      while !null?(elements)
        result = cons(car(elements), result)
        elements = cdr(elements)
      end
      result
    elsif vector?(coll)
      # Add to end of vector
      result = coll.elements
      while !null?(elements)
        result = append_list(result, cons(car(elements), nil))
        elements = cdr(elements)
      end
      make_vector(result)
    else
      raise "conj requires list or vector"
    end
  when "seq"
    # Convert to sequence
    if null?(a)
      nil
    elsif list?(a)
      a
    elsif vector?(a)
      a.elements
    elsif a.is_a?(String)
      if a.empty?
        nil
      else
        # Convert string to list of single-char strings
        str_to_list(a)
      end
    else
      nil
    end
  else
    raise "Unknown function: #{f}"
  end
end

def concat_lists(lists)
  result = nil
  # Process in reverse to build result
  lst_array = []
  while !null?(lists)
    lst_array << car(lists)
    lists = cdr(lists)
  end
  
  # Start from the end
  i = lst_array.length - 1
  while i >= 0
    curr = lst_array[i]
    if list?(curr)
      # Append each element
      result = append_list(curr, result)
    elsif !curr.nil?
      raise "concat requires lists"
    end
    i -= 1
  end
  result
end

def append_list(lst, tail)
  if null?(lst)
    tail
  else
    cons(car(lst), append_list(cdr(lst), tail))
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

# Map function over list
def map_list(f, lst, env)
  if null?(lst)
    nil
  else
    mapped_val = if mal_fn?(f)
      fn_env = Env.new(f.env)
      bind_params(f.params, cons(car(lst), nil), fn_env)
      EVAL(f.body, fn_env)
    else
      apply_builtin(f, cons(car(lst), nil), env)
    end
    cons(mapped_val, map_list(f, cdr(lst), env))
  end
end

# Create vector from list
def make_vector(lst)
  vec = Object.new
  vec.instance_variable_set(:@elements, lst)
  eval <<-RUBY
    def vec.vector?; true; end
    def vec.elements; @elements; end
    def vec.to_s; "[" + elements_to_s(@elements) + "]"; end
    def vec.elements_to_s(els)
      if null?(els)
        ""
      elsif null?(cdr(els))
        pr_str(car(els), true)
      else
        pr_str(car(els), true) + " " + elements_to_s(cdr(els))
      end
    end
  RUBY
  vec
end

# Create hash-map from alternating key-value list
def make_hash_map(lst)
  hm = Object.new
  pairs = build_hash_map_pairs(lst)
  hm.instance_variable_set(:@pairs, pairs)
  eval <<-RUBY
    def hm.hash_map?; true; end
    def hm.pairs; @pairs; end
  RUBY
  hm
end

# Build hash-map pairs from alternating list
def build_hash_map_pairs(lst)
  if null?(lst) || null?(cdr(lst))
    nil
  else
    key = car(lst)
    val = car(cdr(lst))
    cons(cons(key, val), build_hash_map_pairs(cdr(cdr(lst))))
  end
end

# Create hash-map from pairs list
def make_hash_map_from_pairs(pairs)
  hm = Object.new
  hm.instance_variable_set(:@pairs, pairs)
  eval <<-RUBY
    def hm.hash_map?; true; end
    def hm.pairs; @pairs; end
  RUBY
  hm
end

# Lookup value in hash-map pairs
def lookup_hash_map(pairs, key)
  if null?(pairs)
    nil
  else
    pair = car(pairs)
    if car(pair) == key
      cdr(pair)
    else
      lookup_hash_map(cdr(pairs), key)
    end
  end
end

# Associate new key-value pairs
def assoc_pairs(pairs, kvs)
  if null?(kvs)
    pairs
  elsif null?(cdr(kvs))
    pairs  # Odd number, ignore last
  else
    key = car(kvs)
    val = car(cdr(kvs))
    new_pairs = remove_key(pairs, key)
    cons(cons(key, val), assoc_pairs(new_pairs, cdr(cdr(kvs))))
  end
end

# Remove key from pairs
def remove_key(pairs, key)
  if null?(pairs)
    nil
  elsif car(car(pairs)) == key
    cdr(pairs)
  else
    cons(car(pairs), remove_key(cdr(pairs), key))
  end
end

# Dissociate keys from pairs
def dissoc_keys(pairs, keys)
  if null?(keys)
    pairs
  else
    dissoc_keys(remove_key(pairs, car(keys)), cdr(keys))
  end
end

# Get keys from hash-map
def get_hash_map_keys(pairs)
  if null?(pairs)
    nil
  else
    cons(car(car(pairs)), get_hash_map_keys(cdr(pairs)))
  end
end

# Get values from hash-map
def get_hash_map_vals(pairs)
  if null?(pairs)
    nil
  else
    cons(cdr(car(pairs)), get_hash_map_vals(cdr(pairs)))
  end
end

# Convert string to list of characters
def str_to_list(str)
  result = nil
  i = str.length - 1
  while i >= 0
    result = cons(str.slice(i, 1), result)
    i -= 1
  end
  result
end

# Create keyword
def make_keyword(name)
  keyword = Object.new
  keyword.instance_variable_set(:@name, ":" + name)
  eval <<-RUBY
    def keyword.keyword?; true; end
    def keyword.name; @name; end
    def keyword.to_s; @name; end
    def keyword.==(other)
      other.respond_to?(:keyword?) && other.keyword? && other.name == @name
    end
  RUBY
  keyword
end

# Check if keyword
def keyword?(obj)
  obj.respond_to?(:keyword?) && obj.keyword?
end

# Add metadata support
def with_meta(obj, meta)
  # Create a copy with metadata
  new_obj = obj.dup
  new_obj.instance_variable_set(:@meta, meta)
  
  # Define meta accessor if not already defined
  unless new_obj.respond_to?(:meta)
    eval <<-RUBY
      def new_obj.meta; @meta; end
    RUBY
  end
  
  new_obj
end

# Convert Ruby array to MAL list
def array_to_list(arr)
  result = nil
  i = arr.length - 1
  while i >= 0
    result = cons(arr[i], result)
    i -= 1
  end
  result
end

# Core functions
def create_core_fns
  core = {}
  
  # Arithmetic
  %w[+ - * / %].each { |op| core[op] = op }
  
  # Comparison
  %w[= < > <= >=].each { |op| core[op] = op }
  
  # List operations
  %w[list list? empty? count].each { |op| core[op] = op }
  
  # List manipulation
  %w[cons concat car cdr nth first rest].each { |op| core[op] = op }
  
  # Higher-order functions
  %w[apply map].each { |op| core[op] = op }
  
  # Type predicates
  %w[nil? true? false? string? symbol? keyword? number? fn? macro? sequential?].each { |op| core[op] = op }
  
  # Type conversions
  %w[symbol keyword vector hash-map].each { |op| core[op] = op }
  
  # Collection operations
  %w[vector? map? assoc dissoc get contains? keys vals conj seq].each { |op| core[op] = op }
  
  # Logic
  core["not"] = "not"
  
  # Exception handling
  core["throw"] = "throw"
  
  # String functions
  %w[pr-str str prn println].each { |op| core[op] = op }
  
  # I/O
  %w[read-string slurp readline].each { |op| core[op] = op }
  
  # Atoms
  %w[atom atom? deref reset! swap!].each { |op| core[op] = op }
  
  # Metadata
  %w[meta with-meta].each { |op| core[op] = op }
  
  # Time
  core["time-ms"] = "time-ms"
  
  # Special
  core["eval"] = "eval"
  
  core
end

# Create the REPL environment
def create_repl_env
  env = Env.new
  
  # Add core functions
  create_core_fns.each do |name, func|
    env.set(name, func)
  end
  
  # Add *ARGV* for command line args
  argv_list = array_to_list(ARGV[1..-1] || [])
  env.set("*ARGV*", argv_list)
  
  # Define load-file function
  env.set("load-file", make_mal_fn(
    cons(make_symbol("filename"), nil),
    read_str('(eval (read-string (str "(do " (slurp filename) "\nnil)")))'),
    env
  ))
  
  # Define cond macro
  rep("(defmacro! cond (fn* (& xs) (if (> (count xs) 0) (list 'if (first xs) (if (> (count xs) 1) (nth xs 1) (throw \"odd number of forms to cond\")) (cons 'cond (rest (rest xs)))))))", env)
  
  env
end

# REPL
if __FILE__ == $0
  repl_env = create_repl_env
  
  # If file argument provided, load it
  if ARGV.length > 0
    begin
      rep("(load-file \"#{ARGV[0]}\")", repl_env)
      exit 0
    rescue => e
      puts "Error loading file: #{e.message}"
      exit 1
    end
  end
  
  # Interactive REPL
  puts "Step A: Self-hosting MAL"
  puts "All core functions implemented. Ready for self-hosting!"
  puts "Try: (load-file \"mal/stepA_mal.mal\") to load MAL-in-MAL"
  
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