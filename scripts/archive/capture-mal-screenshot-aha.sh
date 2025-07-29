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