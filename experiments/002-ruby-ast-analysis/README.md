# Experiment 002: Ruby AST Analysis

## Objective
Analyze the actual Ruby AST nodes used in our MAL implementation to validate the "13 essential AST node types" constraint from Ruby Essence research.

## Background
The Ruby Essence project found that 13 AST node types account for 81% of Ruby code:

1. `send` (method calls)
2. `lvar` (local variables)
3. `const` (constants) 
4. `int` (integers)
5. `str` (strings)
6. `if` (conditionals)
7. `def` (method definitions)
8. `args` (argument lists)
9. `begin` (blocks)
10. `return` (return statements)
11. `true` (true literal)
12. `false` (false literal) 
13. `nil` (nil literal)

## Research Questions
1. What Ruby AST nodes did we actually use in our implementation?
2. How many fall within the "essential 13"?
3. What patterns emerge in our control flow?
4. Which nodes were most critical for interpreter construction?

## Methodology
1. Parse all Ruby files in our implementation
2. Extract and catalog all AST node types
3. Count frequency of each node type
4. Analyze control flow patterns
5. Map to Ruby Essence categories
6. Generate visualizations and statistics

## Files to Analyze
- `mal_minimal.rb` - Main interpreter
- `reader.rb` - Parser
- `printer.rb` - Formatter  
- `env.rb` - Environment
- `step0_repl.rb` through `stepA_mal.rb` - Progressive implementations
- Test files

## Expected Outcomes
- Validation (or refutation) of the 13-node constraint
- Identification of interpreter-specific patterns
- Insights into minimal language implementation requirements
- Data to support architectural decisions