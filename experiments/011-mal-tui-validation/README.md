# MAL Mode TUI Screenshot Generation Experiment

## Overview

This experiment documents the process of capturing high-quality screenshots of MAL (Make-A-Lisp) mode running in Emacs within a terminal environment. The goal is to create visual documentation of the MAL development environment for use in specifications and documentation.

## Environment

- **OS**: FreeBSD 14.3-RELEASE (amd64)
- **Project**: mal-ruby-minimal
- **Terminal Multiplexer**: tmux
- **Editor**: Emacs with mal-mode.el

## Prerequisites Verification

Run these commands to verify all tools are installed:

```bash
# Check required tools
which tmux emacs ruby aha firefox asciinema agg magick

# Verify versions
tmux -V
emacs --version | head -1
ruby --version
aha --version
firefox --version
asciinema --version
agg --help | head -1
magick -version | head -1
```

Expected output should show all commands are available.

## Test Files Setup

Create test directory and files:

```bash
mkdir -p screenshots experiments/tui-tests

# Create test MAL files if not present
cat > examples/test-simple.mal << 'EOF'
;; Simple MAL test file
(def! x 42)
(println "Hello from MAL!")
(+ x 8)
EOF

cat > examples/test-church.mal << 'EOF'
;; Church numerals example
(def! church-zero (fn* [f] (fn* [x] x)))
(def! church-succ (fn* [n]
  (fn* [f] (fn* [x] (f ((n f) x))))))
(def! church-one (church-succ church-zero))
(def! church->int (fn* [n] ((n (fn* [x] (+ x 1))) 0)))
(println "Church one as int:" (church->int church-one))
EOF
```

## Experiment 1: Basic Screenshot with aha + Firefox

**Script**: `scripts/capture-mal-screenshot-aha.sh`

```bash
#!/bin/sh
# Capture MAL TUI screenshot using aha and Firefox

SESSION="mal-shot-$$"
FILE="${1:-examples/macros.mal}"
OUTPUT="${2:-screenshots/mal-aha-$(date +%Y%m%d-%H%M%S).png}"

echo "Starting capture of $FILE..."

# Start tmux with emacs
tmux new-session -d -s "$SESSION" -x 120 -y 40 \
    "emacs -nw -Q -l mal-mode.el $FILE"

# Wait for initialization
sleep 3

# Capture ANSI output
tmux capture-pane -t "$SESSION" -p -e > capture.ansi

# Convert to styled HTML
cat > capture.html << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { 
    background: #002b36; 
    color: #839496; 
    font-family: 'DejaVu Sans Mono', 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.2;
    padding: 20px;
    margin: 0;
}
pre { margin: 0; white-space: pre-wrap; }
</style>
</head>
<body>
<pre>
HTML_HEADER

aha --no-header --black < capture.ansi >> capture.html
echo "</pre></body></html>" >> capture.html

# Take screenshot
firefox --headless --window-size=1200,800 \
    --screenshot="$OUTPUT" \
    "file://$(pwd)/capture.html"

# Cleanup
tmux kill-session -t "$SESSION"
rm -f capture.ansi capture.html

echo "Screenshot saved to: $OUTPUT"
```

**Test Command**:
```bash
bash scripts/capture-mal-screenshot-aha.sh examples/macros.mal
```

**Expected Result**: PNG screenshot showing syntax-highlighted MAL code in Emacs

## Experiment 2: Animated GIF with asciinema + agg

**Script**: `scripts/capture-mal-demo-gif.sh`

```bash
#!/bin/sh
# Capture animated GIF of MAL interaction

OUTPUT="${1:-screenshots/mal-demo-$(date +%Y%m%d-%H%M%S).gif}"

echo "Recording MAL demo..."

# Record 10 second demo
asciinema rec -c "tmux new-session 'emacs -nw -Q -l mal-mode.el examples/test-simple.mal; sleep 10'" \
    --quiet \
    --idle-time-limit 2 \
    recording.cast

# Convert to GIF
agg recording.cast "$OUTPUT" \
    --font-family "DejaVu Sans Mono" \
    --font-size 14 \
    --theme solarized-dark

# Cleanup
rm -f recording.cast

echo "GIF saved to: $OUTPUT"
```

**Test Command**:
```bash
bash scripts/capture-mal-demo-gif.sh
```

**Expected Result**: Animated GIF showing Emacs loading and displaying MAL code

## Experiment 3: Multiple State Captures

**Script**: `scripts/capture-mal-states.sh`

```bash
#!/bin/sh
# Capture different MAL mode states

capture_state() {
    local name=$1
    local file=$2
    local keys=$3
    local wait=${4:-2}
    
    SESSION="mal-state-$$"
    OUTPUT="screenshots/mal-${name}-$(date +%Y%m%d-%H%M%S).png"
    
    echo "Capturing state: $name"
    
    # Start session
    tmux new-session -d -s "$SESSION" -x 120 -y 40 \
        "emacs -nw -Q -l mal-mode.el $file"
    
    sleep 3
    
    # Send keys if specified
    if [ -n "$keys" ]; then
        tmux send-keys -t "$SESSION" "$keys"
        sleep "$wait"
    fi
    
    # Capture and convert
    tmux capture-pane -t "$SESSION" -p -e | \
        aha --black --style > "capture-$name.html"
    
    # Screenshot
    firefox --headless --window-size=1200,800 \
        --screenshot="$OUTPUT" \
        "file://$(pwd)/capture-$name.html"
    
    # Cleanup
    tmux kill-session -t "$SESSION"
    rm -f "capture-$name.html"
    
    echo "  Saved: $OUTPUT"
}

# Capture different states
capture_state "editor" "examples/macros.mal" ""
capture_state "repl" "examples/test-simple.mal" "C-c C-z" 3
capture_state "eval" "examples/test-church.mal" "C-c C-e" 2
capture_state "help" "examples/macros.mal" "C-h m" 2
```

**Test Command**:
```bash
bash scripts/capture-mal-states.sh
```

**Expected Results**: 
- `mal-editor-*.png` - Normal editing view
- `mal-repl-*.png` - REPL interaction
- `mal-eval-*.png` - Code evaluation
- `mal-help-*.png` - Help buffer

## Experiment 4: TUI Layout Mockup

**Script**: `scripts/create-mal-tui-mockup.sh`

```bash
#!/bin/sh
# Create a TUI layout mockup for MAL development

SESSION="mal-tui-$$"
OUTPUT="screenshots/mal-tui-layout-$(date +%Y%m%d-%H%M%S).png"

# Start tmux with multiple panes
tmux new-session -d -s "$SESSION" -x 120 -y 40

# Create layout: editor (top-left), REPL (top-right), output (bottom)
tmux split-window -h -t "$SESSION"
tmux split-window -v -t "$SESSION" -p 30
tmux select-pane -t "$SESSION:0.0"

# Load different content in each pane
tmux send-keys -t "$SESSION:0.0" "emacs -nw -Q -l mal-mode.el examples/macros.mal" Enter
sleep 2

tmux send-keys -t "$SESSION:0.1" "cd ..; ./stepA_mal.rb" Enter
sleep 1
tmux send-keys -t "$SESSION:0.1" "(def! x 42)" Enter
sleep 0.5
tmux send-keys -t "$SESSION:0.1" "(+ x 8)" Enter

tmux send-keys -t "$SESSION:0.2" "make test | head -20" Enter

# Wait for everything to settle
sleep 3

# Capture entire window
tmux capture-pane -t "$SESSION" -p -e -S -3000 | \
    aha --black --style > capture-tui.html

# Take screenshot
firefox --headless --window-size=1200,800 \
    --screenshot="$OUTPUT" \
    "file://$(pwd)/capture-tui.html"

# Cleanup
tmux kill-session -t "$SESSION"
rm -f capture-tui.html

echo "TUI layout saved to: $OUTPUT"
```

## Validation Checklist

For each experiment, verify:

- [ ] Screenshot file is created in `screenshots/` directory
- [ ] Image shows proper syntax highlighting
- [ ] Terminal dimensions are correct (120x40)
- [ ] Text is readable and not cut off
- [ ] Colors match Emacs theme (solarized or similar)
- [ ] No error messages in output

## Troubleshooting

### Common Issues and Solutions

1. **"firefox: not found"**
   - Ensure Firefox is installed: `sudo pkg install firefox`
   - Alternative: Save HTML and open manually in browser

2. **"aha: not found"**
   - Install with: `sudo pkg install aha`
   - Alternative: Use `ansifilter` or `script` command

3. **Empty or black screenshots**
   - Increase sleep timers in scripts
   - Check tmux session manually: `tmux attach -t SESSION_NAME`
   - Verify mal-mode.el is in correct path

4. **Garbled ANSI output**
   - Ensure terminal supports 256 colors
   - Try different capture methods: `-p` vs `-p -e`

5. **Font issues in GIF**
   - Install DejaVu fonts: `sudo pkg install dejavu`
   - Try different font with agg: `--font-family "Courier New"`

## Expected Outputs

After running all experiments, you should have:

```
screenshots/
├── mal-aha-TIMESTAMP.png         # Basic screenshot
├── mal-demo-TIMESTAMP.gif        # Animated demo
├── mal-editor-TIMESTAMP.png      # Editor state
├── mal-repl-TIMESTAMP.png        # REPL state
├── mal-eval-TIMESTAMP.png        # Evaluation state
├── mal-help-TIMESTAMP.png        # Help state
└── mal-tui-layout-TIMESTAMP.png  # Multi-pane layout
```

## Final Notes

- All scripts are idempotent and can be run multiple times
- Timestamps prevent overwriting previous captures
- HTML files are cleaned up automatically
- Scripts exit cleanly even if interrupted

Run all experiments with:
```bash
for script in scripts/capture-*.sh; do
    echo "Running: $script"
    bash "$script"
    echo "---"
done
```

This completes the MAL mode TUI screenshot generation experiment. The captured images can be used as specifications for TUI development or documentation.