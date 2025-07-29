# MAL Ruby Minimal - Beginner's Tutorial Walkthrough

## Introduction: What Are We Building?

Welcome! We're going to explore a Lisp interpreter built with extreme constraints. Imagine building a car using only a screwdriver - that's what we've done here, but with programming.

## Starting Simple: The REPL

Let's start by running the simplest version:

```bash
$ ruby step0_repl.rb
mal-user> hello
hello
```

This just echoes back what you type. Not very exciting yet!

## Step 1: Reading and Printing

Now let's see how we parse Lisp expressions:

```bash
$ ruby step1_read_print.rb
mal-user> (+ 1 2)
(+ 1 2)
```

Still just echoing, but now it understands parentheses! Let's trace what happens:

1. Input: `(+ 1 2)`
2. Tokenizer breaks it into: `(`, `+`, `1`, `2`, `)`
3. Parser builds a list structure
4. Printer converts back to string

### Key Learning: Cons Cells

Look at how lists are built in `reader.rb`:

```ruby
def cons(car_val, cdr_val)
  pair = Object.new
  pair.instance_variable_set(:@car, car_val)
  pair.instance_variable_set(:@cdr, cdr_val)
  # ...
end
```

A cons cell is just a pair! The list `(+ 1 2)` is actually:
```
[+|•]-->[1|•]-->[2|nil]
```

## Step 2: Basic Evaluation

```bash
$ ruby step2_eval.rb
mal-user> (+ 1 2)
3
```

Finally, math works! Let's trace the evaluation:

1. See it's a list starting with `+`
2. Look up `+` (it's a built-in function)
3. Evaluate the arguments: `1` → 1, `2` → 2
4. Apply `+` to `(1 2)` → 3

Try these:
```lisp
(+ 5 (* 2 3))     ; Nested math
(+ 1 2 3 4)       ; Multiple arguments
```

## Step 3: Environments and Variables

```bash
$ ruby step3_env.rb
mal-user> (def! x 10)
10
mal-user> x
10
mal-user> (+ x 5)
15
```

Now we can store values! The environment is just an association list:
- `x = 10` becomes the pair `(x . 10)`
- Looking up `x` walks the list until it finds the pair

## Step 4: Functions and Control Flow

```bash
$ ruby step4_if_fn_do.rb
mal-user> (if true 1 2)
1
mal-user> (fn* (a) (+ a 1))
#<function>
mal-user> ((fn* (a) (+ a 1)) 5)
6
```

Functions capture their environment! Try:
```lisp
(def! inc (fn* (n) (+ n 1)))
(inc 5)                        ; => 6

(def! add5 
  ((fn* (x) 
    (fn* (y) (+ x y))) 5))    ; Closure!
(add5 3)                       ; => 8
```

## Step 5: Tail Call Optimization

Without TCO, this would crash:
```lisp
(def! sum-to (fn* (n acc)
  (if (= n 0)
    acc
    (sum-to (- n 1) (+ n acc)))))
    
(sum-to 10000 0)  ; Works! Returns 50005000
```

The magic is in the loop in EVAL - instead of recursive calls, we update variables and loop.

## Step 6: Files and More

```bash
$ ruby step6_file.rb
mal-user> (load-file "examples/factorial.mal")
mal-user> (factorial 5)
120
```

We can now:
- Load code from files
- Use `eval` to evaluate data as code
- Create atoms (mutable references)

## Step 7: Quote and Quasiquote

```lisp
'(+ 1 2)           ; => (+ 1 2) - not evaluated!
`(list 1 ~(+ 2 3)) ; => (list 1 5) - selective evaluation
```

This is where Lisp gets magical - code is data!

## Step 8: Macros

```lisp
(defmacro! unless (fn* (pred a b)
  `(if ~pred ~b ~a)))
  
(unless false "yes" "no")  ; => "yes"
```

Macros transform code before evaluation. They're like functions that run at compile time!

## Step 9: Exception Handling

```lisp
(try*
  (/ 1 0)
  (catch* e
    (str "Error: " e)))  ; => "Error: Division by zero"
```

Now we can handle errors gracefully.

## Key Takeaways for Beginners

1. **Everything is built from pairs** - No arrays needed!
2. **Lists are code, code is lists** - This is homoiconicity
3. **Environments chain together** - Lexical scoping
4. **Special forms control evaluation** - Not everything is a function
5. **Macros transform code** - Metaprogramming power

## Exercises to Try

1. **Trace evaluation by hand**:
   ```lisp
   (def! x 5)
   (let* (x 10 y x) (+ x y))
   ```
   What's the result and why?

2. **Build your own function**:
   Create a `max` function that returns the larger of two numbers.

3. **Experiment with macros**:
   Create an `when` macro (like `if` but no else clause).

## Common Confusions

- **Why no arrays?** - To show everything can be built from pairs
- **Why is it slow?** - Clarity over performance for learning
- **What's a special form?** - Something that controls evaluation (if, def!, fn*, etc.)

## Next Steps

1. Read the source code - start with `reader.rb`
2. Try the exercises in `exercises/student-exercises.md`
3. Implement a new built-in function
4. Create your own macro

Remember: The goal isn't to build a fast Lisp, but to understand how Lisp works!