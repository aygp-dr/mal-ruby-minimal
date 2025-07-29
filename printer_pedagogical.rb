# Printer module for MAL - Converting AST back to strings
#
# PEDAGOGICAL NOTE: The printer is the inverse of the reader.
# Where the reader converts strings to AST, the printer converts
# AST back to strings. This symmetry is fundamental to Lisp.
#
# Key insight: We can represent any data structure as text and
# parse it back perfectly. This is the essence of homoiconicity.

require_relative 'reader'

# Main printing function - converts any MAL value to a string
# 
# The print_readably parameter controls whether we produce
# output that can be read back by the reader (true) or 
# human-friendly output (false)
def pr_str(obj, print_readably = true)
  if null?(obj)
    # nil prints as the symbol nil
    "nil"
  elsif obj == true
    # Boolean true
    "true"
  elsif obj == false
    # Boolean false
    "false"
  elsif obj.is_a?(Integer)
    # Numbers print as themselves
    obj.to_s
  elsif obj.is_a?(String)
    # Strings need special handling
    if print_readably
      # For readable output, wrap in quotes and escape special chars
      '"' + escape_string(obj) + '"'
    else
      # For human output, just print the string contents
      obj
    end
  elsif symbol?(obj)
    # Symbols print as their name
    obj.name
  elsif keyword?(obj)
    # Keywords print with their : prefix
    obj.name
  elsif pair?(obj)
    # Lists print with parentheses
    "(" + pr_list(obj, print_readably) + ")"
  elsif vector?(obj)
    # Vectors print with square brackets
    "[" + pr_list(obj.elements, print_readably) + "]"
  elsif hash_map?(obj)
    # Hash-maps print with curly braces
    "{" + pr_hash_map(obj.pairs, print_readably) + "}"
  elsif obj.respond_to?(:mal_fn?) && obj.mal_fn?
    # User-defined functions
    "#<function>"
  elsif obj.is_a?(String) && obj.start_with?("builtin:")
    # Built-in functions
    "#<builtin:#{obj.sub('builtin:', '')}>"
  else
    # Fallback for unknown types
    obj.to_s
  end
end

# Print a list (or vector elements)
# PEDAGOGICAL NOTE: This is a recursive function that walks
# the cons cell chain. Each recursive call handles one element.
def pr_list(lst, print_readably)
  if null?(lst)
    # Base case: empty list
    ""
  elsif null?(cdr(lst))
    # Base case: single element
    pr_str(car(lst), print_readably)
  else
    # Recursive case: print first element, space, then rest
    pr_str(car(lst), print_readably) + " " + pr_list(cdr(lst), print_readably)
  end
end

# Print hash-map pairs
# PEDAGOGICAL NOTE: Hash-maps are stored as lists of pairs,
# where each pair is (key . value). We print them as "key value".
def pr_hash_map(pairs, print_readably)
  if null?(pairs)
    # Base case: no more pairs
    ""
  else
    # Get the key-value pair
    pair = car(pairs)
    key_str = pr_str(car(pair), print_readably)
    val_str = pr_str(cdr(pair), print_readably)
    
    # Format as "key value"
    result = key_str + " " + val_str
    
    # Add remaining pairs
    if !null?(cdr(pairs))
      result + " " + pr_hash_map(cdr(pairs), print_readably)
    else
      result
    end
  end
end

# Escape special characters in strings
# PEDAGOGICAL NOTE: This ensures that printed strings can be
# read back correctly. It's the inverse of process_string_escapes
# in the reader.
def escape_string(str)
  result = ""
  i = 0
  
  # Process each character
  while i < str.length
    char = str.slice(i, 1)
    
    # Escape special characters
    case char
    when "\n" then result += "\\n"   # Newline → \n
    when "\t" then result += "\\t"   # Tab → \t
    when "\r" then result += "\\r"   # Return → \r
    when "\\" then result += "\\\\"  # Backslash → \\
    when '"' then result += '\\"'    # Quote → \"
    else 
      # Regular character - include as-is
      result += char
    end
    
    i += 1
  end
  
  result
end

# ===== DEBUGGING HELPERS =====
# These functions help visualize data structures

# Print a cons cell diagram
# Example: (1 2 3) prints as:
# [1|•]-->[2|•]-->[3|nil]
def pr_cons_diagram(lst)
  if null?(lst)
    "nil"
  elsif !pair?(lst)
    lst.to_s
  else
    result = ""
    current = lst
    
    while pair?(current)
      result += "[#{pr_str(car(current), false)}|"
      
      if null?(cdr(current))
        result += "nil]"
      elsif pair?(cdr(current))
        result += "•]-->"
      else
        # Improper list (rare in our implementation)
        result += "#{pr_str(cdr(current), false)}]"
      end
      
      current = cdr(current)
    end
    
    result
  end
end

# Print environment for debugging
def pr_env(env, indent = 0)
  return "nil" if env.nil?
  
  spaces = "  " * indent
  result = "#{spaces}Environment:\n"
  
  # Print bindings in this environment
  if env.respond_to?(:data)
    bindings = env.data
    while !null?(bindings)
      binding = car(bindings)
      key = car(binding)
      val = cdr(binding)
      result += "#{spaces}  #{key} = #{pr_str(val, false)}\n"
      bindings = cdr(bindings)
    end
  end
  
  # Print outer environment
  if env.respond_to?(:outer) && env.outer
    result += "#{spaces}Outer:\n"
    result += pr_env(env.outer, indent + 1)
  end
  
  result
end