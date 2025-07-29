#!/bin/sh
# capture-mal-tmux-session.sh

# Create a realistic tmux session in terminal
Xvfb :99 -screen 0 1400x900x24 &
XVFB_PID=$!
export DISPLAY=:99
sleep 2

# Nice background
xsetroot -solid '#1a1a1a'

# Use xterm as fallback if urxvt not available
TERM_CMD="xterm -geometry 200x60 -bg '#0c0c0c' -fg '#cccccc' -fa 'DejaVu Sans Mono' -fs 10"
if which urxvt >/dev/null 2>&1; then
    TERM_CMD="urxvt -geometry 200x60 -bg '#0c0c0c' -fg '#cccccc' -fn 'xft:DejaVu Sans Mono:size=10'"
fi

$TERM_CMD -e bash -c '
    # Create tmux session with custom status
    tmux new-session -s mal-dev -d
    tmux set -g status-bg colour235
    tmux set -g status-fg colour246
    tmux set -g status-left "#[fg=colour214] MAL Dev #[default]"
    tmux set -g status-right "#[fg=colour246]%H:%M #[fg=colour214]#(hostname)"
    
    # Main editor pane
    tmux send-keys "emacs -nw -Q -l mal-mode.el examples/functional-patterns.mal" C-m
    sleep 2
    
    # Create REPL pane on the right
    tmux split-window -h -p 35
    tmux send-keys "ruby mal_minimal.rb" C-m
    sleep 1
    tmux send-keys ";; MAL REPL - Testing functional patterns" C-m
    tmux send-keys "(load-file \"examples/test-simple.mal\")" C-m
    sleep 0.5
    tmux send-keys "(+ x 8)" C-m
    
    # Bottom pane for git/tests
    tmux select-pane -t 0
    tmux split-window -v -p 25
    tmux send-keys "git status --short" C-m
    
    # Focus back on editor
    tmux select-pane -t 0
    
    # Attach to session
    tmux attach-session -t mal-dev
' &
TERM_PID=$!

# Let everything render
sleep 10

# Capture with high quality
WINDOW_ID=$(xwininfo -root -tree | grep -E "(urxvt|xterm)" | head -1 | awk '{print $1}')
if [ -n "$WINDOW_ID" ]; then
    # Method 1: xwd for pixel-perfect capture
    xwd -id "$WINDOW_ID" -out mal-session.xwd
    magick mal-session.xwd -quality 100 mal-tmux-session.png
    
    # Method 2: import with frame
    import -window "$WINDOW_ID" -frame mal-tmux-session-framed.png
    
    rm -f mal-session.xwd
fi

kill $TERM_PID $XVFB_PID