#!/bin/sh
# capture-mal-dev-environment.sh

# Start Xvfb
Xvfb :99 -screen 0 1400x900x24 &
XVFB_PID=$!
export DISPLAY=:99
sleep 2

# Set a nice desktop background
xsetroot -solid '#2d2d2d'

# Start a terminal emulator with tmux session
# Install: sudo pkg install xterm or rxvt-unicode
xterm -geometry 180x50 -bg black -fg white -fa 'DejaVu Sans Mono' -fs 11 -e '
    tmux new-session -s mal-dev \; \
    send-keys "emacs -nw -Q -l mal-mode.el examples/macros.mal" C-m \; \
    split-window -h -p 40 \; \
    send-keys "ruby mal_minimal.rb" C-m \; \
    send-keys "(def! x 42)" C-m \; \
    send-keys "(print \"x = \")" C-m \; \
    send-keys "(print x)" C-m \; \
    split-window -v -p 30 \; \
    send-keys "make test | head -20" C-m \; \
    select-pane -t 0
' &
XTERM_PID=$!

# Wait for everything to load
sleep 8

# Capture the terminal
import -window root mal-dev-environment.png

# Also capture just the xterm window
WINDOW_ID=$(xwininfo -root -tree | grep -i "xterm" | head -1 | awk '{print $1}')
if [ -n "$WINDOW_ID" ]; then
    import -window "$WINDOW_ID" mal-terminal-only.png
fi

kill $XTERM_PID $XVFB_PID