# Evaluation Walkthrough: How MAL Processes Code

## Overview

This document traces through exactly how MAL evaluates expressions, from input string to final result. We'll use concrete examples to show each step.

## Example 1: Simple Arithmetic `(+ 1 2)`

### Step 1: Reading (Parsing)

```
Input: "(+ 1 2)"
```

#### Tokenization
```ruby
tokenize("(+ 1 2)")
# Produces tokens: ["(", "+", "1", "2", ")"]
# As cons cells: ("(" . ("+" . ("1" . ("2" . (")" . nil)))))
```

#### Parsing
```ruby
read_str("(+ 1 2)")
# Calls read_form which sees "(" and calls read_list
# read_list collects: + 1 2
# Produces AST: (+ . (1 . (2 . nil)))
```

The AST is a list where:
- First element: symbol "+"
- Second element: number 1
- Third element: number 2

### Step 2: Evaluation

```ruby
EVAL(ast, env)
# ast = (+ 1 2)
# env = global environment with + bound to builtin
```

1. **Check if list**: Yes, it's a list
2. **Check special form**: First element is "+", not a special form
3. **Evaluate the list**:
   ```ruby
   eval_ast(ast, env)
   # Evaluates each element:
   # + -> builtin "+" function
   # 1 -> 1 (numbers evaluate to themselves)
   # 2 -> 2
   # Returns: (<builtin +> 1 2)
   ```
4. **Apply function**:
   ```ruby
   apply_builtin("+", (1 2))
   # Extracts arguments: a=1, b=2
   # Returns: 1 + 2 = 3
   ```

### Step 3: Printing

```ruby
pr_str(3, true)
# Returns: "3"
```

**Final output**: `3`

## Example 2: Variable Definition `(def! x 10)`

### Step 1: Reading

```
Input: "(def! x 10)"
Tokens: ["(", "def!", "x", "10", ")"]
AST: (def! x 10)
```

### Step 2: Evaluation

```ruby
EVAL((def! x 10), env)
```

1. **Check if list**: Yes
2. **Check special form**: `def!` IS a special form!
3. **Handle def! special form**:
   ```ruby
   # Extract parts:
   # symbol = x
   # value_expr = 10
   
   # Evaluate the value expression:
   value = EVAL(10, env)  # Returns 10
   
   # Set in environment:
   env.set("x", 10)
   
   # Return the value:
   return 10
   ```

**Key insight**: `def!` doesn't evaluate the symbol `x`, only the value `10`.

## Example 3: Function Definition and Call

### Define: `(def! inc (fn* (n) (+ n 1)))`

```ruby
EVAL((def! inc (fn* (n) (+ n 1))), env)
```

1. **Special form**: `def!`
2. **Evaluate value**: `(fn* (n) (+ n 1))`
   - **Special form**: `fn*`
   - **Create MAL function**:
     ```ruby
     make_mal_fn(
       params: (n),
       body: (+ n 1),
       closure_env: current_env
     )
     ```
3. **Bind to inc**: `env.set("inc", <mal_function>)`

### Call: `(inc 5)`

```ruby
EVAL((inc 5), env)
```

1. **Not a special form**
2. **Evaluate list**:
   - `inc` -> `<mal_function>`
   - `5` -> `5`
3. **Apply function**:
   ```ruby
   # It's a MAL function, so:
   # 1. Create new environment
   new_env = Env.new(function.closure_env)
   
   # 2. Bind parameters
   new_env.set("n", 5)
   
   # 3. Evaluate body in new environment
   EVAL((+ n 1), new_env)
   # n -> 5
   # (+ 5 1) -> 6
   ```

**Result**: `6`

## Example 4: Let Binding `(let* (x 10 y 20) (+ x y))`

### Parsing

```
AST: (let* (x 10 y 20) (+ x y))
     ^      ^bindings^  ^body^
```

### Evaluation

1. **Special form**: `let*`
2. **Create new environment**:
   ```ruby
   let_env = Env.new(current_env)
   ```
3. **Process bindings**:
   ```ruby
   # x = 10
   value = EVAL(10, let_env)  # 10
   let_env.set("x", 10)
   
   # y = 20
   value = EVAL(20, let_env)  # 20
   let_env.set("y", 20)
   ```
4. **Evaluate body**:
   ```ruby
   EVAL((+ x y), let_env)
   # x -> 10 (from let_env)
   # y -> 20 (from let_env)
   # Result: 30
   ```

## Example 5: Tail Call Optimization

### Recursive sum without TCO (would stack overflow):

```lisp
(def! sum-bad (fn* (n acc)
  (if (= n 0)
    acc
    (sum-bad (- n 1) (+ n acc)))))
```

### How TCO works:

```ruby
def EVAL(ast, env)
  loop do  # <-- The key: loop instead of recursion
    # ... evaluate ...
    
    if tail_position?
      # Don't recurse! Update ast/env and continue loop
      ast = new_ast
      env = new_env
      # Loop continues with new values
    else
      # Not in tail position, must recurse
      return EVAL(new_ast, new_env)
    end
  end
end
```

For `(sum-bad 10000 0)`:
- Instead of 10000 recursive calls
- We update ast/env 10000 times in a loop
- No stack growth!

## Visual Trace: `(let* (x 5) (+ x 3))`

```
1. READ: "(let* (x 5) (+ x 3))"
   └─> AST: (let* (x 5) (+ x 3))

2. EVAL: Check special forms
   └─> Found: let*

3. SPECIAL FORM let*:
   ├─> Create new environment
   │   └─> let_env = Env.new(global_env)
   ├─> Process bindings: (x 5)
   │   ├─> Evaluate 5 -> 5
   │   └─> let_env.set("x", 5)
   └─> Evaluate body with let_env

4. EVAL: (+ x 3) in let_env
   ├─> Not special form, evaluate list
   ├─> Evaluate +: lookup in env chain -> builtin
   ├─> Evaluate x: lookup in let_env -> 5
   ├─> Evaluate 3: self-evaluating -> 3
   └─> Apply: (+ 5 3) -> 8

5. PRINT: 8 -> "8"

Result: 8
```

## Key Insights

1. **Special forms control evaluation**: They decide what gets evaluated and when
2. **Environments chain**: Each scope has its own environment linked to parent
3. **Functions capture environments**: Closures remember where they were defined
4. **TCO is essential**: Without it, recursive functions blow the stack
5. **Everything is recursive**: From list processing to evaluation itself

## Exercises

1. **Trace this**: `(let* (x 10) (let* (x 20) x))`
   - What value is returned?
   - How many environments are created?

2. **Explain why this works**: `(def! x 10) (let* (x 20) (def! y x)) y`
   - What is the value of y?
   - Which x does y get?

3. **Trace a function call**: `(def! add (fn* (a b) (+ a b))) (add 3 4)`
   - Show each environment
   - Show parameter binding

4. **Find the bug**: Why doesn't this work?
   ```lisp
   (def! f (fn* (x) (+ x y)))
   (def! y 10)
   (f 5)
   ```