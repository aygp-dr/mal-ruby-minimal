#!/bin/sh
# Capture Emacs eshell workflow with MAL REPL and code

OUTPUT="${1:-screenshots/mal-eshell-workflow-$(date +%Y%m%d-%H%M%S).html}"
PNG_OUTPUT="${OUTPUT%.html}.png"

echo "Creating eshell workflow capture..."

# Create a minimal example file for the workflow
cat > examples/workflow-example.mal << 'EOF'
;; Fibonacci sequence generator
(def! fib (fn* (n)
  (if (<= n 1)
    n
    (+ (fib (- n 1)) 
       (fib (- n 2))))))

;; Test the function
(print "fib(5) = ")
(print (fib 5))
(print "\n")

;; List of first 10 fibonacci numbers
(def! fib-list (fn* (n)
  (if (= n 0)
    '()
    (cons (fib n) (fib-list (- n 1))))))

(print "First 5 fibs: ")
(print (reverse (fib-list 5)))
EOF

# Create Emacs init file for the workflow
cat > workflow-init.el << 'EOF'
;; Load mal-mode
(load-file "mal-mode.el")

;; Split window configuration
(defun setup-mal-workflow ()
  "Setup MAL workflow with eshell and code"
  (interactive)
  ;; Open the example file
  (find-file "examples/workflow-example.mal")
  ;; Split window horizontally
  (split-window-below)
  ;; Move to bottom window
  (other-window 1)
  ;; Start eshell
  (eshell)
  ;; Run MAL REPL in eshell
  (insert "ruby mal_minimal.rb")
  (eshell-send-input)
  ;; Wait for REPL to start
  (sit-for 2)
  ;; Send some example commands
  (insert "(def! square (fn* (x) (* x x)))")
  (eshell-send-input)
  (sit-for 0.5)
  (insert "(square 5)")
  (eshell-send-input)
  ;; Switch back to code window
  (other-window 1))

;; Run setup after a short delay
(run-with-timer 1 nil 'setup-mal-workflow)
EOF

# Start tmux session with Emacs
SESSION="eshell-workflow-$$"
tmux new-session -d -s "$SESSION" -x 100 -y 40 \
    "emacs -nw -Q -l workflow-init.el"

# Wait for setup to complete
sleep 5

# Capture the session
tmux capture-pane -t "$SESSION" -p -e > workflow-capture.ansi

# Convert to styled HTML
cat > "$OUTPUT" << 'HTML_HEADER'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>MAL Eshell Workflow</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Fira+Code&display=swap');
body { 
    background: #1a1a1a; 
    padding: 20px;
    margin: 0;
    font-family: 'Fira Code', monospace;
}
.workflow-container {
    max-width: 1200px;
    margin: 0 auto;
}
.terminal {
    background: #002b36;
    border: 2px solid #586e75;
    border-radius: 8px;
    padding: 16px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.6);
    overflow-x: auto;
}
pre { 
    margin: 0; 
    font-size: 13px;
    line-height: 1.4;
    color: #839496;
    white-space: pre;
}
h1 {
    color: #93a1a1;
    text-align: center;
    margin-bottom: 20px;
}
.description {
    color: #657b83;
    text-align: center;
    margin-bottom: 30px;
}
</style>
</head>
<body>
<div class="workflow-container">
<h1>MAL Development Workflow</h1>
<p class="description">Emacs with mal-mode (top) and eshell running MAL REPL (bottom)</p>
<div class="terminal">
<pre>
HTML_HEADER

# Add the captured content
aha --no-header --black < workflow-capture.ansi >> "$OUTPUT"

cat >> "$OUTPUT" << 'HTML_FOOTER'
</pre>
</div>
</div>
</body>
</html>
HTML_FOOTER

echo "✓ HTML workflow saved to: $OUTPUT"

# Convert to PNG if possible
if which Xvfb >/dev/null 2>&1 && which firefox >/dev/null 2>&1; then
    Xvfb :99 -screen 0 1400x900x24 &
    XVFB_PID=$!
    export DISPLAY=:99
    sleep 2
    
    firefox --headless --screenshot="$PNG_OUTPUT" \
        "file://$(pwd)/$OUTPUT" \
        --window-size=1400,900 2>/dev/null
    
    kill $XVFB_PID 2>/dev/null
    echo "✓ PNG workflow saved to: $PNG_OUTPUT"
fi

# Cleanup
tmux kill-session -t "$SESSION" 2>/dev/null
rm -f workflow-capture.ansi workflow-init.el

echo "Workflow capture complete!"