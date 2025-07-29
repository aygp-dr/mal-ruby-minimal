# Quick Start Guide

Get up and running with MAL Ruby Minimal in under 5 minutes!

## Prerequisites

```bash
# Check Ruby version (3.0+ required)
ruby --version

# Install dependencies (FreeBSD)
sudo pkg install tmux emacs git

# Or macOS
brew install tmux emacs git

# Or Ubuntu/Debian  
sudo apt install tmux emacs git
```

## 1. Clone and Run ⚡

```bash
git clone https://github.com/aygp-dr/mal-ruby-minimal.git
cd mal-ruby-minimal

# Start the REPL immediately
make run
```

You should see the MAL banner and prompt:
```
╔═══════════════════════════════════════════════════════════════════╗
║                    MAL - Make a Lisp (Ruby Minimal)               ║
...
> 
```

## 2. Try Basic Examples 🧮

```lisp
> (+ 1 2 3)
6

> (def! x 42)
42

> (* x 2)
84

> (def! factorial (fn* (n) (if (= n 0) 1 (* n (factorial (- n 1))))))
#<function>

> (factorial 5)
120
```

## 3. Development Environment 🛠️

### Option A: Emacs Integration (Recommended)
```bash
# Load mal-mode for syntax highlighting
emacs -nw -l mal-mode.el examples/macros.mal

# Or use the integrated workflow
make -C experiments/012-eshell-mal-workflow demo
```

### Option B: tmux Multi-pane Setup
```bash
# Start tmux session with editor + REPL
make tmux-repl

# In another terminal, attach to see the session
tmux attach -t mal-repl
```

## 4. Explore Examples 📚

```bash
# See all available examples
ls examples/

# Try the algorithms
ruby mal_minimal.rb examples/algorithms.mal

# Explore functional programming patterns  
ruby mal_minimal.rb examples/functional-patterns.mal

# Check out advanced macros
ruby mal_minimal.rb examples/macros.mal
```

## 5. Experiments 🔬

```bash
# List all 12 experiments
make experiments

# Try the Church encoding experiment
make -C experiments/004-church-encoding-mal

# Test the SICP examples
make -C experiments/005-sicp-mal

# Explore the eshell workflow
make -C experiments/012-eshell-mal-workflow demo
```

## 6. Generate Screenshots 📸

```bash
# Create visual documentation
make screenshots

# Or generate specific types
./scripts/screenshot.sh gui
./scripts/screenshot.sh tmux screenshots/my-setup
```

## 7. Run Tests ✅

```bash
# Run all tests
make test

# Check code quality
make lint

# Validate experiments
make validate-experiments
```

## Quick Commands Reference

| Command | Purpose |
|---------|---------|
| `make run` | Start REPL |
| `make test` | Run all tests |
| `make experiments` | List experiments |
| `make screenshots` | Generate screenshots |
| `make help` | Show all available targets |
| `Ctrl+D` | Exit REPL |

## File Structure at a Glance

```
mal-ruby-minimal/
├── mal_minimal.rb          # Main interpreter
├── mal-mode.el            # Emacs integration
├── examples/              # Example MAL programs
│   ├── algorithms.mal     # Sorting, searching
│   ├── data-structures.mal # Trees, graphs from cons cells
│   └── functional-patterns.mal # Advanced FP techniques
├── experiments/           # 12 research experiments  
├── scripts/               # Development utilities
├── screenshots/           # Visual documentation
└── docs/                  # Learning materials
```

## What Makes This Special? ✨

- **Extreme Minimalism**: Built with only 13 Ruby AST node types
- **No Arrays/Hashes/Blocks**: Everything from cons cells
- **Educational Focus**: 5 comprehensive pedagogical review passes
- **Complete MAL**: All features from the original MAL guide
- **Modern Tooling**: Screenshot generation, Emacs integration, automated testing

## Next Steps 🚀

1. **Read the README**: Comprehensive documentation with examples
2. **Try the experiments**: 12 research projects exploring different aspects
3. **Modify the interpreter**: Add your own built-in functions
4. **Create examples**: Write MAL programs demonstrating concepts
5. **Generate documentation**: Use the screenshot tools for visual guides

## Getting Help 💬

- **Documentation**: Check `docs/` directory for detailed guides
- **Examples**: Look at `examples/` for working code
- **Experiments**: Each experiment has its own README
- **Issues**: Open GitHub issues for questions or problems

## Pro Tips 💡

1. **Use mal-mode**: Syntax highlighting makes MAL much easier to read
2. **Try tmux workflow**: Split-pane development is very efficient  
3. **Explore experiments**: Each one teaches different concepts
4. **Generate screenshots**: Great for documentation and presentations
5. **Read the constraints**: Understanding the 13-node limit is key

Happy Lisping! 🎉