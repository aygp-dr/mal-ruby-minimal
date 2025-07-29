# MAL Ruby Minimal - Assessment Rubric

## Overview

This rubric helps educators assess student understanding of the MAL Ruby Minimal implementation. It's designed to evaluate both conceptual understanding and practical skills.

## Core Concepts (40 points)

### Cons Cells and Lists (10 points)
- **Excellent (9-10)**: Can draw cons cell diagrams, implement list operations, explain why we use pairs
- **Good (7-8)**: Understands cons/car/cdr, can trace list operations
- **Satisfactory (5-6)**: Basic understanding of pairs, some confusion on complex structures
- **Needs Work (0-4)**: Struggles with basic cons cell concepts

### Evaluation Model (10 points)
- **Excellent (9-10)**: Can trace evaluation step-by-step, understands special forms vs functions
- **Good (7-8)**: Understands EVAL function, can explain most evaluation rules
- **Satisfactory (5-6)**: Basic understanding of evaluation, some confusion on edge cases
- **Needs Work (0-4)**: Cannot explain how expressions are evaluated

### Environment and Scope (10 points)
- **Excellent (9-10)**: Fully understands lexical scope, can trace environment chains, explains closures
- **Good (7-8)**: Understands environment lookup, basic closure concepts
- **Satisfactory (5-6)**: Knows variables are stored in environments, some scope confusion
- **Needs Work (0-4)**: Doesn't understand environment chains or scope

### Special Forms (10 points)
- **Excellent (9-10)**: Can implement new special forms, explains why they're special
- **Good (7-8)**: Understands all existing special forms, their evaluation rules
- **Satisfactory (5-6)**: Knows special forms exist, understands basic ones (if, def!)
- **Needs Work (0-4)**: Confuses special forms with functions

## Implementation Skills (30 points)

### Reading Code (10 points)
- **Excellent (9-10)**: Can explain any part of the implementation, sees the big picture
- **Good (7-8)**: Understands most code, can trace through functions
- **Satisfactory (5-6)**: Can read simple functions, needs help with complex ones
- **Needs Work (0-4)**: Struggles to understand the code

### Modifying Code (10 points)
- **Excellent (9-10)**: Can add new features maintaining style and constraints
- **Good (7-8)**: Can make simple modifications correctly
- **Satisfactory (5-6)**: Can modify with guidance, sometimes breaks constraints
- **Needs Work (0-4)**: Cannot modify code without extensive help

### Debugging (10 points)
- **Excellent (9-10)**: Can debug complex issues, adds helpful debug output
- **Good (7-8)**: Can find and fix simple bugs, uses print debugging
- **Satisfactory (5-6)**: Can identify where problems occur, needs help fixing
- **Needs Work (0-4)**: Cannot effectively debug issues

## Advanced Understanding (30 points)

### Tail Call Optimization (10 points)
- **Excellent (9-10)**: Fully explains TCO implementation, can identify tail positions
- **Good (7-8)**: Understands why TCO is needed, basic implementation
- **Satisfactory (5-6)**: Knows TCO prevents stack overflow
- **Needs Work (0-4)**: Doesn't understand TCO

### Quote and Quasiquote (10 points)
- **Excellent (9-10)**: Can implement macros, fully understands quote manipulation
- **Good (7-8)**: Understands quote/quasiquote/unquote interaction
- **Satisfactory (5-6)**: Basic understanding of quote preventing evaluation
- **Needs Work (0-4)**: Confused about quote semantics

### Performance Trade-offs (10 points)
- **Excellent (9-10)**: Can explain all trade-offs, suggest optimizations preserving clarity
- **Good (7-8)**: Understands why implementation is slow, main bottlenecks
- **Satisfactory (5-6)**: Knows cons cells are slower than arrays
- **Needs Work (0-4)**: Doesn't understand performance implications

## Practical Exercises

### Exercise 1: Implement a New Built-in Function (Easy)
Add a `max` function that returns the largest of its arguments.
- Full points: Correct implementation following patterns
- Partial: Works but doesn't match style
- No points: Doesn't work

### Exercise 2: Add a Special Form (Medium)
Implement `when` - like `if` but with no else clause, returns nil if false.
- Full points: Correct special form with proper evaluation control
- Partial: Works but evaluates too eagerly
- No points: Doesn't work or implemented as function

### Exercise 3: Trace Evaluation (Medium)
Given: `(let* (x 10 f (fn* (y) (+ x y))) (f 5))`
Trace the complete evaluation showing all environment operations.
- Full points: Complete accurate trace
- Partial: Mostly correct with minor errors
- No points: Major conceptual errors

### Exercise 4: Fix a Bug (Hard)
Given a bug in quasiquote handling, debug and fix it.
- Full points: Identifies root cause and fixes correctly
- Partial: Identifies issue but fix is incomplete
- No points: Cannot identify the issue

## Grading Scale

- **A (90-100)**: Deep understanding, can extend and teach others
- **B (80-89)**: Good understanding, can work independently
- **C (70-79)**: Adequate understanding, can work with some guidance
- **D (60-69)**: Minimal understanding, needs significant help
- **F (0-59)**: Insufficient understanding

## Portfolio Projects

For advanced assessment, consider these portfolio projects:

1. **Tutorial Creation**: Write a tutorial explaining one aspect deeply
2. **Feature Addition**: Add strings with escape sequences
3. **Optimization**: Improve performance while maintaining clarity
4. **Comparison**: Compare with another MAL implementation
5. **Teaching**: Lead a study group or create exercises

## Assessment Tips

1. **Focus on Understanding**: Syntax errors are less important than conceptual errors
2. **Encourage Exploration**: Reward creative solutions that maintain constraints
3. **Value Documentation**: Good comments and commit messages show understanding
4. **Practical Over Perfect**: Working code that's clear beats clever code
5. **Growth Mindset**: Assess improvement over time, not just final state

## Self-Assessment Questions

Students should be able to answer:

1. Why can't we use Ruby arrays in this implementation?
2. How does a function capture its environment?
3. What makes special forms special?
4. Why do we need TCO?
5. How would you add mutable variables?
6. What's the slowest operation and why?
7. How does quote differ from list?
8. Why is everything built from cons cells?
9. How would you implement a debugger?
10. What did you learn that surprised you?

## Evidence of Mastery

A student has mastered the material when they can:
- Implement a new special form without help
- Debug complex evaluation issues
- Explain the implementation to another student
- Identify and articulate trade-offs
- Extend the language meaningfully
- Write clear, constraint-respecting code

Remember: The goal is understanding, not memorization. A student who truly understands can recreate the implementation from principles.