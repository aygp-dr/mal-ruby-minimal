# Experiment 012: Eshell MAL Workflow

## Overview

This experiment demonstrates a minimal Emacs workflow for MAL development using:
- **mal-mode.el** for syntax highlighting and editing MAL code
- **eshell** as an integrated terminal for running the MAL REPL
- Split-window configuration for simultaneous code editing and REPL interaction

## Workflow Components

### 1. Code Editor (Top Window)
- Emacs with mal-mode active
- Syntax highlighting for MAL constructs
- Example code showing fibonacci sequence implementation

### 2. REPL Terminal (Bottom Window)
- Eshell running within Emacs
- MAL REPL (`ruby mal_minimal.rb`) for interactive testing
- Live evaluation of expressions

## Setup Instructions

### Manual Setup
1. Open Emacs: `emacs -nw`
2. Load mal-mode: `M-x load-file RET mal-mode.el RET`
3. Open MAL file: `C-x C-f examples/workflow-example.mal RET`
4. Split window: `C-x 2`
5. Switch to bottom: `C-x o`
6. Start eshell: `M-x eshell RET`
7. Run REPL: `ruby mal_minimal.rb`

### Automated Setup
```bash
# Run the capture script
bash scripts/capture-eshell-workflow.sh

# Or use the provided Elisp function
emacs -Q -l experiments/012-eshell-mal-workflow/setup-workflow.el
```

## Example Workflow

### Step 1: Write Code
```lisp
;; Fibonacci sequence generator
(def! fib (fn* (n)
  (if (<= n 1)
    n
    (+ (fib (- n 1)) 
       (fib (- n 2))))))
```

### Step 2: Test in REPL
```
> (load-file "examples/workflow-example.mal")
> (fib 10)
=> 55
```

### Step 3: Iterate
- Edit code in top window
- Test immediately in bottom eshell
- See results instantly

## Key Bindings

| Binding | Action |
|---------|--------|
| `C-x 2` | Split window horizontally |
| `C-x o` | Switch between windows |
| `C-c C-e` | Eval last expression (if configured) |
| `C-c C-r` | Eval region (if configured) |
| `M-x eshell` | Start eshell |

## Benefits

1. **Integrated Environment**: No need to switch between terminal and editor
2. **Immediate Feedback**: Test code as you write
3. **Consistent Interface**: All within Emacs
4. **Copy/Paste**: Easy to move code between editor and REPL
5. **History**: Eshell maintains command history

## Files Created

```
experiments/012-eshell-mal-workflow/
├── README.md           # This file
├── setup-workflow.el   # Elisp configuration
├── workflow.mal        # Example MAL code
└── screenshot.png      # Visual demonstration
```

## Running the Demo

```bash
# From project root
make -C experiments/012-eshell-mal-workflow demo
```

## Customization

The workflow can be customized by modifying `setup-workflow.el`:

```elisp
;; Change window split ratio
(split-window-below -15)  ; Smaller REPL window

;; Add key bindings
(define-key mal-mode-map (kbd "C-c C-z") 'eshell)
(define-key mal-mode-map (kbd "C-c C-e") 'mal-eval-last-sexp)
```

## Integration with mal-mode

The workflow leverages mal-mode features:
- Syntax highlighting
- Proper indentation
- Parenthesis matching
- Comment handling

## Troubleshooting

### REPL not starting
- Ensure `ruby` is in PATH
- Check `mal_minimal.rb` exists in project root

### mal-mode not loading
- Verify `mal-mode.el` path is correct
- Check for Emacs version compatibility

### Display issues
- Adjust terminal size: `tmux` default is 80x24
- Use larger terminal for better visibility

## Future Enhancements

1. **Direct evaluation**: Send code from editor to REPL
2. **Error highlighting**: Show REPL errors in editor
3. **Documentation lookup**: Quick help for MAL functions
4. **Project management**: Handle multiple MAL files

## Conclusion

This workflow provides a minimal but effective development environment for MAL, keeping everything within Emacs for a consistent and efficient experience.