#!/bin/sh
# test-xvfb-setup.sh

echo "Testing Xvfb setup..."

# Test 1: Basic X11 app
Xvfb :99 -screen 0 800x600x24 &
XVFB_PID=$!
export DISPLAY=:99
sleep 1

xclock &
XCLOCK_PID=$!
sleep 1

import -window root test-xclock.png
kill $XCLOCK_PID $XVFB_PID

# Test 2: Check available fonts
Xvfb :99 -screen 0 800x600x24 &
XVFB_PID=$!
export DISPLAY=:99
xlsfonts | head -20
kill $XVFB_PID

echo "Test complete. Check test-xclock.png"