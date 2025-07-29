# MAL Ruby Minimal - Learning Guide

## Introduction

This guide will help you understand how to build a Lisp interpreter from scratch using only the most fundamental building blocks. By the end, you'll have implemented a complete programming language without using Ruby's arrays, hashes, or blocks - everything is built from cons cells.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Core Concepts](#core-concepts)
3. [Implementation Journey](#implementation-journey)
4. [Key Learning Points](#key-learning-points)
5. [Exercises](#exercises)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

- Basic Ruby knowledge (variables, functions, classes)
- Understanding of recursion
- Familiarity with basic data structures
- No Lisp experience required!

## Core Concepts

### What is a Cons Cell?

A cons cell is the fundamental building block of Lisp. It's simply a pair of values:

```ruby
def cons(a, d)
  [a, d]  # We use a 2-element array, but conceptually it's just a pair
end

def car(c)
  c && c[0]  # Get first element (Contents of Address Register)
end

def cdr(c)
  c && c[1]  # Get second element (Contents of Decrement Register)
end
```

### Building Lists from Cons Cells

Lists are chains of cons cells:

```ruby
# The list (1 2 3) is represented as:
# cons(1, cons(2, cons(3, nil)))
#
# Visually:
#  [1|•]-->[2|•]-->[3|nil]
```

### Why These Constraints?

By avoiding Ruby's built-in data structures, we:
1. Understand how data structures work at a fundamental level
2. Experience the elegance of building everything from simple pairs
3. Learn how early Lisp implementations worked
4. Gain deep insight into recursion and list processing

## Implementation Journey

### Step 0: The REPL (Read-Eval-Print Loop)

**Goal**: Create a basic echo server that reads input and prints it back.

**Key Concepts**:
- What is a REPL?
- Basic I/O in Ruby
- The program loop pattern

**Try It**:
```bash
ruby step0_repl.rb
> hello
hello
```

### Step 1: Reading and Printing S-Expressions

**Goal**: Parse Lisp syntax into an Abstract Syntax Tree (AST).

**Key Concepts**:
- Tokenization: Breaking input into meaningful pieces
- Parsing: Building a tree structure from tokens
- S-expressions: The simple syntax of Lisp

**What You'll Learn**:
- How to build a parser without regular expressions
- Recursive descent parsing
- Pretty-printing data structures

**Example**:
```lisp
> (+ 1 2)
(+ 1 2)  ; Parsed and printed back
```

### Step 2: Basic Evaluation

**Goal**: Make arithmetic work.

**Key Concepts**:
- Tree walking: Traversing the AST
- Evaluation rules for different node types
- Built-in functions

**What You'll Learn**:
- The core eval function pattern
- How interpreters execute code
- Symbol lookup

### Step 3: Environments and Variables

**Goal**: Add variables with `def!` and local scopes with `let*`.

**Key Concepts**:
- Environments: Where variables live
- Association lists: Key-value storage using cons cells
- Lexical scoping

**What You'll Learn**:
- How variable binding works
- Nested scopes
- Environment chaining

**Example**:
```lisp
> (def! x 10)
10
> (let* (y 20) (+ x y))
30
```

### Step 4: Functions and Control Flow

**Goal**: Add `if`, `fn*`, and `do`.

**Key Concepts**:
- First-class functions
- Closures: Functions that capture their environment
- Special forms vs. regular functions

**What You'll Learn**:
- How functions are represented
- Why some forms can't be regular functions
- The power of closures

### Step 5: Tail Call Optimization (TCO)

**Goal**: Enable infinite recursion without stack overflow.

**Key Concepts**:
- The call stack problem
- Tail position
- Loop-based TCO

**What You'll Learn**:
- Why recursion can be problematic
- How to transform recursion into iteration
- The trampoline pattern

### Step 6: File I/O and Atoms

**Goal**: Load code from files and add mutable state.

**Key Concepts**:
- File operations
- Atoms: Mutable references
- The `eval` function

### Step 7: Quoting and Macros Foundation

**Goal**: Manipulate code as data.

**Key Concepts**:
- Code as data (homoiconicity)
- Quote and quasiquote
- Selective evaluation

## Key Learning Points

### 1. Everything is a List

In Lisp, code and data have the same structure:
```lisp
(+ 1 2)      ; This is code
'(+ 1 2)     ; This is data (a list)
```

### 2. Recursion is Fundamental

Most operations are naturally recursive:
```ruby
def length(lst)
  if null?(lst)
    0
  else
    1 + length(cdr(lst))
  end
end
```

### 3. Environments are Just Lists

Variable lookup is a simple list search:
```ruby
def lookup(key, env)
  if null?(env)
    raise "Undefined: #{key}"
  elsif car(car(env)) == key
    cdr(car(env))  # Return the value
  else
    lookup(key, cdr(env))  # Search rest
  end
end
```

### 4. Special Forms Control Evaluation

Not everything evaluates its arguments:
- `if` only evaluates one branch
- `def!` doesn't evaluate the symbol
- `quote` doesn't evaluate at all

## Exercises

### Beginner
1. Implement `length` to count list elements
2. Write `reverse` to reverse a list
3. Create `map` to apply a function to each element

### Intermediate
1. Add `cond` (multiple condition branches)
2. Implement `and` and `or` with short-circuiting
3. Create `filter` to select list elements

### Advanced
1. Add `loop`/`recur` for explicit tail recursion
2. Implement `defn` as a macro combining `def!` and `fn*`
3. Create a debugger that can step through evaluation

## Troubleshooting

### Common Issues

1. **"Stack level too deep"**
   - You're missing TCO for a recursive function
   - Solution: Ensure tail calls use the TCO loop

2. **"undefined method `name' for nil"**
   - You're calling car/cdr on nil
   - Solution: Add nil checks in your functions

3. **Parse errors**
   - Check for balanced parentheses
   - Ensure strings are properly quoted

### Debugging Tips

1. Add print statements in `EVAL` to trace execution
2. Use `pr_str` to inspect data structures
3. Test small expressions before combining them
4. Check environments with a debug print function

## Next Steps

After completing the basic implementation:

1. **Study the implementation patterns**
   - How does each step build on the previous?
   - What makes Lisp special?

2. **Experiment with the language**
   - Write small programs
   - Implement missing features
   - Try optimization techniques

3. **Compare with other implementations**
   - How do arrays/hashes make things easier?
   - What are the performance trade-offs?
   - Could you implement this in other languages?

## Resources

- [Make-a-Lisp Guide](https://github.com/kanaka/mal/blob/master/process/guide.md)
- [Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sicp/)
- [The Roots of Lisp](http://www.paulgraham.com/rootsoflisp.html)

## Conclusion

Building a Lisp from cons cells teaches fundamental computer science concepts:
- How programming languages work
- The power of simple abstractions
- Recursive thinking
- The relationship between code and data

Take your time, experiment, and enjoy the journey!