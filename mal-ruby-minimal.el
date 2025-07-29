;;; mal-ruby-minimal.el --- Emacs configuration for MAL Ruby development -*- lexical-binding: t; -*-

;; Author: MAL Ruby Minimal Contributors
;; Keywords: languages, lisp, ruby
;; Package-Requires: ((emacs "26.1"))

;;; Commentary:

;; This file provides an Emacs configuration for working with the MAL Ruby
;; Minimal implementation.  It sets up:
;; - Ruby development environment with ruby-lsp
;; - MAL REPL integration
;; - Testing shortcuts
;; - Project navigation

;;; Code:

;; Add MELPA if not already present
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install required packages
(defvar mal-ruby-required-packages
  '(eglot           ; LSP client (built-in from Emacs 29)
    ruby-mode       ; Ruby mode (usually built-in)
    inf-ruby        ; Ruby REPL integration
    projectile      ; Project navigation
    which-key       ; Key binding help
    company         ; Completion
    flycheck        ; Syntax checking
    magit           ; Git integration
    paredit         ; Structured editing for Lisp
    rainbow-delimiters)) ; Colored parentheses

;; Install packages if needed
(dolist (package mal-ruby-required-packages)
  (unless (package-installed-p package)
    (package-refresh-contents)
    (package-install package)))

;; Ruby configuration
(require 'ruby-mode)
(require 'eglot)
(require 'inf-ruby)

;; Ruby LSP setup
(defun mal-ruby-setup-lsp ()
  "Setup Ruby LSP for MAL development."
  (when (executable-find "ruby-lsp")
    (add-to-list 'eglot-server-programs
                 '(ruby-mode . ("ruby-lsp")))
    (eglot-ensure)))

(add-hook 'ruby-mode-hook #'mal-ruby-setup-lsp)

;; MAL-specific settings
(defgroup mal-ruby nil
  "MAL Ruby Minimal implementation settings."
  :group 'languages)

(defcustom mal-ruby-repl-command "ruby mal_minimal.rb"
  "Command to start MAL REPL."
  :type 'string
  :group 'mal-ruby)

(defcustom mal-ruby-project-root
  (file-name-directory (or load-file-name buffer-file-name))
  "Root directory of MAL Ruby project."
  :type 'directory
  :group 'mal-ruby)

;; MAL REPL
(defun mal-ruby-repl ()
  "Start MAL Ruby REPL."
  (interactive)
  (let ((default-directory mal-ruby-project-root))
    (run-ruby mal-ruby-repl-command "mal-repl")))

(defun mal-ruby-send-region (start end)
  "Send region to MAL REPL."
  (interactive "r")
  (ruby-send-region start end))

(defun mal-ruby-send-buffer ()
  "Send entire buffer to MAL REPL."
  (interactive)
  (ruby-send-region (point-min) (point-max)))

(defun mal-ruby-load-file ()
  "Load current file in MAL REPL."
  (interactive)
  (let ((file (file-relative-name buffer-file-name mal-ruby-project-root)))
    (ruby-send-string (format "(load-file \"%s\")" file))))

;; Testing functions
(defun mal-ruby-run-tests ()
  "Run all MAL tests."
  (interactive)
  (let ((default-directory mal-ruby-project-root))
    (compile "make test")))

(defun mal-ruby-run-current-test ()
  "Run test for current file."
  (interactive)
  (let* ((default-directory mal-ruby-project-root)
         (test-file (if (string-match "test_" buffer-file-name)
                        buffer-file-name
                      (concat "test/test_" (file-name-base buffer-file-name) ".rb"))))
    (if (file-exists-p test-file)
        (compile (format "ruby %s" test-file))
      (message "No test file found for %s" buffer-file-name))))

;; Project navigation
(defun mal-ruby-find-step ()
  "Find a step implementation file."
  (interactive)
  (let ((default-directory mal-ruby-project-root)
        (steps (directory-files mal-ruby-project-root nil "^step[0-9].*\\.rb$")))
    (find-file (completing-read "Step: " steps))))

(defun mal-ruby-find-test ()
  "Find a test file."
  (interactive)
  (let ((default-directory (concat mal-ruby-project-root "test/"))
        (tests (directory-files (concat mal-ruby-project-root "test/") nil "^test_.*\\.rb$")))
    (find-file (completing-read "Test: " tests))))

;; MAL mode for .mal files
(define-derived-mode mal-mode lisp-mode "MAL"
  "Major mode for editing MAL files."
  (setq-local lisp-indent-function 'lisp-indent-function)
  (setq-local comment-start ";")
  (setq-local comment-end "")
  (paredit-mode 1)
  (rainbow-delimiters-mode 1))

(add-to-list 'auto-mode-alist '("\\.mal\\'" . mal-mode))

;; Key bindings
(defvar mal-ruby-mode-map
  (let ((map (make-sparse-keymap)))
    ;; REPL interaction
    (define-key map (kbd "C-c C-z") 'mal-ruby-repl)
    (define-key map (kbd "C-c C-r") 'mal-ruby-send-region)
    (define-key map (kbd "C-c C-b") 'mal-ruby-send-buffer)
    (define-key map (kbd "C-c C-l") 'mal-ruby-load-file)
    ;; Testing
    (define-key map (kbd "C-c t a") 'mal-ruby-run-tests)
    (define-key map (kbd "C-c t t") 'mal-ruby-run-current-test)
    ;; Navigation
    (define-key map (kbd "C-c f s") 'mal-ruby-find-step)
    (define-key map (kbd "C-c f t") 'mal-ruby-find-test)
    map)
  "Keymap for MAL Ruby commands.")

;; Add to Ruby mode
(define-minor-mode mal-ruby-mode
  "Minor mode for MAL Ruby development."
  :lighter " MAL"
  :keymap mal-ruby-mode-map)

;; Enable MAL mode in project files
(defun mal-ruby-maybe-enable ()
  "Enable MAL Ruby mode if in project."
  (when (and buffer-file-name
             (string-prefix-p (expand-file-name mal-ruby-project-root)
                              (expand-file-name buffer-file-name)))
    (mal-ruby-mode 1)))

(add-hook 'ruby-mode-hook #'mal-ruby-maybe-enable)

;; Which-key descriptions
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c C-" "MAL REPL"
    "C-c t" "MAL tests"
    "C-c f" "MAL find"))

;; Projectile setup
(with-eval-after-load 'projectile
  (projectile-register-project-type 'mal-ruby
                                    '("mal_minimal.rb")
                                    :compile "make test"
                                    :test "make test"
                                    :run "make run"))

;; Company mode setup
(add-hook 'ruby-mode-hook 'company-mode)
(add-hook 'mal-mode-hook 'company-mode)

;; Flycheck setup
(add-hook 'ruby-mode-hook 'flycheck-mode)

;; Display startup message
(defun mal-ruby-startup-message ()
  "Display MAL Ruby startup information."
  (message "MAL Ruby Minimal loaded. Press C-c C-z to start REPL, C-c C-h for help."))

(add-hook 'emacs-startup-hook #'mal-ruby-startup-message)

;; Custom function to run example
(defun mal-ruby-run-example ()
  "Run an example MAL file."
  (interactive)
  (let* ((default-directory (concat mal-ruby-project-root "examples/"))
         (examples (directory-files default-directory nil "\\.mal$"))
         (example (completing-read "Example: " examples)))
    (mal-ruby-repl)
    (sit-for 1) ; Wait for REPL to start
    (ruby-send-string (format "(load-file \"examples/%s\")" example))))

(define-key mal-ruby-mode-map (kbd "C-c e") 'mal-ruby-run-example)

;; Test helper for non-interactive testing
(defun mal-ruby-test-setup ()
  "Setup for automated testing."
  (find-file (concat mal-ruby-project-root "examples/factorial.mal"))
  (mal-ruby-repl)
  (sit-for 2)
  (mal-ruby-load-file)
  (message "MAL Ruby test setup complete."))

(provide 'mal-ruby-minimal)

;;; mal-ruby-minimal.el ends here