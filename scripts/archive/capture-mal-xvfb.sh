#!/bin/sh
# Capture MAL TUI screenshot using Xvfb and ImageMagick

SESSION="mal-xvfb-$$"
FILE="${1:-examples/macros.mal}"
OUTPUT="${2:-screenshots/mal-xvfb-$(date +%Y%m%d-%H%M%S).png}"

echo "Starting Xvfb capture of $FILE..."

# Start Xvfb
Xvfb :99 -screen 0 1280x800x24 &
XVFB_PID=$!
export DISPLAY=:99
sleep 2

# Start terminal emulator in Xvfb
xterm -geometry 120x40 -bg '#002b36' -fg '#839496' -fa 'DejaVu Sans Mono' -fs 12 -e tmux new-session -s "$SESSION" "emacs -nw -Q -l mal-mode.el $FILE" &
XTERM_PID=$!

# Wait for everything to start
sleep 4

# Take screenshot using ImageMagick import
import -window root "$OUTPUT"

# Alternative using xwd
# xwd -root -out screenshot.xwd
# convert screenshot.xwd "$OUTPUT"
# rm -f screenshot.xwd

# Cleanup
kill $XTERM_PID 2>/dev/null
tmux kill-session -t "$SESSION" 2>/dev/null
kill $XVFB_PID 2>/dev/null

echo "Screenshot saved to: $OUTPUT"