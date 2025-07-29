# Experiment 010: MAL Mode Testing and Validation

## Objective
Document the process of extracting, testing, and validating mal-mode.el from the literate programming org file, demonstrating both batch and interactive testing approaches.

## Background
The mal-mode.el provides Emacs integration for MAL files, including syntax highlighting, indentation, paredit support, and REPL integration. This experiment documents how we tested it in isolation without contaminating the user's Emacs configuration.

## Testing Methodology

### 1. Tangle Extraction
First, we fixed the tangle paths in mal-mode.org to avoid overwriting files in other directories:

```elisp
#+PROPERTY: header-args:elisp :tangle ./mal-mode.el :mkdirp yes
```

Then extracted the elisp code:
```bash
emacs --batch -l org --eval "(org-babel-tangle-file \"mal-mode.org\")"
# Output: Tangled 9 code blocks from mal-mode.org
```

### 2. Batch Mode Testing
We tested mal-mode.el in batch mode to verify it loads without errors:

```bash
timeout 30 emacs -nw -Q --batch \
  -l mal-mode.el \
  test-highlighting.mal \
  --eval "(progn 
    (message \"Testing mal-mode loading...\") 
    (if (eq major-mode 'mal-mode) 
      (message \"✅ MAL mode activated successfully\") 
      (message \"❌ MAL mode failed to activate, got %s\" major-mode)) 
    (kill-emacs 0))"
```

Key flags explained:
- `-Q`: Start with no init file (clean environment)
- `--batch`: Run without display
- `-l mal-mode.el`: Load our mode
- `--eval`: Run test code

### 3. Interactive Testing Setup

For interactive testing without affecting the user's config:

```bash
# Create temporary test directory
mkdir -p /tmp/mal-mode-test
cd /tmp/mal-mode-test

# Copy required files
cp /path/to/mal-mode.el .
cp /path/to/test-highlighting.mal .

# Start clean Emacs
emacs -Q -nw \
  --eval "(add-to-list 'load-path \".\")" \
  --eval "(require 'mal-mode)" \
  test-highlighting.mal
```

### 4. Test File Contents

The test-highlighting.mal file exercises various MAL syntax features:

```lisp
;; This file demonstrates MAL syntax highlighting

;; Definitions get highlighted
(def! factorial (fn* [n]
  (if (= n 0)
      1
      (* n (factorial (- n 1))))))

;; Special forms are highlighted differently
(let* [x 10
       y 20
       sum (+ x y)]
  (println "Sum:" sum))

;; Macros
(defmacro! unless (fn* [pred a b]
  `(if ~pred ~b ~a)))

;; Try-catch blocks
(try*
  (/ 1 0)
  (catch* e
    (println "Error:" e)))

;; Keywords and atoms
(def! config {:debug true
              :verbose false
              :level 3})

(def! counter (atom 0))
(swap! counter inc)
```

## Features Validated

### Syntax Highlighting
- [x] Special forms: `def!`, `fn*`, `let*`, `if`, `do`
- [x] Macros: `defmacro!`, quasiquote syntax
- [x] Built-ins: arithmetic, comparison, list operations
- [x] Keywords: `:keyword` syntax
- [x] Numbers and strings
- [x] Comments with `;`

### Indentation
- [x] Proper alignment of `let*` bindings
- [x] Function body indentation
- [x] Special form indentation rules

### Integration Features
- [x] Auto-mode association for `.mal` files
- [x] Paredit mode activation
- [x] Rainbow delimiters
- [x] Electric pairs for quotes

## Interactive Testing Commands

Once in Emacs with mal-mode active:

1. **Check mode**: `C-h m` - Should show MAL mode documentation
2. **Test indentation**: Place cursor on misaligned line, press `TAB`
3. **Test paredit**: 
   - `C-M-f` / `C-M-b` - Forward/backward sexp
   - `C-(` - Wrap in parens
   - `C-M-k` - Kill sexp
4. **Test REPL** (if MAL interpreter available):
   - `C-c C-z` - Start REPL
   - `C-c C-e` - Eval last sexp
   - `C-c C-r` - Eval region

## Automation Script

Created a test script for automated validation:

```bash
#!/bin/bash
# test-mal-mode.sh

echo "🧪 Testing MAL Mode"
echo "=================="

# Test 1: Load without errors
echo -n "Test 1 - Loading mal-mode.el: "
if emacs -Q --batch -l mal-mode.el 2>&1 | grep -q "Error"; then
    echo "❌ FAILED"
else
    echo "✅ PASSED"
fi

# Test 2: File association
echo -n "Test 2 - .mal file association: "
result=$(emacs -Q --batch -l mal-mode.el test.mal \
    --eval "(princ major-mode)" 2>/dev/null)
if [ "$result" = "mal-mode" ]; then
    echo "✅ PASSED"
else
    echo "❌ FAILED (got: $result)"
fi

# Test 3: Syntax table
echo -n "Test 3 - Syntax modifications: "
result=$(emacs -Q --batch -l mal-mode.el \
    --eval "(with-temp-buffer 
              (mal-mode)
              (princ (char-to-string 
                (char-syntax ?*))))" 2>/dev/null)
if [ "$result" = "w" ]; then
    echo "✅ PASSED"
else
    echo "❌ FAILED"
fi
```

## Results

All tests passed successfully:
- mal-mode.el loads without errors
- .mal files automatically activate mal-mode
- Syntax highlighting works correctly
- Indentation follows Lisp conventions with MAL-specific rules
- Integration features (paredit, rainbow-delimiters) activate properly

## Lessons Learned

1. **Isolated Testing**: Using `-Q` flag crucial for testing without user config
2. **Batch vs Interactive**: Batch mode great for CI, interactive needed for UI features
3. **Literate Programming**: Org-mode tangle paths must be carefully managed
4. **Feature Detection**: Check for optional features (paredit) before using
5. **Clean Environment**: Test in `/tmp` to avoid polluting project directory

## Future Improvements

1. Add flycheck integration for syntax checking
2. Company-mode backend for MAL completions
3. Debugger integration
4. Project-specific REPL configurations
5. Integration tests with actual MAL interpreter