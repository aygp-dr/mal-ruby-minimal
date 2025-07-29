;;; mal-mode.el --- Major mode for MAL (Make-A-Lisp) files -*- lexical-binding: t; -*-

;; Author: MAL Community
;; Keywords: languages, lisp
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; This package provides a major mode for editing MAL files with:
;; - Syntax highlighting for MAL-specific forms
;; - Proper indentation
;; - Paredit support
;; - REPL integration

;;; Code:

(require 'lisp-mode)
(require 'cl-lib)

;; Define MAL mode
(define-derived-mode mal-mode lisp-mode "MAL"
  "Major mode for editing MAL (Make-A-Lisp) files.
\\{mal-mode-map}"
  ;; Comments
  (setq-local comment-start ";")
  (setq-local comment-end "")
  (setq-local comment-start-skip ";+ *")
  
  ;; Syntax table modifications
  (modify-syntax-entry ?* "w" mal-mode-syntax-table)  ; fn* and let* are symbols
  (modify-syntax-entry ?! "w" mal-mode-syntax-table)  ; def! is a symbol
  (modify-syntax-entry ?? "w" mal-mode-syntax-table)  ; predicates
  (modify-syntax-entry ?- "w" mal-mode-syntax-table)  ; hyphenated names
  
  ;; Font lock
  (setq-local font-lock-defaults
              '(mal-font-lock-keywords
                nil ; keywords-only
                nil ; case-fold
                (("+-*/.<>=!?$%_&~^:" . "w")) ; syntax-alist
                nil ; syntax-begin
                (font-lock-mark-block-function . mark-defun)))
  
  ;; Indentation
  (setq-local lisp-indent-function 'mal-indent-function)
  
  ;; Enable paredit if available
  (when (fboundp 'paredit-mode)
    (paredit-mode 1))
  
  ;; Enable rainbow-delimiters if available
  (when (fboundp 'rainbow-delimiters-mode)
    (rainbow-delimiters-mode 1)))

;; MAL-specific keywords and special forms
(defconst mal-font-lock-keywords
  (eval-when-compile
    `(;; Special forms and definitions
      (,(regexp-opt '("def!" "defmacro!" "let*" "fn*" "do"
                      "if" "when" "cond" "case"
                      "try*" "catch*" "throw"
                      "quote" "quasiquote" "unquote" "splice-unquote"
                      "macroexpand" "macroexpand-1")
                    'symbols)
       . font-lock-keyword-face)
      
      ;; Built-in functions
      (,(regexp-opt '("+" "-" "*" "/" "mod"
                      "=" "<" ">" "<=" ">=" "not="
                      "and" "or" "not"
                      "list" "list?" "empty?" "count" "cons"
                      "concat" "vec" "vector" "nth" "first" "rest"
                      "map" "apply" "filter" "reduce"
                      "atom" "atom?" "deref" "reset!" "swap!"
                      "nil?" "true?" "false?" "symbol?" "number?"
                      "string?" "keyword?" "vector?" "map?" "sequential?"
                      "pr-str" "str" "prn" "println"
                      "read-string" "slurp" "load-file"
                      "assoc" "dissoc" "get" "contains?" "keys" "vals"
                      "time-ms" "conj" "seq" "with-meta" "meta"
                      "readline" "eval")
                    'symbols)
       . font-lock-builtin-face)
      
      ;; Definition names
      ("(\\(def!\\|defmacro!\\)\\s-+\\(\\sw+\\)"
       (1 font-lock-keyword-face)
       (2 font-lock-function-name-face))
      
      ;; Function names in fn* forms
      ("(\\(fn\\*\\)\\s-+\\(\\sw+\\)?"
       (1 font-lock-keyword-face)
       (2 font-lock-function-name-face nil t))
      
      ;; let* bindings
      ("(\\(let\\*\\)\\s-*\\["
       (1 font-lock-keyword-face))
      
      ;; Keywords
      (":\\sw+" . font-lock-constant-face)
      
      ;; Numbers
      ("\\b[0-9]+\\(\\.[0-9]+\\)?\\b" . font-lock-constant-face)
      
      ;; Special values
      (,(regexp-opt '("nil" "true" "false") 'symbols)
       . font-lock-constant-face)))
  "Font lock keywords for MAL mode.")

;; Indentation specifications for MAL forms
(defvar mal-indent-rules
  '((def! . 1)
    (defmacro! . 1)
    (fn* . 1)
    (let* . 1)
    (do . 0)
    (if . 2)
    (when . 1)
    (cond . 0)
    (case . 1)
    (try* . 0)
    (catch* . 1)
    (doseq . 1)
    (dotimes . 1)
    (while . 1)
    (loop . 0)
    (recur . 0))
  "Indentation rules for MAL special forms.")

(defun mal-indent-function (indent-point state)
  "Indentation function for MAL mode.
This function handles MAL-specific forms while delegating
to standard Lisp indentation for others."
  (let ((normal-indent (current-column)))
    (goto-char (1+ (elt state 1)))
    (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
    (if (and (elt state 2)
             (not (looking-at "\\sw\\|\\s_")))
        ;; car of form doesn't seem to be a symbol
        (progn
          (if (not (> (save-excursion (forward-line 1) (point))
                      calculate-lisp-indent-last-sexp))
              (progn (goto-char calculate-lisp-indent-last-sexp)
                     (beginning-of-line)
                     (parse-partial-sexp (point)
                                         calculate-lisp-indent-last-sexp 0 t)))
          (backward-prefix-chars)
          (current-column))
      (let* ((function (buffer-substring (point)
                                         (progn (forward-sexp 1) (point))))
             (method (cdr (assoc (intern function) mal-indent-rules))))
        (cond ((integerp method)
               (lisp-indent-specform method state indent-point normal-indent))
              (method
               (funcall method state indent-point normal-indent))
              (t
               (lisp-indent-function indent-point state)))))))

;; Interactive commands for MAL development
(defvar mal-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Inherit from lisp-mode-map
    (set-keymap-parent map lisp-mode-map)
    ;; Add MAL-specific bindings
    (define-key map (kbd "C-c C-e") 'mal-eval-last-sexp)
    (define-key map (kbd "C-c C-r") 'mal-eval-region)
    (define-key map (kbd "C-c C-b") 'mal-eval-buffer)
    (define-key map (kbd "C-c C-l") 'mal-load-file)
    (define-key map (kbd "C-c C-z") 'mal-switch-to-repl)
    map)
  "Keymap for MAL mode.")

(defcustom mal-program-name "ruby mal_minimal.rb"
  "Program invoked by the `mal-repl' command."
  :type 'string
  :group 'mal)

(defcustom mal-repl-buffer-name "*mal-repl*"
  "Name of the MAL REPL buffer."
  :type 'string
  :group 'mal)

(defun mal-repl ()
  "Start a MAL REPL process."
  (interactive)
  (let ((buffer (get-buffer-create mal-repl-buffer-name)))
    (unless (comint-check-proc buffer)
      (with-current-buffer buffer
        (apply 'make-comint-in-buffer "mal" buffer
               (car (split-string mal-program-name))
               nil (cdr (split-string mal-program-name)))
        (mal-repl-mode)))
    (pop-to-buffer buffer)))

(define-derived-mode mal-repl-mode comint-mode "MAL-REPL"
  "Major mode for MAL REPL interaction."
  (setq comint-prompt-regexp "^user> ")
  (setq comint-prompt-read-only t))

(defun mal-switch-to-repl ()
  "Switch to the MAL REPL buffer, starting it if necessary."
  (interactive)
  (mal-repl))

(defun mal-eval-last-sexp ()
  "Evaluate the last sexp before point in the MAL REPL."
  (interactive)
  (let ((sexp (buffer-substring-no-properties
               (save-excursion (backward-sexp) (point))
               (point))))
    (mal-eval-string sexp)))

(defun mal-eval-region (start end)
  "Evaluate the region in the MAL REPL."
  (interactive "r")
  (mal-eval-string (buffer-substring-no-properties start end)))

(defun mal-eval-buffer ()
  "Evaluate the entire buffer in the MAL REPL."
  (interactive)
  (mal-eval-region (point-min) (point-max)))

(defun mal-load-file ()
  "Load the current file in the MAL REPL."
  (interactive)
  (save-buffer)
  (mal-eval-string (format "(load-file \"%s\")" buffer-file-name)))

(defun mal-eval-string (string)
  "Evaluate STRING in the MAL REPL."
  (let ((buffer (mal-repl)))
    (with-current-buffer buffer
      (goto-char (point-max))
      (insert string)
      (comint-send-input))))

;; File associations
(add-to-list 'auto-mode-alist '("\\.mal\\'" . mal-mode))
(add-to-list 'interpreter-mode-alist '("mal" . mal-mode))

;; Electric pairs for MAL
(defvar mal-mode-electric-pairs
  '((?\" . ?\"))
  "Electric pairs for MAL mode.")

(defun mal-mode-setup-electric-pairs ()
  "Setup electric pairs for MAL mode."
  (setq-local electric-pair-pairs
              (append electric-pair-pairs mal-mode-electric-pairs))
  (setq-local electric-pair-skip-self t))

(add-hook 'mal-mode-hook #'mal-mode-setup-electric-pairs)
(add-hook 'mal-mode-hook #'electric-pair-local-mode)

;; Additional setup for better Lisp editing
(add-hook 'mal-mode-hook #'show-paren-mode)
(add-hook 'mal-mode-hook #'electric-indent-mode)

;; Company mode support (if available)
(with-eval-after-load 'company
  (defun mal-mode-company-setup ()
    "Setup company mode for MAL."
    (setq-local company-backends
                '((company-capf company-dabbrev-code)
                  company-dabbrev)))
  (add-hook 'mal-mode-hook #'mal-mode-company-setup)
  (add-hook 'mal-mode-hook #'company-mode))

;; Flycheck support (if available)
(with-eval-after-load 'flycheck
  (flycheck-define-checker mal
    "A syntax checker for MAL using the MAL implementation itself."
    :command ("ruby" "mal_minimal.rb" "--check" source)
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": " (message) line-end))
    :modes mal-mode))

(provide 'mal-mode)

;;; mal-mode.el ends here

(use-package mal-mode
  :load-path "/path/to/mal-ruby-minimal/experiments/005-sicp-mal/"
  :mode "\\.mal\\'"
  :config
  (setq mal-program-name "/path/to/mal-ruby-minimal/stepA_mal.rb"))

(with-eval-after-load 'mal-mode
  (add-to-list 'mal-indent-rules '(my-macro . 1)))
