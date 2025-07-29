# Environment module for MAL
# Uses association lists (cons cells) for bindings

require_relative 'reader'

class Env
  attr_reader :data, :outer
  
  def initialize(outer = nil)
    @data = nil  # Association list of bindings
    @outer = outer
  end
  
  def set(key, value)
    # Add new binding to front of association list
    @data = cons(cons(key, value), @data)
    value
  end
  
  def find(key)
    # Search current environment
    binding = assoc(key, @data)
    if binding
      self
    elsif @outer
      @outer.find(key)
    else
      nil
    end
  end
  
  def get(key)
    env = find(key)
    if env
      binding = assoc(key, env.data)
      cdr(binding)
    else
      raise "Unknown symbol: #{key}"
    end
  end
  
  private
  
  def assoc(key, alist)
    return nil if null?(alist)
    
    binding = car(alist)
    if car(binding) == key
      binding
    else
      assoc(key, cdr(alist))
    end
  end
end