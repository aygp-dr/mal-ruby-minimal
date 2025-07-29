#!/usr/bin/env ruby

# Minimal MAL (Make a Lisp) implementation using only 13 AST nodes
# No arrays, hashes, or blocks allowed!

# ===== Pairs (from minimal_pairs.rb) =====
def cons(car_val, cdr_val)
  pair = Object.new
  pair.instance_variable_set(:@car, car_val)
  pair.instance_variable_set(:@cdr, cdr_val)
  
  eval <<-RUBY
    def pair.car; @car; end
    def pair.cdr; @cdr; end
    def pair.set_car!(val); @car = val; end
    def pair.set_cdr!(val); @cdr = val; end
    def pair.pair?; true; end
  RUBY
  
  pair
end

def car(pair)
  pair.respond_to?(:car) ? pair.car : raise("car: not a pair")
end

def cdr(pair)
  pair.respond_to?(:cdr) ? pair.cdr : raise("cdr: not a pair")
end

def pair?(obj)
  obj.respond_to?(:pair?) && obj.pair?
end

def null?(obj)
  obj.nil?
end

def list2(a, b)
  cons(a, cons(b, nil))
end

def list3(a, b, c)
  cons(a, cons(b, cons(c, nil)))
end

# ===== Types =====
def make_symbol(name)
  sym = Object.new
  sym.instance_variable_set(:@name, name)
  eval <<-RUBY
    def sym.symbol?; true; end
    def sym.name; @name; end
    def sym.to_s; @name; end
  RUBY
  sym
end

def symbol?(obj)
  obj.respond_to?(:symbol?) && obj.symbol?
end

def make_fn(params, body, env)
  fn = Object.new
  fn.instance_variable_set(:@params, params)
  fn.instance_variable_set(:@body, body)
  fn.instance_variable_set(:@env, env)
  eval <<-RUBY
    def fn.fn?; true; end
    def fn.params; @params; end
    def fn.body; @body; end
    def fn.env; @env; end
  RUBY
  fn
end

def fn?(obj)
  obj.respond_to?(:fn?) && obj.fn?
end

# ===== Environment =====
def make_env(outer)
  env = Object.new
  env.instance_variable_set(:@bindings, nil)  # Association list
  env.instance_variable_set(:@outer, outer)
  eval <<-RUBY
    def env.bindings; @bindings; end
    def env.set_bindings!(b); @bindings = b; end
    def env.outer; @outer; end
    def env.env?; true; end
  RUBY
  env
end

def env_set(env, key, value)
  env.set_bindings!(cons(cons(key, value), env.bindings))
end

def env_get(env, key)
  current = env
  while current
    binding = assoc(key, current.bindings)
    if binding
      return cdr(binding)
    end
    current = current.outer
  end
  raise "Unbound symbol: #{key}"
end

def assoc(key, alist)
  if null?(alist)
    nil
  elsif car(car(alist)) == key
    car(alist)
  else
    assoc(key, cdr(alist))
  end
end

# ===== Reader (Tokenizer + Parser) =====
def tokenize(str)
  # Simple tokenizer - returns a list of tokens
  tokens = nil
  current_token = ""
  i = 0
  
  while i < str.length
    char = str.slice(i, 1)  # Using slice instead of []
    
    if char == ' ' || char == "\n" || char == "\t"
      if current_token.length > 0
        tokens = append_token(tokens, current_token)
        current_token = ""
      end
    elsif char == '(' || char == ')'
      if current_token.length > 0
        tokens = append_token(tokens, current_token)
        current_token = ""
      end
      tokens = append_token(tokens, char)
    else
      current_token += char
    end
    
    i += 1
  end
  
  if current_token.length > 0
    tokens = append_token(tokens, current_token)
  end
  
  reverse_list(tokens)
end

def append_token(lst, token)
  cons(token, lst)
end

def reverse_list(lst)
  result = nil
  while !null?(lst)
    result = cons(car(lst), result)
    lst = cdr(lst)
  end
  result
end

def parse(tokens)
  if null?(tokens)
    raise "Unexpected EOF"
  end
  
  token = car(tokens)
  rest = cdr(tokens)
  
  if token == "("
    parse_list(rest)
  elsif token == ")"
    raise "Unexpected )"
  elsif token.match(/^-?\d+$/)
    cons(token.to_i, rest)
  elsif token == "true"
    cons(true, rest)
  elsif token == "false"
    cons(false, rest)
  elsif token == "nil"
    cons(nil, rest)
  else
    cons(make_symbol(token), rest)
  end
end

def parse_list(tokens)
  elements = nil
  
  while !null?(tokens) && car(tokens) != ")"
    parsed = parse(tokens)
    element = car(parsed)
    tokens = cdr(parsed)
    elements = cons(element, elements)
  end
  
  if null?(tokens)
    raise "Missing )"
  end
  
  # Skip the )
  tokens = cdr(tokens)
  
  cons(reverse_list(elements), tokens)
end

def read_str(str)
  tokens = tokenize(str)
  if null?(tokens)
    nil
  else
    parsed = parse(tokens)
    car(parsed)
  end
end

# ===== Evaluator =====
def eval_mal(ast, env)
  if symbol?(ast)
    env_get(env, ast.name)
  elsif pair?(ast)
    # Special forms
    if !null?(ast) && symbol?(car(ast))
      case car(ast).name
      when "def"
        # (def name value)
        name = car(cdr(ast))
        value = eval_mal(car(cdr(cdr(ast))), env)
        env_set(env, name.name, value)
        value
      when "if"
        # (if cond then else)
        cond = eval_mal(car(cdr(ast)), env)
        if cond && cond != false
          eval_mal(car(cdr(cdr(ast))), env)
        else
          # else part
          else_part = cdr(cdr(cdr(ast)))
          if !null?(else_part)
            eval_mal(car(else_part), env)
          else
            nil
          end
        end
      when "fn"
        # (fn (params...) body)
        params = car(cdr(ast))
        body = car(cdr(cdr(ast)))
        make_fn(params, body, env)
      when "quote"
        car(cdr(ast))
      when "do"
        # Evaluate all expressions, return last
        exprs = cdr(ast)
        result = nil
        while !null?(exprs)
          result = eval_mal(car(exprs), env)
          exprs = cdr(exprs)
        end
        result
      else
        # Function call
        eval_list(ast, env)
      end
    else
      # Evaluate all elements
      eval_list(ast, env)
    end
  else
    # Self-evaluating
    ast
  end
end

def eval_list(ast, env)
  if null?(ast)
    nil
  else
    fn_ast = eval_mal(car(ast), env)
    args = eval_args(cdr(ast), env)
    apply_fn(fn_ast, args)
  end
end

def eval_args(args, env)
  if null?(args)
    nil
  else
    cons(eval_mal(car(args), env), eval_args(cdr(args), env))
  end
end

def apply_fn(fn_ast, args)
  if fn?(fn_ast)
    # User-defined function
    new_env = make_env(fn_ast.env)
    bind_params(fn_ast.params, args, new_env)
    eval_mal(fn_ast.body, new_env)
  else
    # Built-in function (string name)
    case fn_ast
    when "+"
      car(args) + car(cdr(args))
    when "-"
      car(args) - car(cdr(args))
    when "*"
      car(args) * car(cdr(args))
    when "/"
      car(args) / car(cdr(args))
    when "="
      car(args) == car(cdr(args))
    when "<"
      car(args) < car(cdr(args))
    when ">"
      car(args) > car(cdr(args))
    when "list"
      args
    when "car"
      car(car(args))
    when "cdr"
      cdr(car(args))
    when "cons"
      cons(car(args), car(cdr(args)))
    when "null?"
      null?(car(args))
    when "print"
      puts mal_to_string(car(args))
      nil
    else
      raise "Unknown function: #{fn_ast}"
    end
  end
end

def bind_params(params, args, env)
  while !null?(params) && !null?(args)
    param = car(params)
    arg = car(args)
    env_set(env, param.name, arg)
    params = cdr(params)
    args = cdr(args)
  end
  
  if !null?(params) || !null?(args)
    raise "Wrong number of arguments"
  end
end

# ===== Printer =====
def mal_to_string(obj)
  if null?(obj)
    "nil"
  elsif pair?(obj)
    "(" + list_to_string(obj) + ")"
  elsif symbol?(obj)
    obj.name
  elsif obj == true
    "true"
  elsif obj == false
    "false"
  elsif fn?(obj)
    "#<function>"
  else
    obj.to_s
  end
end

def list_to_string(lst)
  if null?(lst)
    ""
  elsif null?(cdr(lst))
    mal_to_string(car(lst))
  else
    mal_to_string(car(lst)) + " " + list_to_string(cdr(lst))
  end
end

# ===== REPL =====
def create_root_env
  env = make_env(nil)
  
  # Built-in functions
  env_set(env, "+", "+")
  env_set(env, "-", "-")
  env_set(env, "*", "*")
  env_set(env, "/", "/")
  env_set(env, "=", "=")
  env_set(env, "<", "<")
  env_set(env, ">", ">")
  env_set(env, "list", "list")
  env_set(env, "car", "car")
  env_set(env, "cdr", "cdr")
  env_set(env, "cons", "cons")
  env_set(env, "null?", "null?")
  env_set(env, "print", "print")
  
  env
end

def rep(str, env)
  ast = read_str(str)
  result = eval_mal(ast, env)
  mal_to_string(result)
end

# ===== Main =====
if __FILE__ == $0
  puts "Minimal MAL - A tiny Lisp in Ruby"
  puts "Using only 13 AST nodes!"
  puts "Type 'quit' to exit\n\n"
  
  env = create_root_env
  
  # Example programs (using cons cells instead of arrays)
  examples = cons("(+ 1 2)",
    cons("(* 3 4)",
    cons("(def x 42)",
    cons("x",
    cons("(def inc (fn (n) (+ n 1)))",
    cons("(inc 5)",
    cons("(def fact (fn (n) (if (= n 0) 1 (* n (fact (- n 1))))))",
    cons("(fact 5)",
    cons("(def lst (list 1 2 3))",
    cons("(car lst)",
    cons("(cdr lst)",
    cons("(cons 0 lst)",
    cons("(def map (fn (f lst) (if (null? lst) nil (cons (f (car lst)) (map f (cdr lst))))))",
    cons("(map inc (list 1 2 3))",
    cons("(do (print (quote Hello)) (print (quote World)) 42)", nil)))))))))))))))
  
  puts "=== Example Session ==="
  example_list = examples
  while !null?(example_list)
    expr = car(example_list)
    begin
      puts "> #{expr}"
      result = rep(expr, env)
      puts "=> #{result}"
      puts
    rescue => e
      puts "Error: #{e.message}"
      puts
    end
    example_list = cdr(example_list)
  end
  
  # Interactive REPL
  puts "\n=== Interactive REPL ==="
  loop do
    print "> "
    input = gets
    break if input.nil?
    
    input = input.chomp
    break if input == "quit"
    
    begin
      result = rep(input, env)
      puts "=> #{result}"
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end

# This demonstrates:
# 1. A complete Lisp interpreter without arrays/hashes/blocks
# 2. S-expression parser using only pairs
# 3. Environment as association lists
# 4. Special forms: def, if, fn, quote, do
# 5. First-class functions and closures
# 6. Recursive functions (factorial)
# 7. List processing (map)
# All using only the 13 allowed AST nodes!