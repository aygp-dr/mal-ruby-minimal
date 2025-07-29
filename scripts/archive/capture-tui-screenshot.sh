#!/bin/bash
# capture-tui-screenshot.sh

# Configuration
SESSION_NAME="mal-screenshot-$$"
OUTPUT_FILE="${1:-screenshot.png}"
MAL_FILE="${2:-examples/macros.mal}"
WAIT_TIME="${3:-5}"  # Time to wait before screenshot

# Start tmux session in background
tmux new-session -d -s "$SESSION_NAME" -x 120 -y 40 \
    "emacs -nw -Q -l mal-mode.el $MAL_FILE"

# Wait for emacs to fully load
sleep "$WAIT_TIME"

# Method 1: Capture pane as text (then convert to image)
tmux capture-pane -t "$SESSION_NAME" -p -e > capture.txt

# Method 2: Using terminal screenshot with ansi2html + wkhtmltoimage
tmux capture-pane -t "$SESSION_NAME" -p -e | \
    ansi2html -s solarized > capture.html
wkhtmltoimage --width 1200 --height 800 capture.html "$OUTPUT_FILE"

# Method 3: Using terminal-to-svg (if installed)
# tmux capture-pane -t "$SESSION_NAME" -p -e | \
#     terminal-to-svg > capture.svg

# Kill the tmux session
tmux kill-session -t "$SESSION_NAME"

# Cleanup
# rm -f capture.txt capture.html
