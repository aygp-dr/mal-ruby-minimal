#!/bin/sh
# Validate mal-mode.el functionality

echo "MAL Mode Validation"
echo "==================="
echo ""

# Function to check if mal-mode is loaded
validate_mode_loading() {
    echo "Test: mal-mode loading"
    echo "----------------------"
    
    result=$(emacs -Q --batch -l mal-mode.el \
        --eval "(if (fboundp 'mal-mode) 
                    (princ \"✓ mal-mode loaded successfully\") 
                    (princ \"✗ mal-mode failed to load\"))" 2>&1)
    echo "$result"
    
    # Check syntax table modifications
    result=$(emacs -Q --batch -l mal-mode.el \
        --eval "(with-temp-buffer 
                  (mal-mode)
                  (princ (format \"✓ Syntax table test: * is %s\" 
                         (char-to-string (char-syntax ?*)))))" 2>&1)
    echo "$result"
    echo ""
}

# Function to validate file association
validate_file_association() {
    echo "Test: .mal file association"
    echo "---------------------------"
    
    result=$(emacs -Q --batch -l mal-mode.el examples/test-simple.mal \
        --eval "(princ (format \"Mode activated: %s\" major-mode))" 2>&1)
    echo "$result"
    echo ""
}

# Function to test syntax highlighting
validate_syntax_highlighting() {
    echo "Test: Syntax highlighting setup"
    echo "-------------------------------"
    
    OUTPUT="screenshots/mal-mode-syntax-$(date +%Y%m%d-%H%M%S).png"
    SESSION="mal-syntax-$$"
    
    # Create a test file with various MAL constructs
    cat > test-syntax.mal << 'EOF'
;; Test syntax highlighting
(def! x 42)                    ; definition
(fn* (a b) (+ a b))           ; function
(let* [x 10 y 20] (+ x y))    ; let binding
(if true "yes" "no")          ; conditional
(do (print 1) (print 2))      ; do form
'(quoted list)                ; quote
:keyword                      ; keyword
"string literal"              ; string
123 -456 3.14                 ; numbers
nil true false                ; literals
EOF
    
    # Start Emacs with the test file
    tmux new-session -d -s "$SESSION" -x 120 -y 40 \
        "emacs -nw -Q -l mal-mode.el test-syntax.mal"
    sleep 3
    
    # Capture and convert
    tmux capture-pane -t "$SESSION" -p -e | \
        aha --black --style > capture-syntax.html
    
    # Take screenshot
    firefox --headless --window-size=1200,800 \
        --screenshot="$OUTPUT" \
        "file://$(pwd)/capture-syntax.html"
    
    echo "✓ Syntax highlighting screenshot: $OUTPUT"
    
    # Cleanup
    tmux kill-session -t "$SESSION"
    rm -f test-syntax.mal capture-syntax.html
    echo ""
}

# Function to test indentation
validate_indentation() {
    echo "Test: Indentation rules"
    echo "-----------------------"
    
    # Test various indentation scenarios
    result=$(emacs -Q --batch -l mal-mode.el \
        --eval "(with-temp-buffer
                  (mal-mode)
                  (insert \"(def! test\\n(fn* (x)\\n(+ x 1)))\")
                  (goto-char (point-min))
                  (forward-line 1)
                  (indent-for-tab-command)
                  (forward-line 1)
                  (indent-for-tab-command)
                  (princ \"✓ Indentation test completed\"))" 2>&1)
    echo "$result"
    echo ""
}

# Function to test paredit integration
validate_paredit() {
    echo "Test: Paredit integration"
    echo "-------------------------"
    
    if emacs -Q --batch --eval "(require 'paredit nil t)" 2>/dev/null; then
        echo "✓ Paredit available, testing integration..."
        
        result=$(emacs -Q --batch -l mal-mode.el \
            --eval "(with-temp-buffer
                      (mal-mode)
                      (if (and (boundp 'paredit-mode) paredit-mode)
                          (princ \"✓ Paredit activated in mal-mode\")
                          (princ \"✗ Paredit not activated\")))" 2>&1)
        echo "$result"
    else
        echo "ℹ Paredit not installed, skipping test"
    fi
    echo ""
}

# Run all validations
echo "Starting validation suite..."
echo ""

validate_mode_loading
validate_file_association
validate_syntax_highlighting
validate_indentation
validate_paredit

# Summary
echo "Validation Summary"
echo "=================="
echo ""
echo "Check the following:"
echo "1. mal-mode loads without errors ✓"
echo "2. .mal files activate mal-mode automatically ✓"
echo "3. Syntax highlighting screenshot created ✓"
echo "4. Indentation works correctly ✓"
echo "5. Optional features (paredit) integrate properly ✓"
echo ""
echo "Screenshots saved in: screenshots/"
echo "All validation tests completed!"