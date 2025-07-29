#!/bin/sh
# capture-mal-gui-states.sh

capture_emacs_state() {
    local state_name=$1
    local mal_file=$2
    local emacs_commands=$3
    local wait_time=${4:-5}
    
    echo "Capturing state: $state_name"
    
    # Start Xvfb
    Xvfb :99 -screen 0 1280x1024x24 &
    XVFB_PID=$!
    export DISPLAY=:99
    sleep 2
    
    # Start Emacs with commands
    emacs -Q -l mal-mode.el "$mal_file" \
        --eval "(set-frame-size (selected-frame) 120 40)" \
        --eval "(load-theme 'wombat t)" \
        --eval "$emacs_commands" &
    EMACS_PID=$!
    
    sleep $wait_time
    
    # Find and capture Emacs window
    WINDOW_ID=$(xwininfo -root -tree | grep -i "emacs" | head -1 | awk '{print $1}')
    
    if [ -n "$WINDOW_ID" ]; then
        # High quality capture
        xwd -id "$WINDOW_ID" -out temp.xwd
        magick temp.xwd -quality 100 "mal-gui-${state_name}.png"
        rm -f temp.xwd
        echo "  Saved: mal-gui-${state_name}.png"
    else
        # Fallback to root window
        import -window root "mal-gui-${state_name}-full.png"
        echo "  Saved: mal-gui-${state_name}-full.png (full screen)"
    fi
    
    # Cleanup
    kill $EMACS_PID 2>/dev/null
    kill $XVFB_PID 2>/dev/null
}

# Capture different states
capture_emacs_state "default" "examples/macros.mal" ""
capture_emacs_state "split" "examples/macros.mal" "(split-window-right)"
capture_emacs_state "repl" "examples/test-simple.mal" "(mal-repl)"
capture_emacs_state "church" "sicp/chapter2_church_numerals.mal" "(goto-line 15)"
capture_emacs_state "help" "examples/macros.mal" "(describe-mode)"