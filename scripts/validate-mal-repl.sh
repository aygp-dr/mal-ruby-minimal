#!/bin/sh
# Validate MAL REPL display and functionality

echo "MAL REPL Display Validation"
echo "==========================="
echo ""

# Test 1: Basic REPL interaction
echo "Test 1: Basic REPL banner and interaction"
echo "-----------------------------------------"

OUTPUT1="screenshots/mal-repl-banner-$(date +%Y%m%d-%H%M%S).png"
SESSION="mal-repl-test-$$"

# Start REPL and capture banner
tmux new-session -d -s "$SESSION" -x 120 -y 40 "ruby mal_minimal.rb"
sleep 2

# Capture initial banner
tmux capture-pane -t "$SESSION" -p -e > capture-banner.ansi
echo "✓ Banner captured"

# Send some commands
tmux send-keys -t "$SESSION" "(+ 1 2)" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(def! x 42)" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(* x 2)" Enter
sleep 0.5

# Capture full session
tmux capture-pane -t "$SESSION" -p -e | aha --black --style > capture-repl.html

# Take screenshot
firefox --headless --window-size=1200,800 \
    --screenshot="$OUTPUT1" \
    "file://$(pwd)/capture-repl.html"

echo "✓ REPL screenshot saved to: $OUTPUT1"

# Cleanup
tmux kill-session -t "$SESSION"
rm -f capture-banner.ansi capture-repl.html

# Test 2: Error handling display
echo ""
echo "Test 2: Error handling display"
echo "------------------------------"

OUTPUT2="screenshots/mal-repl-errors-$(date +%Y%m%d-%H%M%S).png"
SESSION="mal-error-test-$$"

tmux new-session -d -s "$SESSION" -x 120 -y 40 "ruby mal_minimal.rb"
sleep 2

# Send commands that will error
tmux send-keys -t "$SESSION" "(/ 1 0)" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(undefined-symbol)" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(+ 1 'two)" Enter
sleep 0.5

# Capture and screenshot
tmux capture-pane -t "$SESSION" -p -e | aha --black --style > capture-errors.html
firefox --headless --window-size=1200,800 \
    --screenshot="$OUTPUT2" \
    "file://$(pwd)/capture-errors.html"

echo "✓ Error display screenshot saved to: $OUTPUT2"

# Cleanup
tmux kill-session -t "$SESSION"
rm -f capture-errors.html

# Test 3: Multi-line input
echo ""
echo "Test 3: Multi-line function definition"
echo "--------------------------------------"

OUTPUT3="screenshots/mal-repl-multiline-$(date +%Y%m%d-%H%M%S).png"
SESSION="mal-multi-test-$$"

tmux new-session -d -s "$SESSION" -x 120 -y 40 "ruby mal_minimal.rb"
sleep 2

# Send multi-line function
tmux send-keys -t "$SESSION" "(def! factorial" Enter
sleep 0.3
tmux send-keys -t "$SESSION" "  (fn* (n)" Enter
sleep 0.3
tmux send-keys -t "$SESSION" "    (if (= n 0)" Enter
sleep 0.3
tmux send-keys -t "$SESSION" "      1" Enter
sleep 0.3
tmux send-keys -t "$SESSION" "      (* n (factorial (- n 1))))))" Enter
sleep 0.5
tmux send-keys -t "$SESSION" "(factorial 5)" Enter
sleep 0.5

# Capture and screenshot
tmux capture-pane -t "$SESSION" -p -e | aha --black --style > capture-multiline.html
firefox --headless --window-size=1200,800 \
    --screenshot="$OUTPUT3" \
    "file://$(pwd)/capture-multiline.html"

echo "✓ Multi-line screenshot saved to: $OUTPUT3"

# Cleanup
tmux kill-session -t "$SESSION"
rm -f capture-multiline.html

echo ""
echo "Validation complete! Check screenshots/ directory for results."