#!/bin/bash
# capture-tui-with-asciinema.sh

SESSION_NAME="mal-screenshot-$$"
OUTPUT_FILE="${1:-screenshot.png}"
MAL_FILE="${2:-examples/macros.mal}"

# Record with asciinema
asciinema rec -c "tmux new-session -s $SESSION_NAME \
    'emacs -nw -Q -l mal-mode.el $MAL_FILE; sleep 5'" \
    --idle-time-limit 1 recording.cast

# Convert to GIF/PNG using asciicast2gif or svg-term-cli
svg-term --cast recording.cast --out recording.svg
convert recording.svg "$OUTPUT_FILE"

# Or use asciicast2gif
# docker run --rm -v $PWD:/data asciinema/asciicast2gif \
#     -s 2 -t solarized-dark recording.cast recording.gif

# Cleanup
rm -f recording.cast recording.svg
