# Environment module for MAL - Variable bindings using association lists
#
# PEDAGOGICAL NOTE: Environments are how we implement variable scope.
# Each environment stores variable bindings and has a pointer to an
# outer (parent) environment, creating a chain.
#
# This implementation uses association lists (alists) - lists of pairs
# where each pair is (name . value). This is inefficient but clear.
#
# Example environment chain:
#   Global: x=10, y=20
#     ↑
#   Function: z=30
#     ↑  
#   Let: x=40 (shadows global x)

require_relative 'reader'

class Env
  # Every environment has:
  # - data: association list of bindings in THIS environment
  # - outer: reference to parent environment (or nil for global)
  attr_reader :data, :outer
  
  def initialize(outer = nil)
    @data = nil    # Start with empty association list
    @outer = outer # Parent environment
  end
  
  # Add or update a binding in THIS environment
  # PEDAGOGICAL NOTE: We always add to the front of the list.
  # This means newer bindings shadow older ones naturally.
  def set(key, value)
    # Create new binding pair
    binding = cons(key, value)
    
    # Add to front of association list
    @data = cons(binding, @data)
    
    # Return the value (Lisp convention)
    value
  end
  
  # Find which environment contains a binding
  # PEDAGOGICAL NOTE: This implements lexical scoping.
  # We search from inner to outer environments.
  def find(key)
    # First, check if key exists in this environment
    binding = assoc(key, @data)
    
    if binding
      # Found it here
      self
    elsif @outer
      # Not here, try parent environment
      @outer.find(key)
    else
      # Not found anywhere
      nil
    end
  end
  
  # Get the value of a binding
  # Raises error if not found
  def get(key)
    # Find which environment has the binding
    env = find(key)
    
    if env
      # Get the binding from that environment
      binding = assoc(key, env.data)
      # Return the value (cdr of the pair)
      cdr(binding)
    else
      # Variable not defined
      raise "Unknown symbol: #{key}"
    end
  end
  
  private
  
  # Search for a key in an association list
  # Returns the (key . value) pair if found, nil otherwise
  #
  # PEDAGOGICAL NOTE: This is a classic recursive list search.
  # For each binding, we check if its key matches what we want.
  def assoc(key, alist)
    # Base case: empty list
    return nil if null?(alist)
    
    # Get first binding
    binding = car(alist)
    
    # Check if this is the one we want
    if car(binding) == key
      # Found it!
      binding
    else
      # Not this one, keep searching
      assoc(key, cdr(alist))
    end
  end
end

# ===== ENVIRONMENT UTILITIES =====

# Create environment with bindings from parallel lists
# PEDAGOGICAL NOTE: This is used by fn* to bind parameters
# params: (x y z)
# args: (1 2 3)
# Result: environment with x=1, y=2, z=3
def bind_params(params, args, env)
  # Check for parameter/argument mismatch
  if count_list(params) != count_list(args)
    raise "Wrong number of arguments: expected #{count_list(params)}, got #{count_list(args)}"
  end
  
  # Bind each parameter to corresponding argument
  while !null?(params)
    param = car(params)
    arg = car(args)
    
    # Parameter must be a symbol
    if !symbol?(param)
      raise "Function parameter must be symbol, got #{pr_str(param)}"
    end
    
    # Create binding
    env.set(param.name, arg)
    
    # Move to next parameter/argument
    params = cdr(params)
    args = cdr(args)
  end
end

# Process let* bindings
# PEDAGOGICAL NOTE: let* creates bindings sequentially,
# so later bindings can refer to earlier ones.
# 
# bindings: (x 10 y (+ x 5))
# This creates x=10, then y=15
def process_bindings(bindings, env)
  # For vectors, get the elements
  if vector?(bindings)
    bindings = bindings.elements
  end
  
  # Process pairs of symbol/value
  while !null?(bindings)
    # Need at least symbol and value
    if null?(bindings) || null?(cdr(bindings))
      raise "let* bindings must be even"
    end
    
    # Get symbol and expression
    sym = car(bindings)
    expr = car(cdr(bindings))
    
    # Symbol must be a symbol
    if !symbol?(sym)
      raise "let* binding name must be symbol, got #{pr_str(sym)}"
    end
    
    # Evaluate expression and bind
    # IMPORTANT: We evaluate in env, which includes previous bindings
    val = EVAL(expr, env)
    env.set(sym.name, val)
    
    # Skip to next pair
    bindings = cdr(cdr(bindings))
  end
end

# Count elements in a list
def count_list(lst)
  count = 0
  current = lst
  
  while !null?(current)
    count += 1
    current = cdr(current)
  end
  
  count
end

# ===== VISUALIZATION HELPERS =====

# Print environment chain (for debugging)
def show_env_chain(env, prefix = "")
  return if env.nil?
  
  puts "#{prefix}Environment #{env.object_id}:"
  
  # Show bindings in this environment
  bindings = env.data
  while !null?(bindings)
    binding = car(bindings)
    puts "#{prefix}  #{car(binding)} = #{pr_str(cdr(binding), false)}"
    bindings = cdr(bindings)
  end
  
  # Show parent
  if env.outer
    puts "#{prefix}  ↑ parent"
    show_env_chain(env.outer, prefix + "  ")
  else
    puts "#{prefix}  (global)"
  end
end

# Example of environment chains:
#
# (def! x 10)                     Global: x=10
# (def! f (fn* (a) (+ a x)))      Global: x=10, f=<function>
# (let* (x 20)                    Let: x=20 → Global
#   (f 5))                        Call: a=5 → Global (NOT Let!)
#
# Result is 15, not 25, because f captures its definition environment