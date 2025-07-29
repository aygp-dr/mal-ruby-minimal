# MAL Screenshot Documentation

This directory contains screenshots and visualizations of the MAL Ruby Minimal project, demonstrating various aspects of the development environment and workflow.

## Available Screenshots

### REPL Display Validation
- `test-capture.html` - Basic MAL REPL interaction showing the banner and simple expressions
- `mal-mode-test.html` - Emacs with mal-mode.el active, showing syntax highlighting

### Development Workflow
- `mal-eshell-workflow-*.html` - Split-screen Emacs setup with:
  - Top: MAL code editor with mal-mode syntax highlighting
  - Bottom: Eshell running MAL REPL for interactive testing

### X11 Tests
- `xvfb-test.png` - Test of Xvfb screenshot capability

## Viewing HTML Files

The HTML files can be viewed in any web browser:
```bash
firefox screenshots/mal-eshell-workflow-*.html
```

Or served locally:
```bash
cd screenshots
python3 -m http.server 8000
# Then visit http://localhost:8000
```

## Screenshot Scripts

Scripts for generating these screenshots are in the `scripts/` directory:

- `capture-mal-terminal.sh` - Capture terminal sessions as HTML
- `capture-eshell-workflow.sh` - Capture Emacs eshell workflow
- `capture-mal-xvfb.sh` - Use Xvfb for X11 screenshots
- `test-mal-tui-capture.sh` - Test all capture methods

## Technologies Used

1. **tmux** - Terminal multiplexer for session management
2. **aha** - ANSI to HTML converter
3. **Xvfb** - Virtual framebuffer for headless X11
4. **Firefox** - Headless browser for HTML to PNG conversion
5. **ImageMagick** - Image manipulation (import command)

## Regenerating Screenshots

To regenerate all screenshots:
```bash
make -C experiments/011-mal-tui-validation capture-screenshots
```

Or individually:
```bash
bash scripts/capture-eshell-workflow.sh
```

## Future Enhancements

- Animated GIFs using asciinema + agg
- Side-by-side comparisons of different modes
- Error handling demonstrations
- Performance profiling visualizations