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