# Printer module for MAL - converting AST back to strings
# Following SICP's approach to symbolic expression printing

require_relative 'reader'

def pr_str(obj, print_readably = true)
  if null?(obj)
    "nil"
  elsif obj == true
    "true"
  elsif obj == false
    "false"
  elsif obj.is_a?(Integer)
    obj.to_s
  elsif obj.is_a?(String)
    if print_readably
      '"' + escape_string(obj) + '"'
    else
      obj
    end
  elsif symbol?(obj)
    obj.name
  elsif keyword?(obj)
    obj.name
  elsif pair?(obj)
    "(" + pr_list(obj, print_readably) + ")"
  elsif vector?(obj)
    "[" + pr_list(obj.elements, print_readably) + "]"
  elsif hash_map?(obj)
    "{" + pr_hash_map(obj.pairs, print_readably) + "}"
  else
    obj.to_s
  end
end

def pr_list(lst, print_readably)
  if null?(lst)
    ""
  elsif null?(cdr(lst))
    pr_str(car(lst), print_readably)
  else
    pr_str(car(lst), print_readably) + " " + pr_list(cdr(lst), print_readably)
  end
end

def pr_hash_map(pairs, print_readably)
  if null?(pairs)
    ""
  else
    pair = car(pairs)
    key_str = pr_str(car(pair), print_readably)
    val_str = pr_str(cdr(pair), print_readably)
    result = key_str + " " + val_str
    
    if !null?(cdr(pairs))
      result + " " + pr_hash_map(cdr(pairs), print_readably)
    else
      result
    end
  end
end

def escape_string(str)
  result = ""
  i = 0
  while i < str.length
    char = str.slice(i, 1)
    case char
    when "\n" then result += "\\n"
    when "\t" then result += "\\t"
    when "\r" then result += "\\r"
    when "\\" then result += "\\\\"
    when '"' then result += '\\"'
    else result += char
    end
    i += 1
  end
  result
end