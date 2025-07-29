#!/bin/bash
# Setup script for Ruby LSP and development environment

set -e

echo "Setting up Ruby LSP for MAL Ruby Minimal development..."
echo ""

# Check Ruby version
RUBY_VERSION=$(ruby -v | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Ruby version: $RUBY_VERSION"

if [[ "$RUBY_VERSION" < "3.0.0" ]]; then
    echo "Error: Ruby 3.0+ required"
    exit 1
fi

# Install Ruby LSP
echo ""
echo "Installing Ruby LSP..."
if command -v gem &> /dev/null; then
    gem install ruby-lsp
    echo "✓ Ruby LSP installed"
else
    echo "Error: gem command not found"
    exit 1
fi

# Install development dependencies
if [ -f "Gemfile" ]; then
    echo ""
    echo "Installing project dependencies..."
    if command -v bundle &> /dev/null; then
        bundle install
    else
        echo "Installing bundler..."
        gem install bundler
        bundle install
    fi
    echo "✓ Dependencies installed"
fi

# Setup Emacs packages (if Emacs is installed)
if command -v emacs &> /dev/null; then
    echo ""
    echo "Setting up Emacs packages..."
    emacs --batch --eval "(progn
      (require 'package)
      (add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)
      (package-initialize)
      (package-refresh-contents)
      (dolist (pkg '(eglot inf-ruby projectile which-key company flycheck magit paredit rainbow-delimiters))
        (unless (package-installed-p pkg)
          (package-install pkg)))
      (message \"Emacs packages installed\"))" 2>/dev/null
    echo "✓ Emacs packages configured"
fi

# Create .dir-locals.el for project-specific Emacs settings
cat > .dir-locals.el <<'EOF'
;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

((ruby-mode
  (eval . (progn
            (require 'mal-ruby-minimal nil t)
            (mal-ruby-mode 1))))
 (mal-mode
  (eval . (progn
            (paredit-mode 1)
            (rainbow-delimiters-mode 1)))))
EOF
echo "✓ Created .dir-locals.el"

# Test Ruby LSP
echo ""
echo "Testing Ruby LSP..."
if ruby-lsp --version &> /dev/null; then
    echo "✓ Ruby LSP version: $(ruby-lsp --version)"
else
    echo "✗ Ruby LSP test failed"
fi

# Create VS Code settings (optional)
if [ ! -d ".vscode" ]; then
    mkdir -p .vscode
    cat > .vscode/settings.json <<'EOF'
{
    "ruby.useBundler": true,
    "ruby.useLanguageServer": true,
    "ruby.lint": {
        "rubocop": false
    },
    "files.associations": {
        "*.mal": "clojure"
    },
    "editor.rulers": [80],
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true
}
EOF
    echo "✓ Created VS Code settings"
fi

echo ""
echo "Setup complete!"
echo ""
echo "For Emacs users:"
echo "  1. Start Emacs: emacs -l mal-ruby-minimal.el"
echo "  2. Open a Ruby file"
echo "  3. Ruby LSP should start automatically"
echo "  4. Use C-c C-z to start MAL REPL"
echo ""
echo "For VS Code users:"
echo "  1. Install Ruby LSP extension"
echo "  2. Open the project folder"
echo "  3. Ruby LSP should start automatically"
echo ""
echo "To test: make test-emacs"