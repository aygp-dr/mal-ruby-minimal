#!/bin/sh
# Capture MAL terminal session as HTML/image

SESSION="mal-capture-$$"
FILE="${1:-examples/macros.mal}"
HTML_OUTPUT="screenshots/mal-terminal-$(date +%Y%m%d-%H%M%S).html"
PNG_OUTPUT="screenshots/mal-terminal-$(date +%Y%m%d-%H%M%S).png"

echo "Capturing terminal session for $FILE..."

# Start tmux session with MAL file
tmux new-session -d -s "$SESSION" -x 80 -y 24 \
    "emacs -nw -Q -l mal-mode.el $FILE"

# Wait for initialization
sleep 3

# Capture the pane with ANSI codes
tmux capture-pane -t "$SESSION" -p -e > capture.ansi

# Create HTML with proper terminal styling
cat > "$HTML_OUTPUT" << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap');
body { 
    background: #1e1e1e; 
    padding: 0;
    margin: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
}
.terminal {
    background: #002b36;
    border: 2px solid #586e75;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.5);
}
pre { 
    margin: 0; 
    font-family: 'JetBrains Mono', 'DejaVu Sans Mono', monospace;
    font-size: 14px;
    line-height: 1.4;
    color: #839496;
}
.ansi-bright-green { color: #859900; }
.ansi-bright-blue { color: #268bd2; }
.ansi-bright-cyan { color: #2aa198; }
.ansi-bright-magenta { color: #d33682; }
.ansi-bright-yellow { color: #b58900; }
</style>
</head>
<body>
<div class="terminal">
<pre>
HTML_HEADER

# Convert ANSI to HTML
aha --no-header --black < capture.ansi >> "$HTML_OUTPUT"

cat >> "$HTML_OUTPUT" << 'HTML_FOOTER'
</pre>
</div>
</body>
</html>
HTML_FOOTER

echo "HTML output saved to: $HTML_OUTPUT"

# If Xvfb is available, convert HTML to PNG
if which Xvfb >/dev/null 2>&1 && which firefox >/dev/null 2>&1; then
    echo "Converting to PNG using Xvfb..."
    
    # Start Xvfb
    Xvfb :99 -screen 0 1280x800x24 &
    XVFB_PID=$!
    export DISPLAY=:99
    sleep 2
    
    # Take screenshot with Firefox
    firefox --headless --screenshot="$PNG_OUTPUT" \
        "file://$(pwd)/$HTML_OUTPUT" \
        --window-size=1280,800 2>/dev/null
    
    # Cleanup Xvfb
    kill $XVFB_PID 2>/dev/null
    
    echo "PNG output saved to: $PNG_OUTPUT"
else
    echo "Note: Install Xvfb and Firefox to generate PNG screenshots"
fi

# Cleanup
tmux kill-session -t "$SESSION" 2>/dev/null
rm -f capture.ansi

echo "Capture complete!"