#!/bin/sh
# screenshot.sh - Main screenshot utility for MAL project

# Usage: ./scripts/screenshot.sh [type] [output_name]
# Types: gui, terminal, tmux, workspace

TYPE="${1:-gui}"
OUTPUT="${2:-screenshots/mal-screenshot-$(date +%Y%m%d-%H%M%S)}"

case "$TYPE" in
    gui)
        echo "Capturing MAL GUI screenshot..."
        
        # Start Xvfb
        Xvfb :99 -screen 0 1280x1024x24 &
        XVFB_PID=$!
        export DISPLAY=:99
        sleep 2
        
        # Start Emacs GUI
        emacs -Q -l mal-mode.el examples/macros.mal \
            --eval "(set-frame-size (selected-frame) 120 40)" \
            --eval "(load-theme 'wombat t)" &
        EMACS_PID=$!
        sleep 5
        
        # Capture
        import -window root "${OUTPUT}.png"
        
        # Cleanup
        kill $EMACS_PID $XVFB_PID 2>/dev/null
        echo "Saved: ${OUTPUT}.png"
        ;;
        
    terminal)
        echo "Capturing MAL terminal session..."
        
        # Use tmux to create a terminal session
        SESSION="mal-capture-$$"
        tmux new-session -d -s "$SESSION" -x 120 -y 40
        
        # Split into panes
        tmux send-keys -t "$SESSION" "emacs -nw -Q -l mal-mode.el examples/macros.mal" C-m
        tmux split-window -h -t "$SESSION" -p 40
        tmux send-keys -t "$SESSION" "ruby mal_minimal.rb" C-m
        sleep 2
        tmux send-keys -t "$SESSION" "(def! x 42)" C-m
        sleep 0.5
        tmux send-keys -t "$SESSION" "(+ x 8)" C-m
        
        # Capture with ANSI codes
        sleep 1
        tmux capture-pane -t "$SESSION" -p -e > capture.ansi
        
        # Convert to HTML
        cat > "${OUTPUT}.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { background: #1a1a1a; padding: 20px; margin: 0; }
.terminal { 
    background: #002b36; 
    color: #839496;
    padding: 20px;
    border-radius: 8px;
    font-family: 'DejaVu Sans Mono', monospace;
    font-size: 14px;
    line-height: 1.4;
    box-shadow: 0 4px 12px rgba(0,0,0,0.5);
}
pre { margin: 0; }
</style>
</head>
<body>
<div class="terminal">
<pre>
EOF
        aha --no-header --black < capture.ansi >> "${OUTPUT}.html"
        echo "</pre></div></body></html>" >> "${OUTPUT}.html"
        
        # Cleanup
        tmux kill-session -t "$SESSION"
        rm -f capture.ansi
        echo "Saved: ${OUTPUT}.html"
        ;;
        
    tmux)
        echo "Capturing MAL tmux development session..."
        
        # Start Xvfb
        Xvfb :99 -screen 0 1400x900x24 &
        XVFB_PID=$!
        export DISPLAY=:99
        sleep 2
        
        # Use xterm (more reliable than urxvt)
        xterm -geometry 180x50 -bg black -fg white \
            -fa "DejaVu Sans Mono" -fs 11 -e bash -c '
            tmux new-session -s mal-dev -d
            tmux send-keys "emacs -nw -Q -l mal-mode.el examples/macros.mal" C-m
            tmux split-window -h -p 40
            tmux send-keys "ruby mal_minimal.rb" C-m
            sleep 1
            tmux send-keys "(def! square (fn* (x) (* x x)))" C-m
            tmux send-keys "(square 5)" C-m
            tmux split-window -v -p 30
            tmux send-keys "git status --short" C-m
            tmux select-pane -t 0
            tmux attach-session -t mal-dev
        ' &
        XTERM_PID=$!
        
        sleep 8
        
        # Capture the xterm window
        WINDOW_ID=$(xwininfo -root -tree | grep -i "xterm" | head -1 | awk '{print $1}')
        if [ -n "$WINDOW_ID" ]; then
            xwd -id "$WINDOW_ID" -out temp.xwd
            magick temp.xwd "${OUTPUT}.png"
            rm -f temp.xwd
        else
            import -window root "${OUTPUT}.png"
        fi
        
        # Cleanup
        kill $XTERM_PID $XVFB_PID 2>/dev/null
        echo "Saved: ${OUTPUT}.png"
        ;;
        
    workspace)
        echo "Capturing MAL workspace..."
        
        # Start Xvfb
        Xvfb :99 -screen 0 1600x1200x24 &
        XVFB_PID=$!
        export DISPLAY=:99
        sleep 2
        
        # Create multi-pane Emacs layout
        emacs -Q -l mal-mode.el \
            --eval '(progn
                (find-file "examples/macros.mal")
                (split-window-right)
                (other-window 1)
                (find-file "examples/functional-patterns.mal")
                (split-window-below)
                (other-window 1)
                (switch-to-buffer "*scratch*")
                (insert ";; MAL Workspace\n\n")
                (insert "(def! test (fn* (x) (* x x)))\n")
                (insert "(test 5) ; => 25\n")
                (other-window 1)
                (set-frame-size (selected-frame) 150 50)
                (load-theme (quote wombat) t))' &
        EMACS_PID=$!
        
        sleep 7
        
        # Capture
        import -window root "${OUTPUT}.png"
        
        # Cleanup
        kill $EMACS_PID $XVFB_PID 2>/dev/null
        echo "Saved: ${OUTPUT}.png"
        ;;
        
    *)
        echo "Usage: $0 [gui|terminal|tmux|workspace] [output_name]"
        echo ""
        echo "Types:"
        echo "  gui       - Emacs GUI with MAL mode"
        echo "  terminal  - Terminal session with tmux panes" 
        echo "  tmux      - Full tmux development environment"
        echo "  workspace - Multi-pane Emacs workspace"
        exit 1
        ;;
esac