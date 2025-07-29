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