# Screenshot Experiment Results

## Overview

This document summarizes the extensive screenshot capture experiments conducted for the MAL Ruby Minimal project. We tested multiple approaches to capture both terminal-based and GUI-based views of the development environment.

## Tested Approaches

### 1. HTML-based Terminal Capture (aha)
- **Script**: `capture-mal-terminal.sh`
- **Method**: Uses `tmux capture-pane` with ANSI codes, converted to HTML via `aha`
- **Result**: ✅ Success - Clean HTML output with proper syntax highlighting
- **Pros**: No X11 required, preserves exact terminal colors
- **Cons**: Output is HTML, not image format

### 2. Xvfb + Firefox Headless
- **Script**: `capture-mal-screenshot-aha.sh`
- **Method**: HTML to PNG using Firefox headless mode
- **Result**: ⚠️ Partial - Works but requires Firefox
- **Pros**: Produces PNG images
- **Cons**: Requires Firefox, slower

### 3. Xvfb + ImageMagick (import)
- **Script**: `capture-mal-emacs-gui.sh`
- **Method**: Direct X11 window capture using `import`
- **Result**: ✅ Success - High quality GUI screenshots
- **Pros**: Native X11 capture, multiple capture methods
- **Cons**: GUI only, requires Xvfb

### 4. Xvfb + xwd + magick
- **Script**: `capture-mal-gui-states.sh`
- **Method**: X Window Dump converted with ImageMagick 7
- **Result**: ✅ Success - Best quality screenshots
- **Pros**: Pixel-perfect capture, highest quality
- **Cons**: Two-step process

### 5. Terminal Emulator in Xvfb
- **Script**: `capture-mal-dev-environment.sh`, `capture-mal-tmux-session.sh`
- **Method**: xterm/urxvt running tmux in virtual X11
- **Result**: ✅ Success - Most realistic development screenshots
- **Pros**: Shows actual terminal workflow, tmux panes
- **Cons**: More complex setup

## Final Implementation

The consolidated `screenshot.sh` script provides four capture modes:

1. **gui** - Emacs GUI with syntax highlighting
2. **terminal** - Terminal session as HTML
3. **tmux** - Full tmux development environment
4. **workspace** - Multi-pane Emacs workspace

## Key Learnings

1. **Xvfb Reliability**: Works consistently on FreeBSD with proper setup
2. **ImageMagick 7 Syntax**: Use `magick` instead of `convert`
3. **Window ID Capture**: More reliable than root window for specific apps
4. **Font Rendering**: DejaVu Sans Mono provides best results
5. **tmux Integration**: Best represents actual development workflow

## Technical Details

### Dependencies
```bash
# Required packages
sudo pkg install xorg-vfbserver  # Virtual framebuffer
sudo pkg install ImageMagick7    # Image manipulation
sudo pkg install aha             # ANSI to HTML converter
sudo pkg install tmux            # Terminal multiplexer

# Optional for better results
sudo pkg install dejavu          # Better fonts
sudo pkg install xterm           # Reliable terminal emulator
```

### Best Practices

1. **Window Timing**: Allow 5-7 seconds for complex layouts to render
2. **Resolution**: 1280x1024 for single windows, 1600x1200 for workspaces
3. **Color Depth**: 24-bit for best color reproduction
4. **Cleanup**: Always kill Xvfb and application PIDs

### Screenshot Quality Comparison

| Method | Quality | Speed | Reliability | Use Case |
|--------|---------|-------|-------------|----------|
| import (root) | Good | Fast | High | Quick captures |
| xwd + magick | Excellent | Medium | High | Publication quality |
| HTML (aha) | Perfect | Fast | Highest | Documentation |
| Firefox headless | Good | Slow | Medium | When PNG needed from HTML |

## Usage Examples

```bash
# Quick GUI screenshot
./scripts/screenshot.sh gui

# Terminal workflow capture
./scripts/screenshot.sh tmux screenshots/workflow

# Multi-pane workspace
./scripts/screenshot.sh workspace screenshots/ide-view

# Simple terminal session
./scripts/screenshot.sh terminal
```

## Files Created

### Scripts
- `screenshot.sh` - Main unified script (KEPT)
- `capture-mal-emacs-gui.sh` - GUI capture experiments
- `capture-mal-gui-states.sh` - Multiple GUI states
- `capture-mal-dev-environment.sh` - Terminal in X11
- `capture-mal-tmux-session.sh` - tmux session capture
- `capture-mal-gui-workspace.sh` - Complex layouts

### Test Results
- `test-gui.png` - Clean Emacs GUI screenshot
- `test-terminal.html` - Terminal session as HTML
- `test-tmux.png` - Full development environment
- `test-workspace.png` - Multi-pane Emacs layout

## Conclusion

The experiment successfully identified multiple reliable methods for capturing MAL development screenshots. The final `screenshot.sh` script consolidates the best approaches into a single, easy-to-use tool that covers all common use cases.

The tmux-based approach provides the most realistic representation of actual MAL development workflow, while the GUI captures showcase the syntax highlighting capabilities of mal-mode.el.