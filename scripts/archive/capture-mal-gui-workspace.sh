#!/bin/sh
# capture-mal-gui-workspace.sh

echo "Creating MAL development workspace screenshot..."

# Start Xvfb with larger resolution
Xvfb :99 -screen 0 1600x1200x24 &
XVFB_PID=$!
export DISPLAY=:99
sleep 2

# Start Emacs with complex layout
emacs -Q -l mal-mode.el \
    --eval '(progn
        (find-file "examples/macros.mal")
        (split-window-right)
        (other-window 1)
        (find-file "examples/functional-patterns.mal")
        (split-window-below)
        (other-window 1)
        (switch-to-buffer "*scratch*")
        (insert ";; MAL REPL ready\n")
        (insert "(def! square (fn* (x) (* x x)))\n")
        (insert "(square 5)\n")
        (other-window 1)
        (set-frame-size (selected-frame) 150 50)
        (load-theme (quote wombat) t))' &
EMACS_PID=$!

# Wait longer for complex setup
sleep 7

# Capture with xwd for best quality
WINDOW_ID=$(xwininfo -root -tree | grep -i "emacs" | head -1 | awk '{print $1}')
if [ -n "$WINDOW_ID" ]; then
    xwd -id "$WINDOW_ID" -out workspace.xwd
    magick workspace.xwd -quality 100 mal-workspace.png
    
    # Also create a scaled version for documentation
    magick workspace.xwd -resize 1200x900 -quality 95 mal-workspace-doc.png
    
    rm -f workspace.xwd
    echo "Workspace screenshots saved: mal-workspace.png, mal-workspace-doc.png"
fi

# Cleanup
kill $EMACS_PID 2>/dev/null
kill $XVFB_PID 2>/dev/null