#!/bin/sh
# Capture animated GIF of MAL interaction

OUTPUT="${1:-screenshots/mal-demo-$(date +%Y%m%d-%H%M%S).gif}"

echo "Recording MAL demo..."

# Record 10 second demo
asciinema rec -c "tmux new-session 'emacs -nw -Q -l mal-mode.el examples/test-simple.mal; sleep 10'" \
    --quiet \
    --idle-time-limit 2 \
    recording.cast

# Convert to GIF
agg recording.cast "$OUTPUT" \
    --font-family "DejaVu Sans Mono" \
    --font-size 14 \
    --theme solarized-dark

# Cleanup
rm -f recording.cast

echo "GIF saved to: $OUTPUT"