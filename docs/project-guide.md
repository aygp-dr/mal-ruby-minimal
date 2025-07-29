# MAL Ruby Minimal - Complete Project Guide

## What is This Project?

This is a **pedagogical implementation** of a Lisp interpreter in Ruby, following the Make-a-Lisp (MAL) process with extreme constraints:

- ✗ No Ruby arrays
- ✗ No Ruby hashes  
- ✗ No Ruby blocks
- ✓ Only cons cells
- ✓ Everything built from scratch

## Quick Start

```bash
# Clone the repository
git clone https://github.com/aygp-dr/mal-ruby-minimal.git
cd mal-ruby-minimal

# Check dependencies
make deps

# Run the REPL
make run

# Run tests
make test

# See all commands
make help
```

## Learning Path

### Week 1: Understand the Basics

1. **Read the Overview**
   - README.md - Project introduction
   - docs/cons-cell-visualizations.md - Understand the data structure

2. **Run Simple Examples**
   ```lisp
   > (+ 1 2)
   3
   > (def! x 10)
   10
   > (if (> x 5) "big" "small")
   "big"
   ```

3. **Study Core Modules**
   - reader.rb - How parsing works
   - printer.rb - How output works
   - env.rb - How variables work

### Week 2: Trace Through Evaluation

1. **Read Evaluation Walkthrough**
   - docs/evaluation-walkthrough.md
   - Trace examples by hand

2. **Understand Special Forms**
   - Why `if` is special
   - Why `def!` is special  
   - Why `fn*` is special

3. **Work Through Exercises**
   - exercises/student-exercises.md Level 1-2

### Week 3: Implement Features

1. **Follow MAL Steps**
   - Study step0 through step3
   - Understand progression

2. **Add Your Own Feature**
   - Start with exercises Level 3
   - Implement `cond` or `when`

3. **Debug Common Issues**
   - docs/common-pitfalls.md

### Week 4: Deep Dive

1. **Understand TCO**
   - Why recursion breaks
   - How the loop fixes it
   - step5_tco.rb

2. **Explore Advanced Topics**
   - Quote and quasiquote (step7)
   - Macros (step8 - if implemented)

3. **Performance Analysis**
   - docs/performance-analysis.md
   - Try optimizations

## Project Structure

### Core Implementation Files

```
├── reader.rb          # String → AST
├── printer.rb         # AST → String
├── env.rb             # Variable storage
├── mal_minimal.rb     # Complete implementation
```

### Step Implementations

```
├── step0_repl.rb      # Basic REPL
├── step1_read_print.rb # Parsing
├── step2_eval.rb      # Arithmetic
├── step3_env.rb       # Variables
├── step4_if_fn_do.rb  # Functions
├── step5_tco.rb       # Tail calls
├── step6_file.rb      # File I/O
├── step7_quote.rb     # Macros foundation
```

### Documentation

```
├── docs/
│   ├── learning-guide.md         # Start here!
│   ├── cons-cell-visualizations.md
│   ├── evaluation-walkthrough.md
│   ├── common-pitfalls.md
│   ├── implementation-notes.md
│   ├── performance-analysis.md
│   ├── code-style-guide.md
│   └── git-notes-template.md
```

## Key Concepts to Master

### 1. Cons Cells Are Everything

```ruby
# This is our only data structure
def cons(a, b)
  [a, b]  # Just a pair!
end

# Lists are chains of pairs
(1 2 3) = [1, [2, [3, nil]]]
```

### 2. Recursion Is Fundamental

```ruby
# Everything is recursive
def length(lst)
  if null?(lst)
    0
  else
    1 + length(cdr(lst))
  end
end
```

### 3. Environments Chain

```lisp
(def! x 10)           ; Global env: x=10
(let* (x 20 y 30)     ; New env: x=20, y=30, parent=global
  (+ x y))            ; Looks up x,y in new env
```

### 4. Special Forms Control Evaluation

```lisp
(if false           ; 'if' is special:
  (launch-missiles) ;   This is NOT evaluated!
  (make-peace))     ;   Only this is evaluated
```

### 5. Functions Capture Environments

```lisp
(def! make-adder (fn* (x)
  (fn* (y) (+ x y))))  ; Inner fn captures x

(def! add5 (make-adder 5))
(add5 3)  ; Returns 8
```

## Development Workflow

### 1. Make Changes

```bash
# Edit files
vim reader.rb

# Test your changes
ruby test/test_reader.rb

# Run integration tests
make test
```

### 2. Use the REPL for Testing

```bash
# Start REPL
make run

# Test your implementation
> (your-new-feature 1 2 3)
```

### 3. Commit with Good Messages

```bash
# See git notes template
git add -p  # Review changes
git commit  # Write good message
git notes add  # Add context
```

### 4. Push and Share

```bash
make push-all  # Tests, lints, and pushes
```

## Debugging Techniques

### 1. Add Debug Output

```ruby
def EVAL(ast, env)
  puts "EVAL: #{pr_str(ast)}" if ENV['DEBUG']
  # ...
end
```

Run with: `DEBUG=1 ruby mal_minimal.rb`

### 2. Use the Test Suite

```bash
# Run specific test
ruby test/test_reader.rb

# Run with coverage
make test-coverage
```

### 3. Interactive Debugging

```ruby
# Add breakpoint
def some_function
  require 'pry'; binding.pry  # If you have pry
  # or
  debugger  # Ruby built-in
  # or just
  puts "Variable x = #{x.inspect}"
end
```

## Common Tasks

### Add a New Built-in Function

1. Add to `create_core_fns`:
   ```ruby
   core["reverse"] = "reverse"
   ```

2. Add to `apply_builtin`:
   ```ruby
   when "reverse"
     reverse_list(a)
   ```

3. Test it:
   ```lisp
   > (reverse (list 1 2 3))
   (3 2 1)
   ```

### Add a New Special Form

1. Add to EVAL's special form check:
   ```ruby
   when "when"
     # Your implementation
   ```

2. Remember: Special forms control evaluation!

### Run Examples

```bash
# Run all examples
make examples

# Run specific example
ruby mal_minimal.rb < examples/factorial.mal
```

## Advanced Topics

### Understanding Macros

- Step 7 (quote) lays the foundation
- Step 8 would add defmacro!
- Macros transform code before evaluation

### Self-Hosting

- Step A implements MAL in MAL
- The ultimate test of completeness
- Shows the power of minimalism

### Optimization Ideas

1. **Environment Caching**: Speed up lookups
2. **Constant Folding**: Evaluate at parse time
3. **Bytecode Compilation**: Compile to instructions
4. **JIT Compilation**: Generate Ruby code

## Getting Help

### Resources

1. **Project Documentation**: Start with docs/
2. **MAL Guide**: https://github.com/kanaka/mal/blob/master/process/guide.md
3. **SICP**: https://mitpress.mit.edu/sicp/
4. **GitHub Issues**: https://github.com/aygp-dr/mal-ruby-minimal/issues

### Common Questions

**Q: Why is it so slow?**
A: It's intentionally inefficient to be clear. See performance-analysis.md.

**Q: Why no arrays/hashes?**
A: To show how everything can be built from pairs. It's pedagogical.

**Q: Can I use this in production?**
A: No! This is for learning. Use a real Lisp for production.

**Q: How do I add feature X?**
A: Check exercises/student-exercises.md for ideas and guidance.

## Contributing

### Ways to Help

1. **Find Bugs**: Test edge cases
2. **Improve Docs**: Clarify confusing parts
3. **Add Examples**: Show cool MAL programs
4. **Create Exercises**: Help others learn

### Guidelines

- Follow code-style-guide.md
- Add tests for new features
- Update documentation
- Use clear commit messages
- Add git notes for context

## Final Thoughts

This project is about understanding, not performance. Take your time, experiment, break things, and learn. The constraints are features—they force deep understanding.

Remember: If you can build a Lisp from cons cells, you can build anything.

Happy hacking! 🎉