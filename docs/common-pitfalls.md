# Common Pitfalls and How to Avoid Them

## 1. The "Where's My Array?" Syndrome

### Pitfall
```ruby
# Trying to use Ruby arrays
tokens = []
tokens << token  # NO!
```

### Why It Happens
We're so used to arrays that building lists with cons cells feels alien.

### The Right Way
```ruby
# Build list backwards, then reverse
tokens = nil
tokens = cons(token, tokens)
# Later: reverse_list(tokens)
```

### Key Insight
Adding to the front of a cons list is O(1), adding to the end is O(n). That's why we build backwards!

## 2. The "Forgotten nil Check"

### Pitfall
```ruby
def sum_list(lst)
  car(lst) + sum_list(cdr(lst))  # Stack overflow!
end
```

### Why It Happens
Forgetting that lists end with nil, not an empty list object.

### The Right Way
```ruby
def sum_list(lst)
  if null?(lst)
    0
  else
    car(lst) + sum_list(cdr(lst))
  end
end
```

### Key Insight
Always check for nil before calling car/cdr.

## 3. The "Mutating Cons Cells" Mistake

### Pitfall
```ruby
# Trying to modify a list in place
def append!(lst, elem)
  if null?(cdr(lst))
    lst.instance_variable_set(:@cdr, cons(elem, nil))  # NO!
  end
end
```

### Why It Happens
Coming from imperative languages where mutation is normal.

### The Right Way
```ruby
def append(lst, elem)
  if null?(lst)
    cons(elem, nil)
  else
    cons(car(lst), append(cdr(lst), elem))
  end
end
```

### Key Insight
Immutability is a feature! It makes reasoning about code easier.

## 4. The "Special Form Evaluation" Confusion

### Pitfall
```ruby
# Trying to evaluate all arguments
when "if"
  condition = EVAL(cadr(ast), env)
  then_expr = EVAL(caddr(ast), env)   # NO! Too eager
  else_expr = EVAL(cadddr(ast), env)  # NO! Too eager
```

### Why It Happens
Not understanding that special forms control evaluation.

### The Right Way
```ruby
when "if"
  condition = EVAL(cadr(ast), env)
  if truthy?(condition)
    EVAL(caddr(ast), env)      # Only evaluate the branch we need
  else
    EVAL(cadddr(ast), env)
  end
```

### Key Insight
Special forms exist precisely because they need custom evaluation rules.

## 5. The "Environment Lookup" Bug

### Pitfall
```ruby
def find_in_pairs(pairs, key)
  if car(car(pairs)) == key  # Crash if pairs is nil!
    return car(pairs)
  end
  find_in_pairs(cdr(pairs), key)
end
```

### Why It Happens
Forgetting to handle the base case in recursive functions.

### The Right Way
```ruby
def find_in_pairs(pairs, key)
  if null?(pairs)
    nil  # Base case
  elsif car(car(pairs)) == key
    car(pairs)
  else
    find_in_pairs(cdr(pairs), key)
  end
end
```

### Key Insight
Every recursive function needs a base case that stops recursion.

## 6. The "Infinite Loop in TCO"

### Pitfall
```ruby
loop do
  # ... evaluate ...
  ast = new_ast
  env = new_env
  # Forgot to handle non-tail positions!
end
```

### Why It Happens
Not understanding when to loop vs when to return.

### The Right Way
```ruby
loop do
  # ... evaluate ...
  if in_tail_position?
    ast = new_ast
    env = new_env
    # Continue loop
  else
    return EVAL(new_ast, new_env)  # Must return!
  end
end
```

### Key Insight
TCO only applies to tail calls. Other calls must use normal recursion.

## 7. The "Quote vs List" Confusion

### Pitfall
```lisp
(def! x '(1 2 3))     ; x is a list
(def! y (1 2 3))      ; Error! Tries to call 1 as function
(def! z (list 1 2 3)) ; z is a list
```

### Why It Happens
Not understanding the difference between data and code.

### The Right Way
- Use `'(...)` or `(quote ...)` for literal data
- Use `(list ...)` to build lists from evaluated elements
- Unquoted `(...)` is always a function call

### Key Insight
In Lisp, code and data have the same structure, but different evaluation rules.

## 8. The "Scope Chain" Misunderstanding

### Pitfall
```lisp
(def! x 10)
(def! f (fn* () x))    ; Captures x=10
(def! x 20)
(f)  ; Returns 10, not 20!
```

### Why It Happens
Expecting dynamic scope when we have lexical scope.

### The Right Way
Understand that functions capture their definition environment:
```lisp
(def! make-adder (fn* (x) 
  (fn* (y) (+ x y))))  ; Captures x
(def! add5 (make-adder 5))
(add5 3)  ; Returns 8
```

### Key Insight
Lexical scope means functions remember where they were defined.

## 9. The "Tokenizer State Machine" Trap

### Pitfall
```ruby
while i < str.length
  if str[i] == '"'
    # Scan for closing quote
    i += 1
    while str[i] != '"'  # Doesn't handle escapes!
      i += 1
    end
  end
end
```

### Why It Happens
Forgetting edge cases in string parsing.

### The Right Way
```ruby
while i < str.length && str[i] != '"'
  if str[i] == '\\'  # Handle escape
    i += 1  # Skip escaped character
  end
  i += 1
end
```

### Key Insight
Parsing is full of edge cases. Think about: escapes, EOF, malformed input.

## 10. The "Reference vs Value" Mix-up

### Pitfall
```ruby
# Trying to share structure
a = cons(1, cons(2, nil))
b = cons(3, cdr(a))  # b is (3 2), shares tail with a
# If we could mutate, this would be dangerous!
```

### Why It Happens
Thinking about cons cells as mutable containers.

### The Right Way
Embrace immutability:
```ruby
a = cons(1, cons(2, nil))
b = cons(3, cons(2, nil))  # Separate structure
# Or use a helper:
b = cons(3, copy_list(cdr(a)))
```

### Key Insight
Immutability means sharing structure is safe!

## Debugging Tips

### 1. Add Print Statements
```ruby
def EVAL(ast, env)
  puts "EVAL: #{pr_str(ast)}" if $DEBUG
  # ...
end
```

### 2. Check Your Base Cases
Every recursive function needs:
- A condition to stop recursion
- A return value for that condition

### 3. Draw It Out
When confused about list structure, draw the cons cells!

### 4. Test Small
Before testing `(def! fib (fn* (n) ...))`:
- Test `(+ 1 2)`
- Test `(def! x 5)`
- Test `(fn* (x) x)`

### 5. Read Error Messages
```ruby
rescue => e
  puts e.message
  puts e.backtrace.first(5)  # See where it failed
end
```

## Remember

1. **Cons cells are immutable** - build new lists, don't modify
2. **Check for nil** - it's how lists end
3. **Special forms are special** - they control evaluation
4. **Recursion needs base cases** - or you'll overflow
5. **Draw pictures** - visualize those cons cells
6. **Test incrementally** - small steps reveal bugs faster
7. **Embrace the constraints** - they're teaching you fundamentals!