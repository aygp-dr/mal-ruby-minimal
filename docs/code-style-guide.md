# MAL Ruby Minimal - Code Style Guide

## Purpose

This guide ensures consistent, readable code that serves as a good example for students. Remember: this code is meant to teach, not just to run.

## General Principles

1. **Clarity over Cleverness**: Students should understand the code
2. **Explicit over Implicit**: Show all the steps
3. **Consistent Patterns**: Use the same approach throughout
4. **Educational Comments**: Explain the "why", not just the "what"

## Naming Conventions

### Variables
```ruby
# Good: Descriptive names
current_token = reader.next
environment_chain = env.outer

# Bad: Cryptic abbreviations
t = reader.next
e = env.outer
```

### Functions
```ruby
# Good: Verb or verb phrase
def evaluate_list(lst, env)
def bind_parameters(params, args, env)

# Bad: Noun only or unclear
def list(lst, env)
def params(p, a, e)
```

### Special Naming
```ruby
# Predicates end with ?
def symbol?(obj)
def null?(obj)

# Dangerous operations end with !
def set!(key, value)  # If we had mutation

# Type constructors start with make_
def make_symbol(name)
def make_keyword(name)
```

## Code Structure

### Module Organization
```ruby
# 1. File header comment
# Reader module - converts strings to AST

# 2. Required files
require_relative 'types'

# 3. Core data structures
def cons(a, d)
  # ...
end

# 4. Type definitions
def make_symbol(name)
  # ...
end

# 5. Main functionality
class Reader
  # ...
end

# 6. Helper functions
def reverse_list(lst)
  # ...
end
```

### Function Structure
```ruby
def function_name(param1, param2)
  # 1. Input validation / base cases
  return nil if null?(param1)
  
  # 2. Main logic
  result = process_data(param1)
  
  # 3. Return value
  result
end
```

## Cons Cell Patterns

### Building Lists
```ruby
# Good: Clear accumulator pattern
def build_list(elements)
  result = nil
  elements.each do |elem|
    result = cons(elem, result)
  end
  reverse_list(result)
end

# Bad: Unclear construction
def build_list(elements)
  elements.inject(nil) { |r, e| cons(e, r) }.reverse
end
```

### Walking Lists
```ruby
# Good: Clear iteration
def walk_list(lst)
  current = lst
  while !null?(current)
    process(car(current))
    current = cdr(current)
  end
end

# Bad: Trying to be too clever
def walk_list(lst)
  null?(lst) ? nil : (process(car(lst)); walk_list(cdr(lst)))
end
```

## Error Handling

### Clear Error Messages
```ruby
# Good: Helpful error message
if !symbol?(param)
  raise "Function parameter must be a symbol, got #{param.class}"
end

# Bad: Generic error
if !symbol?(param)
  raise "Invalid parameter"
end
```

### Fail Fast
```ruby
# Good: Check preconditions early
def divide(a, b)
  raise "Division by zero" if b == 0
  a / b
end

# Bad: Deep nesting
def divide(a, b)
  if b != 0
    a / b
  else
    raise "Division by zero"
  end
end
```

## Comments

### Function Comments
```ruby
# Evaluate an AST node in the given environment.
# Handles special forms, function calls, and atoms.
#
# @param ast [Object] The AST node to evaluate
# @param env [Env] The environment for variable lookup
# @return [Object] The evaluated result
def EVAL(ast, env)
  # ...
end
```

### Inline Comments
```ruby
# Good: Explains why
# We build the list backwards for O(1) insertion,
# then reverse at the end
tokens = nil

# Bad: Explains what (obvious from code)
tokens = nil  # Set tokens to nil
```

### Educational Comments
```ruby
# PEDAGOGICAL NOTE:
# This demonstrates the difference between special forms
# and functions. Special forms control evaluation of their
# arguments, while functions receive already-evaluated arguments.
```

## Anti-Patterns to Avoid

### Don't Use Ruby Conveniences
```ruby
# Bad: Using blocks
lst.each { |x| process(x) }

# Good: Explicit iteration
current = lst
while !null?(current)
  process(car(current))
  current = cdr(current)
end
```

### Don't Hide Complexity
```ruby
# Bad: Magic method
def magic_eval(ast, env)
  send("eval_#{ast.type}", ast, env)
end

# Good: Explicit dispatch
def EVAL(ast, env)
  if symbol?(ast)
    eval_symbol(ast, env)
  elsif list?(ast)
    eval_list(ast, env)
  # ...
  end
end
```

### Don't Optimize Prematurely
```ruby
# Bad: Trying to be efficient
@symbol_cache ||= {}
@symbol_cache[name] ||= make_symbol(name)

# Good: Simple and clear
make_symbol(name)
```

## Testing Patterns

### Test Organization
```ruby
# Group related tests
puts "Testing arithmetic..."
test "addition", 3, EVAL(READ("(+ 1 2)"), env)
test "subtraction", -1, EVAL(READ("(- 1 2)"), env)

puts "\nTesting special forms..."
test "if true branch", 1, EVAL(READ("(if true 1 2)"), env)
```

### Test Names
```ruby
# Good: Descriptive test names
test "empty list evaluates to nil"
test "undefined symbol raises error"

# Bad: Generic names
test "test1"
test "list test"
```

## Documentation Standards

### README Sections
1. **Overview**: What is this project?
2. **Constraints**: What makes it special?
3. **Quick Start**: How to run it?
4. **Examples**: What can it do?
5. **Architecture**: How does it work?
6. **Contributing**: How to help?

### Code Documentation
- Every module has a header comment
- Every non-trivial function has a purpose comment
- Complex algorithms have step-by-step comments
- Pedagogical notes explain teaching points

## Commit Messages

### Format
```
type(scope): subject

Longer description if needed.

--trailer Co-Authored-By: Name <email>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Testing
- `refactor`: Code reorganization
- `style`: Formatting

### Examples
```
feat(reader): add string escape handling

fix(env): correct variable shadowing in nested scopes

docs(tutorial): add step-by-step evaluation examples
```

## File Organization

```
mal-ruby-minimal/
├── README.md           # Project overview
├── LICENSE            # MIT license
├── Makefile           # Build automation
│
├── *.rb               # Implementation files
├── step*.rb           # MAL step implementations
│
├── test/              # Test files
│   ├── test_*.rb     # Unit tests
│   └── *.exp         # Integration tests
│
├── docs/              # Documentation
│   ├── *.md          # Guides and references
│   └── images/       # Diagrams
│
├── examples/          # Example MAL programs
│   └── *.mal         # Sample code
│
└── experiments/       # Research and exploration
    └── *.md          # Experiment documentation
```

## Code Review Checklist

- [ ] Follows naming conventions
- [ ] Has appropriate comments
- [ ] Includes error handling
- [ ] Uses consistent patterns
- [ ] Avoids Ruby conveniences
- [ ] Is readable by students
- [ ] Has associated tests
- [ ] Updates documentation

## Remember

This code is a teaching tool. Every line should help students understand:
1. How interpreters work
2. How to build complex systems from simple parts
3. How to write clear, maintainable code
4. The beauty of Lisp's minimalism

When in doubt, choose the approach that teaches the most, even if it's not the most efficient.