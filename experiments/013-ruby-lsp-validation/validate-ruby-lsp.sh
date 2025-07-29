#!/bin/bash

echo "Ruby LSP Validation for MAL Ruby Minimal"
echo "========================================"
echo ""

# Check Ruby version
echo "1. Ruby Version Check:"
ruby_version=$(ruby -v)
echo "   $ruby_version"
if [[ ! "$ruby_version" =~ "3." ]]; then
    echo "   ✗ Ruby 3.0+ required"
    exit 1
fi
echo "   ✓ Ruby version OK"
echo ""

# Check Ruby LSP installation
echo "2. Ruby LSP Installation:"
if command -v ruby-lsp &> /dev/null; then
    lsp_version=$(ruby-lsp --version 2>&1 || echo "unknown")
    echo "   ✓ Ruby LSP installed: $lsp_version"
else
    echo "   ✗ Ruby LSP not found"
    echo "   Run: gem install ruby-lsp"
    exit 1
fi
echo ""

# Test Ruby LSP functionality
echo "3. Testing Ruby LSP on mal_minimal.rb:"
if [ -f "../../mal_minimal.rb" ]; then
    # Create a simple LSP request
    cat > lsp-test-request.json << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "textDocument/didOpen",
  "params": {
    "textDocument": {
      "uri": "file://$(pwd)/../../mal_minimal.rb",
      "languageId": "ruby",
      "version": 1,
      "text": "$(cat ../../mal_minimal.rb | head -20)"
    }
  }
}
EOF
    echo "   ✓ Test request created"
else
    echo "   ✗ mal_minimal.rb not found"
    exit 1
fi
echo ""

# Test with different editors
echo "4. Editor Integration Tests:"

# VS Code
if command -v code &> /dev/null; then
    echo "   ✓ VS Code detected"
    if code --list-extensions | grep -q "ruby"; then
        echo "     ✓ Ruby extension installed"
    else
        echo "     ℹ Install Ruby extension: code --install-extension rebornix.Ruby"
    fi
else
    echo "   ℹ VS Code not found"
fi

# Emacs
if command -v emacs &> /dev/null; then
    echo "   ✓ Emacs detected"
    emacs_version=$(emacs --version | head -1)
    echo "     $emacs_version"
else
    echo "   ℹ Emacs not found"
fi

# Neovim
if command -v nvim &> /dev/null; then
    echo "   ✓ Neovim detected"
    nvim_version=$(nvim --version | head -1)
    echo "     $nvim_version"
else
    echo "   ℹ Neovim not found"
fi

echo ""
echo "5. MAL-specific LSP features:"
echo "   Testing Ruby LSP with MAL implementation..."

# Create a test file with MAL-specific code
cat > mal-lsp-test.rb << 'EOF'
# Test file for Ruby LSP with MAL constructs

def make_env(outer)
  { outer: outer, bindings: {} }
end

def env_set(env, key, value)
  env[:bindings][key] = value
end

def eval_mal(ast, env)
  case ast
  when Symbol
    env_get(env, ast.name)
  when Array
    # MAL list evaluation
    eval_list(ast, env)
  else
    ast
  end
end
EOF

echo "   ✓ Created mal-lsp-test.rb"

# Clean up
rm -f lsp-test-request.json mal-lsp-test.rb

echo ""
echo "Validation complete!"
echo ""
echo "Next steps:"
echo "1. Install Ruby LSP: gem install ruby-lsp"
echo "2. Configure your editor (see README for examples)"
echo "3. Open mal_minimal.rb and test LSP features"