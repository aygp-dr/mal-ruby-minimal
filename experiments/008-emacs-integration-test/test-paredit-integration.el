;;; test-paredit-integration.el --- Test paredit with MAL files -*- lexical-binding: t; -*-

;; This file specifically tests paredit functionality with MAL files

;;; Code:

;; Load the MAL Ruby configuration
(let ((mal-config (expand-file-name "../../mal-ruby-minimal.el" 
                                   (file-name-directory load-file-name))))
  (load mal-config))

;; Test paredit operations on MAL code
(defun test-paredit-operations ()
  "Test various paredit operations on MAL code."
  (let ((test-buffer (generate-new-buffer "*mal-paredit-test*")))
    (with-current-buffer test-buffer
      (mal-mode)
      (paredit-mode 1)
      
      ;; Test 1: Basic sexp navigation
      (insert "(def! factorial (fn* (n) (if (= n 0) 1 (* n (factorial (- n 1))))))")
      (goto-char (point-min))
      
      ;; Test forward-sexp
      (paredit-forward)
      (if (= (point) (point-max))
          (message "✅ Paredit Test 1: Forward sexp navigation works")
        (message "❌ Paredit Test 1: Forward sexp failed"))
      
      ;; Test 2: Backward sexp
      (paredit-backward)
      (if (= (point) (point-min))
          (message "✅ Paredit Test 2: Backward sexp navigation works")
        (message "❌ Paredit Test 2: Backward sexp failed"))
      
      ;; Test 3: Slurp forward
      (erase-buffer)
      (insert "(+ 1) 2")
      (goto-char 4) ; After the 1
      (paredit-forward-slurp-sexp)
      (if (string= (buffer-string) "(+ 1 2)")
          (message "✅ Paredit Test 3: Forward slurp works")
        (message "❌ Paredit Test 3: Forward slurp failed - got %s" (buffer-string)))
      
      ;; Test 4: Wrap with parens
      (erase-buffer)
      (insert "factorial 5")
      (goto-char (point-min))
      (mark-end-of-word 1)
      (paredit-wrap-round)
      (if (string-match "^(factorial) 5" (buffer-string))
          (message "✅ Paredit Test 4: Wrap with parens works")
        (message "❌ Paredit Test 4: Wrap failed - got %s" (buffer-string)))
      
      ;; Test 5: Split sexp
      (erase-buffer)
      (insert "(+ 1 2 3)")
      (goto-char 6) ; Between 1 and 2
      (paredit-split-sexp)
      (if (string= (buffer-string) "(+ 1) (2 3)")
          (message "✅ Paredit Test 5: Split sexp works")
        (message "❌ Paredit Test 5: Split failed - got %s" (buffer-string)))
      
      ;; Test 6: Raise sexp
      (erase-buffer)
      (insert "(* 2 (+ 3 4))")
      (goto-char 8) ; On the 3
      (paredit-raise-sexp)
      (if (string-match "(\\+ 3 4)" (buffer-string))
          (message "✅ Paredit Test 6: Raise sexp works")
        (message "❌ Paredit Test 6: Raise failed - got %s" (buffer-string)))
      
      (kill-buffer test-buffer))))

;; Test paredit with actual MAL file content
(defun test-paredit-with-mal-files ()
  "Test paredit operations on actual MAL file content."
  (let ((mal-files '("../../experiments/005-sicp-mal/chapter1-procedures.mal"
                     "../../experiments/006-let-over-lambda-mal/closures-advanced.mal"
                     "../../examples/fibonacci.mal")))
    (dolist (file-path mal-files)
      (let ((full-path (expand-file-name file-path (file-name-directory load-file-name))))
        (when (file-exists-p full-path)
          (with-temp-buffer
            (insert-file-contents full-path)
            (mal-mode)
            (paredit-mode 1)
            
            ;; Check if paredit is active
            (if paredit-mode
                (message "✅ Paredit activated for %s" (file-name-nondirectory full-path))
              (message "❌ Paredit failed to activate for %s" (file-name-nondirectory full-path)))
            
            ;; Test balanced parens
            (goto-char (point-min))
            (condition-case nil
                (progn
                  (while (< (point) (point-max))
                    (paredit-forward))
                  (message "✅ Balanced parentheses in %s" (file-name-nondirectory full-path)))
              (error (message "❌ Unbalanced parentheses in %s" (file-name-nondirectory full-path))))))))))

;; Test specific MAL constructs
(defun test-mal-specific-constructs ()
  "Test paredit with MAL-specific constructs."
  (with-temp-buffer
    (mal-mode)
    (paredit-mode 1)
    
    ;; Test def! handling
    (insert "(def! x 42)")
    (goto-char (point-min))
    (paredit-forward-down) ; Into the sexp
    (if (looking-at "def!")
        (message "✅ MAL def! construct recognized")
      (message "❌ MAL def! construct not properly handled"))
    
    ;; Test fn* handling
    (erase-buffer)
    (insert "(fn* (a b) (+ a b))")
    (goto-char (point-min))
    (paredit-forward-down)
    (if (looking-at "fn\\*")
        (message "✅ MAL fn* construct recognized")
      (message "❌ MAL fn* construct not properly handled"))
    
    ;; Test let* handling
    (erase-buffer)
    (insert "(let* (x 1 y 2) (+ x y))")
    (goto-char (point-min))
    (paredit-forward-down)
    (if (looking-at "let\\*")
        (message "✅ MAL let* construct recognized")
      (message "❌ MAL let* construct not properly handled"))))

;; Test rainbow delimiters
(defun test-rainbow-delimiters ()
  "Test rainbow delimiters activation."
  (with-temp-buffer
    (mal-mode)
    (insert "(((()))))")
    (if (bound-and-true-p rainbow-delimiters-mode)
        (message "✅ Rainbow delimiters active in MAL mode")
      (message "❌ Rainbow delimiters not active"))))

;; Run all paredit tests
(defun run-paredit-tests ()
  "Run all paredit integration tests."
  (message "\n🎯 Testing Paredit Integration with MAL...")
  (message "=========================================")
  (test-paredit-operations)
  (test-paredit-with-mal-files)
  (test-mal-specific-constructs)
  (test-rainbow-delimiters)
  (message "=========================================")
  (message "✅ Paredit integration tests completed!\n"))

;; Execute tests
(run-paredit-tests)

;; Interactive test function for manual verification
(defun interactive-paredit-test ()
  "Open a MAL file for interactive paredit testing."
  (interactive)
  (let ((test-content "(def! test-function (fn* (x y)
  (let* (sum (+ x y)
         product (* x y))
    (if (> sum product)
      sum
      product))))"))
    (switch-to-buffer "*MAL Paredit Interactive Test*")
    (erase-buffer)
    (mal-mode)
    (insert test-content)
    (goto-char (point-min))
    (message "Interactive paredit test buffer created. Try C-M-f, C-M-b, C-), C-M-k etc.")))

(provide 'test-paredit-integration)
;;; test-paredit-integration.el ends here