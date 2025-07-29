# MAL Ruby Minimal - Intermediate Tutorial Walkthrough

## Understanding the Architecture

Now that you've seen the basics, let's dive deeper into HOW this interpreter works.

## The Reader: Parsing Without Convenience

Open `reader.rb` and let's trace through tokenization:

```ruby
def tokenize(str)
  tokens = nil          # Building list backwards
  current_token = ""    
  i = 0                 
  in_string = false     
  
  while i < str.length
    char = str.slice(i, 1)  # No string indexing!
    # ... state machine logic ...
  end
  
  reverse_list(tokens)  # Built backwards, reverse at end
end
```

### Exercise: Trace Tokenization

Input: `(def! x "hello")`

1. `i=0`: char='(' → token, tokens = `("(" . nil)`
2. `i=1`: char='d' → start building "def!"
3. `i=4`: char='!' → continue building
4. `i=5`: char=' ' → complete token, tokens = `("def!" "(" . nil)`
5. Continue...

Final tokens: `("(" "def!" "x" "\"hello\"" ")")`

### The Parser: Recursive Descent

```ruby
def read_form(reader)
  token = reader.peek
  case token
  when '('
    read_list(reader)
  when "'"
    reader.next  # consume '
    form = read_form(reader)
    list2(make_symbol("quote"), form)
  # ...
  end
end
```

This is classic recursive descent parsing. Each form knows how to read itself.

## The Evaluator: The Heart of Lisp

Let's trace evaluation in detail:

### Example: `(+ 1 (* 2 3))`

```ruby
def EVAL(ast, env)
  loop do  # TCO loop!
    if !list?(ast)
      return eval_ast(ast, env)
    end
    
    # It's a list - check for special forms
    first = car(ast)
    if symbol?(first)
      case first.name
      when "if"
        # Special evaluation rules
      # ...
      else
        # Function call
        evaluated = eval_ast(ast, env)
        f = car(evaluated)
        args = cdr(evaluated)
        # Apply function...
      end
    end
  end
end
```

Trace:
1. AST is list `(+ 1 (* 2 3))`
2. First element is symbol `+`
3. Not a special form, so evaluate all elements:
   - `+` → builtin function
   - `1` → 1
   - `(* 2 3)` → recursive EVAL → 6
4. Apply `+` to `(1 6)` → 7

## Environments: Lexical Scope in Action

The environment is an association list with chaining:

```ruby
class Env
  def initialize(outer = nil)
    @data = nil    # alist: ((x . 10) (y . 20))
    @outer = outer # parent environment
  end
  
  def get(key)
    # Search this env
    binding = assoc(key, @data)
    if binding
      cdr(binding)  # return value
    elsif @outer
      @outer.get(key)  # search parent
    else
      raise "Unknown symbol: #{key}"
    end
  end
end
```

### Exercise: Environment Chains

```lisp
(def! x 10)                    ; Global: ((x . 10))
(let* (x 20 y 30)              ; Let: ((y . 30) (x . 20)) → Global
  (let* (z (+ x y))            ; Inner: ((z . 50)) → Let → Global
    (list x y z)))             ; => (20 30 50)
```

Draw the environment chain at each step!

## Functions: Closures Without Blocks

How do we implement closures without Ruby blocks?

```ruby
def make_mal_fn(params, body, env)
  fn = Object.new
  fn.instance_variable_set(:@params, params)
  fn.instance_variable_set(:@body, body)
  fn.instance_variable_set(:@env, env)  # Captures environment!
  # ...
end
```

### Closure Example

```lisp
(def! make-adder (fn* (x)
  (fn* (y) (+ x y))))
  
(def! add5 (make-adder 5))
(add5 3)  ; => 8
```

Trace:
1. `make-adder` captures global env
2. Call `(make-adder 5)` creates env with `x=5`
3. Inner function captures that env
4. `add5` is the inner function with `x=5` in its closure
5. `(add5 3)` creates new env with `y=3`, parent has `x=5`

## Tail Call Optimization: The Loop Trick

Without TCO:
```ruby
def factorial(n, acc)
  if n == 0
    acc
  else
    factorial(n - 1, n * acc)  # Stack grows!
  end
end
```

With TCO:
```ruby
def EVAL(ast, env)
  loop do
    # ... evaluate ...
    if tail_position?
      ast = new_ast  # Update parameters
      env = new_env
      # Loop continues - no new stack frame!
    else
      return EVAL(new_ast, new_env)
    end
  end
end
```

## Quote and Quasiquote: Code as Data

### Quote: Preventing Evaluation

```lisp
(quote (+ 1 2))  ; => (+ 1 2), not 3
'(a b c)         ; => (a b c)
```

### Quasiquote: Selective Evaluation

```lisp
`(list 1 ~(+ 2 3) 4)      ; => (list 1 5 4)
`(list ~@(list 2 3))      ; => (list 2 3)
```

Implementation:
```ruby
def quasiquote(ast)
  if !pair?(ast)
    # atom - might need quoting
    list2(make_symbol("quote"), ast)
  elsif car(ast) == "unquote"
    # ~expr - evaluate it
    cadr(ast)
  elsif pair?(car(ast)) && caar(ast) == "splice-unquote"
    # ~@expr - splice it
    list3(make_symbol("concat"), cadar(ast), 
          quasiquote(cdr(ast)))
  else
    # recursively process
    list3(make_symbol("cons"), 
          quasiquote(car(ast)),
          quasiquote(cdr(ast)))
  end
end
```

## Macros: Code Transformation

Macros receive unevaluated arguments and return code:

```lisp
(defmacro! unless (fn* (pred a b)
  `(if ~pred ~b ~a)))
  
(macroexpand '(unless false 7 8))  ; => (if false 8 7)
```

The macro expansion loop:
```ruby
def macroexpand(ast, env)
  while is_macro_call?(ast, env)
    macro = env.get(car(ast).name)
    args = cdr(ast)
    ast = apply_macro(macro, args)
  end
  ast
end
```

## Exception Handling: Integration with Ruby

```ruby
class MalException < StandardError
  attr_reader :value
  def initialize(value)
    @value = value  # Can be any MAL value
  end
end

# In EVAL:
when "try*"
  begin
    EVAL(try_expr, env)
  rescue MalException => e
    # Bind e.value to catch symbol
    catch_env = Env.new(env)
    catch_env.set(catch_sym, e.value)
    EVAL(catch_body, catch_env)
  end
```

## Performance Analysis

Why is our implementation slow?

1. **List operations are O(n)**:
   ```ruby
   def nth(lst, n)
     while n > 0
       lst = cdr(lst)  # O(n) to get nth element!
       n -= 1
     end
     car(lst)
   end
   ```

2. **Environment lookup is O(n)**:
   ```ruby
   def assoc(key, alist)
     # Linear search through pairs
   end
   ```

3. **No caching or optimization**:
   - Every symbol lookup walks the chain
   - Every list operation rebuilds structure

## Advanced Exercises

1. **Implement `cond` macro**:
   ```lisp
   (cond
     ((< x 0) "negative")
     ((> x 0) "positive")
     (true "zero"))
   ```

2. **Add memoization to environment**:
   Cache lookups to speed up repeated access.

3. **Implement `loop/recur`**:
   Explicit tail recursion like Clojure.

4. **Profile the interpreter**:
   Where is time actually spent?

## Key Insights

1. **Simplicity reveals complexity** - No hiding behind arrays/hashes
2. **Everything is explicit** - No magic, just cons cells
3. **Trade-offs are visible** - See exactly why things are slow
4. **Patterns emerge** - Recursion everywhere!
5. **Constraints teach** - Limited tools force understanding

## Next Steps

1. Study the macro implementation deeply
2. Try implementing continuations
3. Add a bytecode compiler
4. Port to another language with same constraints