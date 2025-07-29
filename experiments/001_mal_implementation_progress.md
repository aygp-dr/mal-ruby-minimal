# Experiment 001: MAL Implementation Progress

## Overview
Implementing a Make-a-Lisp (MAL) interpreter in Ruby with strict constraints:
- NO Ruby arrays, hashes, or blocks allowed
- Everything built from cons cells
- Only 13 allowed AST node types

## Progress Log

### Completed Steps

#### Step 0: REPL (✓)
- Basic read-eval-print loop
- Echo functionality

#### Step 1: Read/Print (✓)
- S-expression parser using cons cells
- Tokenizer without arrays
- Printer for all data types

#### Step 2: Eval (✓)
- Basic arithmetic evaluation
- Expression evaluation without special forms

#### Step 3: Environments (✓)
- Environment as association list
- def! special form
- let* special form with proper scoping

#### Step 4: If/Functions/Do (✓)
- if special form with proper truthiness
- fn* for user-defined functions
- do special form for sequencing
- Closures capture lexical environment

#### Step 5: Tail Call Optimization (✓)
- TCO using loop instead of recursion
- Prevents stack overflow on recursive functions
- Tested with factorial and sum functions

#### Step 6: Files, Eval, and Atoms (✓)
- File I/O with slurp and load-file
- eval function for runtime evaluation
- Atoms for mutable state
- Command line argument support (*ARGV*)

#### Step 7: Quote and Quasiquote (In Progress)
- quote special form implemented
- quasiquote with unquote working
- splice-unquote functional
- 33/36 tests passing

### Current Issues

1. **Nested quasiquote**: Not preserving inner unquote forms
   - Expected: `(1 (quasiquote (2 (unquote (+ 1 2)) 4)) 5)`
   - Actual: `(1 (quasiquote (2 3 4)) 5)`

2. **Error messages**: unquote/splice-unquote outside quasiquote
   - Should give specific error about being outside quasiquote
   - Currently just says "requires an argument"

### Upcoming Steps

- Step 8: Macros
- Step 9: Try/Catch exception handling  
- Step A: Self-hosting MAL implementation

## Key Design Decisions

### Cons Cell Implementation
```ruby
def cons(a, d)
  [a, d]
end

def car(c)
  c && c[0]
end

def cdr(c)
  c && c[1]
end
```

### Environment as Association List
```ruby
def set(key, value)
  @data = cons(cons(key, value), @data)
  value
end
```

### TCO with Loop
```ruby
def EVAL(ast, env)
  loop do
    # Update ast/env instead of recursion
  end
end
```

## Test Results

### Unit Tests
- Reader: All passing
- Printer: All passing
- Environment: All passing
- Step 4 functions: All passing
- Step 7 quote: 33/36 passing

### Integration Tests
- Step 1 expect tests: Passing (with send -- fix)

## Notes

- Using eval with heredocs to define methods dynamically
- No metaprogramming beyond eval for method definitions
- Strict adherence to cons cell only data structures
- Following MAL guide implementation steps closely