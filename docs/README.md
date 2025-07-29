# MAL Ruby Minimal - Documentation Index

Welcome to the documentation for MAL Ruby Minimal, a pedagogical Lisp interpreter built with extreme constraints.

## 📚 Learning Path

### Start Here
1. **[Learning Guide](learning-guide.md)** - Comprehensive introduction for students
2. **[Project Guide](project-guide.md)** - Complete project overview with practical examples
3. **[Cons Cell Visualizations](cons-cell-visualizations.md)** - Visual understanding of our data structure

### Deep Dives
4. **[Evaluation Walkthrough](evaluation-walkthrough.md)** - Step-by-step trace of evaluation
5. **[Implementation Notes](implementation-notes.md)** - Detailed notes for educators
6. **[Common Pitfalls](common-pitfalls.md)** - Mistakes to avoid and how to fix them

### Development
7. **[Code Style Guide](code-style-guide.md)** - Writing clear, educational code
8. **[Git Notes Template](git-notes-template.md)** - Documenting your commits thoroughly
9. **[Performance Analysis](performance-analysis.md)** - Why we chose clarity over speed

### Reference
10. **[MAL Process Guide](mal-process-guide.md)** - Official MAL implementation guide

## 🎯 Quick Reference

### Key Concepts
- **Cons Cells**: The only data structure - everything is built from pairs
- **No Arrays/Hashes/Blocks**: Extreme constraints force deep understanding
- **Immutability**: All data structures are immutable
- **Lexical Scope**: Functions capture their definition environment
- **TCO**: Tail Call Optimization prevents stack overflow

### Learning Objectives
After studying this implementation, students will understand:
1. How interpreters work at a fundamental level
2. How complex data structures emerge from simple pairs
3. The elegance of Lisp's minimal syntax
4. Trade-offs between simplicity and performance
5. The importance of clear, documented code

### Teaching Tips
- Start with cons cell diagrams
- Trace evaluation by hand before running code
- Modify the interpreter to add features
- Compare with array-based implementations
- Use the performance analysis to motivate optimizations

## 📖 Document Purposes

| Document | Purpose | Audience |
|----------|---------|----------|
| Learning Guide | Step-by-step introduction | Students new to interpreters |
| Project Guide | Practical usage and examples | Students ready to code |
| Cons Cell Visualizations | Visual learning aid | Visual learners |
| Evaluation Walkthrough | Detailed execution traces | Students debugging issues |
| Implementation Notes | Teaching strategies | Educators and TAs |
| Common Pitfalls | Troubleshooting guide | Students hitting problems |
| Code Style Guide | Coding standards | Contributors |
| Performance Analysis | Trade-off discussions | Advanced students |

## 🚀 Getting Started

```bash
# 1. Read the Learning Guide
cat docs/learning-guide.md

# 2. Try the REPL
make repl

# 3. Run tests
make test

# 4. Study the code
cat reader.rb  # Start here
```

## 💡 Key Insights

1. **Everything is a list** - Even our hash-maps are lists of pairs
2. **Recursion is fundamental** - No loops in our data structures
3. **Simple is not easy** - But simple teaches better than easy
4. **Constraints spark creativity** - Limited tools force deep understanding

## 📝 Contributing

When adding documentation:
1. Keep the pedagogical focus
2. Include examples
3. Explain the "why" not just the "what"
4. Add diagrams where helpful
5. Test all code examples

Remember: This project exists to teach. Every line of code and documentation should help students learn.

## 🎓 Further Study

After mastering this implementation:
1. Implement the remaining MAL steps (8-A)
2. Add optimizations while maintaining clarity
3. Port to another language with similar constraints
4. Build your own language with different design choices
5. Study production interpreters to see the trade-offs

Happy Learning! 🌟