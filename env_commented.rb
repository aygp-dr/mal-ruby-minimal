#!/usr/bin/env ruby

# MAL Environment - Variable Storage Without Hash Tables
#
# PEDAGOGICAL NOTES:
# This module shows how environments (variable bindings) work in interpreters.
# Instead of using Ruby's hash tables, we build everything from cons cells
# to demonstrate the fundamental concepts.
#
# KEY CONCEPTS:
# 1. Environments as association lists (alist)
# 2. Lexical scoping through environment chaining
# 3. Variable shadowing
# 4. How interpreters manage variable bindings

require_relative 'reader'

# ===== ENVIRONMENT CLASS =====
# An environment stores variable bindings and has an optional parent.
# This creates a chain of environments for lexical scoping.
#
# Visual representation of environment chain:
#   Current Env         Parent Env          Global Env
#   [x -> 10]   --->   [y -> 20]   --->   [+ -> builtin]
#   [y -> 30]          [z -> 5]           [- -> builtin]
#
# When looking up 'y', we find 30 (shadowing parent's y=20)
# When looking up 'z', we search up to parent and find 5
# When looking up '+', we search up to global and find builtin

class Env
  attr_reader :outer  # Parent environment for scope chain
  
  def initialize(outer = nil, binds = nil, exprs = nil)
    @outer = outer    # Parent environment (for lexical scoping)
    @data = nil       # Association list of (key . value) pairs
    
    # Handle function parameter binding
    # binds = parameter names, exprs = argument values
    if binds && exprs
      bind_params(binds, exprs)
    end
  end
  
  # SET: Add or update a binding in this environment
  # 
  # IMPORTANT: We add to the front of the list, so newer
  # bindings shadow older ones. This is how we implement
  # variable shadowing!
  #
  # Example:
  #   env.set("x", 10)  # data = ((x . 10))
  #   env.set("y", 20)  # data = ((y . 20) (x . 10))
  #   env.set("x", 30)  # data = ((x . 30) (y . 20) (x . 10))
  #                      # Note: first x shadows the second!
  def set(key, value)
    # Add new binding to front of list
    @data = cons(cons(key, value), @data)
    value  # Return the value (like assignment expressions do)
  end
  
  # FIND: Search for a binding in the environment chain
  # Returns the environment containing the binding, or nil
  #
  # This demonstrates the lookup algorithm:
  # 1. Search current environment
  # 2. If not found, search parent
  # 3. Continue until found or no more parents
  def find(key)
    # Look in current environment first
    if find_in_pairs(@data, key)
      self  # Found in this environment
    elsif @outer
      @outer.find(key)  # Recursively search parent
    else
      nil  # Not found anywhere
    end
  end
  
  # GET: Retrieve a value from the environment chain
  # Raises error if variable is undefined
  def get(key)
    env = find(key)
    if env
      # Extract value from the association list
      pair = find_in_pairs(env.instance_variable_get(:@data), key)
      cdr(pair)  # The value is the cdr of (key . value)
    else
      raise "'#{key}' not found"  # Undefined variable error
    end
  end
  
  private
  
  # Search for a key in an association list
  # Returns the (key . value) pair if found, nil otherwise
  #
  # Association list structure:
  #   ((key1 . val1) (key2 . val2) (key3 . val3) ...)
  def find_in_pairs(pairs, key)
    current = pairs
    
    while !null?(current)
      pair = car(current)  # Get (key . value) pair
      
      # Check if this pair has our key
      if car(pair) == key
        return pair  # Found it!
      end
      
      current = cdr(current)  # Move to next pair
    end
    
    nil  # Not found
  end
  
  # Bind function parameters to arguments
  # Used when calling functions to create new scope
  #
  # Example:
  #   Function: (fn* (x y) (+ x y))
  #   Call: (f 10 20)
  #   This binds x->10, y->20 in new environment
  def bind_params(params, args)
    # Walk through parameters and arguments in parallel
    while !null?(params)
      if null?(args)
        raise "Not enough arguments"  # More params than args
      end
      
      param = car(params)
      arg = car(args)
      
      # Handle variadic functions with & rest parameter
      if symbol?(param) && param.name == "&"
        # Next param gets all remaining args as a list
        if null?(cdr(params))
          raise "& requires a parameter name"
        end
        
        rest_param = car(cdr(params))
        set(rest_param.name, args)  # Bind remaining args
        return  # Done binding
      end
      
      # Normal parameter binding
      if symbol?(param)
        set(param.name, arg)
      else
        raise "Parameter must be a symbol, got #{param.class}"
      end
      
      # Move to next param/arg pair
      params = cdr(params)
      args = cdr(args)
    end
    
    # Check for too many arguments
    if !null?(args)
      raise "Too many arguments"
    end
  end
end

# ===== PEDAGOGICAL EXERCISES =====
#
# 1. TRACE VARIABLE LOOKUP:
#    Given: (let* (x 10) (let* (x 20 y 30) (+ x y)))
#    Trace how x and y are resolved in the inner expression.
#
# 2. IMPLEMENT DYNAMIC SCOPE:
#    Current implementation is lexical. How would you change
#    it to use dynamic scoping instead?
#
# 3. ADD SET! (MUTATION):
#    Currently we can only add new bindings. How would you
#    implement set! to modify existing bindings?
#
# 4. OPTIMIZE LOOKUP:
#    Current lookup is O(n). How could you improve performance
#    while still using only cons cells?
#
# 5. GARBAGE COLLECTION:
#    How would you identify which bindings are no longer needed?