# MAL Ruby Minimal - Student Exercises

## Level 1: Understanding Cons Cells

### Exercise 1.1: Basic List Construction
Without running the code, predict what these expressions create:

```ruby
a = cons(1, cons(2, nil))
b = cons(3, a)
c = cons(a, cons(b, nil))
```

Draw the cons cell diagrams for a, b, and c.

### Exercise 1.2: List Operations
Implement these functions using only cons, car, cdr:

```ruby
# Return the second element of a list
def second(lst)
  # Your code here
end

# Return the last element of a list
def last(lst)
  # Your code here
end

# Append element to end of list (hint: rebuild the list)
def append_element(lst, elem)
  # Your code here
end
```

### Exercise 1.3: List Predicates
Implement these without using Ruby arrays:

```ruby
# Check if list has exactly one element
def singleton?(lst)
  # Your code here
end

# Check if two lists have same length
def same_length?(lst1, lst2)
  # Your code here
end
```

## Level 2: Understanding Environments

### Exercise 2.1: Environment Lookup
Trace through this code and predict the output:

```lisp
(def! x 10)
(def! y 20)
(let* (x 30 z 40) 
  (let* (y 50) 
    (list x y z)))
```

Draw the environment chain at each step.

### Exercise 2.2: Implement set!
The current implementation only has `def!` which adds new bindings. Implement `set!` which modifies existing bindings:

```ruby
# In eval, add a new special form:
when "set!"
  # set! should find existing binding and update it
  # If binding doesn't exist, raise error
```

### Exercise 2.3: Dynamic Scope
Our implementation uses lexical scope. Research dynamic scope and modify the evaluator to use it instead. What changes?

## Level 3: Parser Enhancements

### Exercise 3.1: Comments
Extend the tokenizer to handle multi-line comments:

```lisp
#| This is a
   multi-line
   comment |#
(+ 1 2)  ; This still works
```

### Exercise 3.2: Dotted Pairs
Add support for dotted pair notation:

```lisp
(1 . 2)        ; A pair, not a list
(1 2 . 3)      ; Improper list
```

### Exercise 3.3: Character Literals
Add character literals to the language:

```lisp
\a        ; Character 'a'
\space    ; Space character
\newline  ; Newline character
```

## Level 4: Evaluator Enhancements

### Exercise 4.1: Cond Special Form
Implement `cond` which is like a multi-way if:

```lisp
(cond
  ((> x 10) "big")
  ((> x 5)  "medium")
  ((> x 0)  "small")
  (else     "tiny"))
```

### Exercise 4.2: Local Functions
Implement `flet` for local function definitions:

```lisp
(flet ((double (x) (* x 2))
       (triple (x) (* x 3)))
  (+ (double 5) (triple 7)))
```

### Exercise 4.3: Apply Function
Implement `apply` which applies a function to a list of arguments:

```lisp
(apply + (list 1 2 3 4))  ; => 10
```

## Level 5: Advanced Concepts

### Exercise 5.1: Continuations
Research continuations and implement `call/cc`:

```lisp
(call/cc (fn* (k) 
  (+ 1 (k 42))))  ; => 42
```

### Exercise 5.2: Lazy Evaluation
Implement `delay` and `force` for lazy evaluation:

```lisp
(def! x (delay (println "evaluated!")))
(force x)  ; Prints "evaluated!" and returns value
(force x)  ; Returns cached value without printing
```

### Exercise 5.3: Pattern Matching
Add pattern matching to function definitions:

```lisp
(defn factorial
  (0 1)
  (n (* n (factorial (- n 1)))))
```

## Level 6: Optimization Challenges

### Exercise 6.1: Constant Folding
Optimize the evaluator to compute constant expressions at parse time:

```lisp
(+ 1 2)  ; Should be replaced with 3 during parsing
```

### Exercise 6.2: Environment Optimization
The current O(n) lookup is slow. Design and implement a better approach while still using only cons cells.

### Exercise 6.3: Tail Call Optimization for Mutual Recursion
Extend TCO to handle mutual recursion:

```lisp
(def! even? (fn* (n) 
  (if (= n 0) true (odd? (- n 1)))))
(def! odd? (fn* (n) 
  (if (= n 0) false (even? (- n 1)))))
```

## Level 7: Project Ideas

### Project 1: Debugger
Add debugging support:
- Breakpoints
- Step through evaluation
- Inspect environments
- Call stack trace

### Project 2: Type System
Add optional type annotations:

```lisp
(def! add (fn* ((a :number) (b :number)) :number
  (+ a b)))
```

### Project 3: Module System
Implement modules/namespaces:

```lisp
(module math
  (export add subtract multiply)
  (def! add ...))
  
(import math)
(math/add 1 2)
```

### Project 4: Compiler
Instead of interpreting, compile to:
- Ruby code
- JavaScript
- LLVM IR
- Your own bytecode

## Solutions Guide

### Exercise 1.1 Solution Hints
- `a` is the list (1 2)
- `b` is the list (3 1 2)
- `c` is the list ((1 2) (3 1 2))

### Exercise 1.2 Solution Structure
```ruby
def second(lst)
  if null?(lst) || null?(cdr(lst))
    nil
  else
    car(cdr(lst))
  end
end
```

### Key Concepts to Remember
1. Everything is built from cons cells
2. Lists are recursive structures
3. Environments chain for scoping
4. Special forms control evaluation
5. Functions are first-class values
6. TCO prevents stack overflow

## Assessment Rubric

- **Level 1-2**: Understanding fundamentals
- **Level 3-4**: Extending the language
- **Level 5-6**: Advanced concepts
- **Level 7**: Independent research

Work through levels sequentially. Each level builds on previous knowledge.