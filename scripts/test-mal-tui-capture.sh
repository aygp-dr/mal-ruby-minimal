#!/bin/sh
# Test MAL TUI capture from project root

echo "MAL TUI Capture Test"
echo "===================="
echo "Working directory: $(pwd)"
echo ""

# Ensure we're in the right directory
if [ ! -f "mal_minimal.rb" ]; then
    echo "Error: Not in mal-ruby-minimal directory"
    exit 1
fi

# Create screenshots directory if needed
mkdir -p screenshots

# Test 1: Simple ANSI to HTML capture
echo "Test 1: Basic ANSI capture"
echo "--------------------------"

SESSION="mal-test-$$"
tmux new-session -d -s "$SESSION" -x 80 -y 24 \
    "ruby mal_minimal.rb"

sleep 2

# Send test commands
tmux send-keys -t "$SESSION" "(+ 1 2)" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(def! x 42)" Enter
sleep 0.5

# Capture and convert
tmux capture-pane -t "$SESSION" -p -e > test-capture.ansi
echo "✓ ANSI captured ($(wc -l < test-capture.ansi) lines)"

# Convert to HTML
if which aha >/dev/null 2>&1; then
    aha --no-header --black < test-capture.ansi > screenshots/test-capture.html
    echo "✓ HTML created: screenshots/test-capture.html"
else
    echo "✗ aha not found - install with: sudo pkg install aha"
fi

# Cleanup
tmux kill-session -t "$SESSION"
rm -f test-capture.ansi

# Test 2: MAL mode capture
echo ""
echo "Test 2: MAL mode in Emacs"
echo "-------------------------"

if [ -f "mal-mode.el" ]; then
    SESSION2="mal-mode-$$"
    tmux new-session -d -s "$SESSION2" -x 80 -y 24 \
        "emacs -nw -Q -l mal-mode.el examples/macros.mal"
    
    sleep 3
    
    # Capture
    tmux capture-pane -t "$SESSION2" -p -e | \
        aha --no-header --black > screenshots/mal-mode-test.html 2>/dev/null || \
        echo "Note: aha conversion failed"
    
    echo "✓ MAL mode capture: screenshots/mal-mode-test.html"
    
    tmux kill-session -t "$SESSION2"
else
    echo "✗ mal-mode.el not found"
fi

# Test 3: Xvfb screenshot (if available)
echo ""
echo "Test 3: Xvfb screenshot test"
echo "----------------------------"

if which Xvfb >/dev/null 2>&1 && which xterm >/dev/null 2>&1; then
    # Start Xvfb
    Xvfb :99 -screen 0 1024x768x24 &
    XVFB_PID=$!
    export DISPLAY=:99
    sleep 2
    
    # Run simple X test
    xterm -geometry 80x24 -e "echo 'Xvfb test successful'; sleep 2" &
    XTERM_PID=$!
    sleep 1
    
    # Try to capture
    if which import >/dev/null 2>&1; then
        import -window root screenshots/xvfb-test.png 2>/dev/null && \
            echo "✓ Xvfb screenshot: screenshots/xvfb-test.png" || \
            echo "✗ Screenshot failed"
    else
        echo "✗ ImageMagick import not found"
    fi
    
    # Cleanup
    kill $XTERM_PID 2>/dev/null
    kill $XVFB_PID 2>/dev/null
else
    echo "✗ Xvfb or xterm not installed"
    echo "  Install with: sudo pkg install xorg-vfbserver xterm"
fi

echo ""
echo "Test Summary"
echo "============"
echo "Check screenshots/ directory for output files:"
ls -la screenshots/*.html screenshots/*.png 2>/dev/null | tail -5
echo ""
echo "All tests completed!"