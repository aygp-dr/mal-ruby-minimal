#!/bin/sh
# capture-mal-emacs-gui.sh

# Configuration
MAL_FILE="${1:-examples/macros.mal}"
OUTPUT_NAME="${2:-mal-emacs-gui}"
DISPLAY_NUM=":99"
RESOLUTION="1280x1024x24"

echo "Starting GUI capture of $MAL_FILE..."

# Start Xvfb
Xvfb $DISPLAY_NUM -screen 0 $RESOLUTION &
XVFB_PID=$!
export DISPLAY=$DISPLAY_NUM

# Wait for Xvfb
sleep 2

# Start Emacs GUI with MAL mode
emacs -Q -l mal-mode.el "$MAL_FILE" \
    --eval "(set-frame-size (selected-frame) 120 40)" \
    --eval "(load-theme 'wombat t)" &
EMACS_PID=$!

# Wait for Emacs to fully load
sleep 5

# Method 1: Direct root window capture
import -window root "${OUTPUT_NAME}-full.png"

# Method 2: Using xwd + magick (ImageMagick 7)
xwd -root -out screenshot.xwd
magick screenshot.xwd "${OUTPUT_NAME}-xwd.png"

# Method 3: Capture specific Emacs window
WINDOW_ID=$(xwininfo -root -tree | grep -i "emacs" | grep -v grep | head -1 | awk '{print $1}')
if [ -n "$WINDOW_ID" ]; then
    import -window "$WINDOW_ID" "${OUTPUT_NAME}-window.png"
    echo "Captured Emacs window: $WINDOW_ID"
fi

# Method 4: High quality with xwd
if [ -n "$WINDOW_ID" ]; then
    xwd -id "$WINDOW_ID" -out emacs-window.xwd
    magick emacs-window.xwd -quality 100 "${OUTPUT_NAME}-hq.png"
    rm -f emacs-window.xwd
fi

# Cleanup
kill $EMACS_PID 2>/dev/null
kill $XVFB_PID 2>/dev/null
rm -f screenshot.xwd

echo "Screenshots saved:"
ls -la ${OUTPUT_NAME}*.png
