# MAL Ruby Minimal

[![Ruby](https://img.shields.io/badge/Ruby-3.3.8-red.svg)](https://www.ruby-lang.org/)
[![MAL](https://img.shields.io/badge/MAL-Make_a_Lisp-blue.svg)](https://github.com/kanaka/mal)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SICP](https://img.shields.io/badge/Inspired%20by-SICP-purple.svg)](https://mitpress.mit.edu/sites/default/files/sicp/index.html)
[![Experimental](https://img.shields.io/badge/Status-Experimental-orange.svg)](https://github.com/aygp-dr/mal-ruby-minimal)

A minimal implementation of MAL (Make a Lisp) in Ruby using only 13 AST node types.

> **Note**: This is an experimental exploration into minimal language implementation. It demonstrates how a complete Lisp interpreter can be built without using Ruby's built-in arrays, hashes, or blocks - everything is constructed from cons cells.

## Overview

This project implements a complete Lisp interpreter with the following constraints:
- No Ruby arrays
- No Ruby hashes  
- No Ruby blocks
- Only 13 allowed AST node types

Despite these constraints, it provides:
- S-expression parser using only pairs
- Environment as association lists
- Special forms: `def`, `if`, `fn`, `quote`, `do`
- First-class functions and closures
- Recursive functions
- List processing

## Running the REPL

```bash
ruby mal_minimal.rb
```

Or make it executable:
```bash
chmod +x mal_minimal.rb
./mal_minimal.rb
```

## Example Session

```lisp
> (+ 1 2)
=> 3

> (def x 42)
=> 42

> (def inc (fn (n) (+ n 1)))
=> #<function>

> (inc 5)
=> 6

> (def fact (fn (n) (if (= n 0) 1 (* n (fact (- n 1))))))
=> #<function>

> (fact 5)
=> 120

> (def map (fn (f lst) (if (null? lst) nil (cons (f (car lst)) (map f (cdr lst))))))
=> #<function>

> (map inc (list 1 2 3))
=> (2 3 4)
```

## Built-in Functions

- Arithmetic: `+`, `-`, `*`, `/`
- Comparison: `=`, `<`, `>`
- List operations: `list`, `car`, `cdr`, `cons`, `null?`
- I/O: `print`

## Special Forms

- `def` - Define a variable
- `if` - Conditional expression
- `fn` - Create a function
- `quote` - Return expression unevaluated
- `do` - Evaluate multiple expressions

## Implementation Details

The implementation uses only basic Ruby constructs:
- Object instances for pairs, symbols, functions, and environments
- String eval for defining methods on objects
- No arrays or hashes - everything is built from cons cells
- Association lists for environment bindings

## Project Status

This is an **experimental exploration** that investigates:
- How minimal can a language implementation be?
- Can we build everything from just cons cells?
- What are the trade-offs of extreme minimalism?
- How do the 13 essential Ruby AST nodes map to interpreter construction?

## Research Context

This implementation is part of research into:
1. The Ruby Essence project's finding that 13 AST nodes cover 81% of Ruby code
2. SICP-style minimalist language construction
3. The MAL (Make a Lisp) step-by-step approach to building interpreters

## License

MIT