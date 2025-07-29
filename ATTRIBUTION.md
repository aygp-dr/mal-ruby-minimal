# Attribution

This minimal MAL (Make a Lisp) implementation is inspired by:

- **MAL - Make a Lisp** by Joel Martin (https://github.com/kanaka/mal)
  - MAL is a Clojure-inspired Lisp interpreter implemented in 80+ languages
  - This implementation follows MAL's general architecture but with unique constraints

- **Ruby Essence Project** 
  - Analysis showing 13 essential AST nodes cover 81% of Ruby code
  - Demonstrates the Pareto principle in language design

## Unique Aspects

This implementation is unique in that it:
1. Uses NO Ruby arrays, hashes, or blocks
2. Implements all data structures using only cons cells (pairs)
3. Demonstrates that complex interpreters can be built with minimal language features
4. Shows how the 13 essential Ruby AST nodes map to a constrained implementation

## License

This implementation is released under the MIT License, compatible with the original MAL project.