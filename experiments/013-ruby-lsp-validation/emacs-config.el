;;; emacs-config.el --- Ruby LSP configuration for MAL development

;;; Commentary:
;; Example configurations for using Ruby LSP with MAL Ruby Minimal
;; Choose either eglot (built-in to Emacs 29+) or lsp-mode

;;; Code:

;;;; Option 1: Using Eglot (recommended for Emacs 29+)

(use-package eglot
  :ensure t
  :hook ((ruby-mode . eglot-ensure)
         (ruby-ts-mode . eglot-ensure))
  :config
  ;; Add Ruby LSP to the server programs
  (add-to-list 'eglot-server-programs
               '((ruby-mode ruby-ts-mode) . ("ruby-lsp")))
  
  ;; Optional: Customize Eglot for MAL development
  (defun my/eglot-mal-setup ()
    "Setup Eglot for MAL Ruby development."
    (when (and (buffer-file-name)
               (string-match-p "mal.*\\.rb\\'" (buffer-file-name)))
      ;; Disable some Ruby LSP features that don't work well with MAL
      (setq-local eglot-ignored-server-capabilities
                  '(:documentHighlightProvider ; MAL symbols confuse this
                    :codeLensProvider))))      ; Not useful for MAL
  
  (add-hook 'eglot-managed-mode-hook #'my/eglot-mal-setup))

;;;; Option 2: Using lsp-mode

(use-package lsp-mode
  :ensure t
  :hook ((ruby-mode . lsp-deferred)
         (ruby-ts-mode . lsp-deferred))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  ;; Performance tuning
  (setq lsp-idle-delay 0.5
        lsp-log-io nil
        lsp-completion-provider :none) ; Use company-mode
  
  ;; Ruby LSP specific settings
  (setq lsp-ruby-lsp-use-bundler nil)
  
  ;; MAL-specific configuration
  (defun my/lsp-mal-setup ()
    "Setup LSP for MAL Ruby development."
    (when (and (buffer-file-name)
               (string-match-p "mal.*\\.rb\\'" (buffer-file-name)))
      ;; Adjust diagnostics for MAL style
      (setq-local lsp-diagnostics-provider :flycheck)
      (setq-local flycheck-disabled-checkers '(ruby-rubocop))))
  
  (add-hook 'lsp-mode-hook #'my/lsp-mal-setup))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-enable nil)) ; Too noisy for MAL

;;;; Common configuration for both options

;; Enhanced Ruby mode for MAL
(defun my/mal-ruby-mode-setup ()
  "Setup Ruby mode for MAL development."
  ;; Use ruby-ts-mode if available (Emacs 29+)
  (when (and (fboundp 'ruby-ts-mode)
             (treesit-language-available-p 'ruby))
    (ruby-ts-mode))
  
  ;; MAL-specific indentation
  (setq-local ruby-indent-level 2)
  (setq-local ruby-indent-tabs-mode nil)
  
  ;; Highlight MAL-specific keywords
  (font-lock-add-keywords
   nil
   '(("\\<\\(car\\|cdr\\|cons\\|null\\?\\)\\>" . font-lock-builtin-face)
     ("\\<\\(eval_mal\\|read_str\\|mal_to_string\\)\\>" . font-lock-function-name-face)
     ("\\<\\(def!\\|let\\*\\|fn\\*\\)\\>" . font-lock-keyword-face))))

(add-hook 'ruby-mode-hook #'my/mal-ruby-mode-setup)

;; Load mal-mode for .mal files
(when (file-exists-p "../../mal-mode.el")
  (load-file "../../mal-mode.el"))

;;; Testing the setup

(defun test-ruby-lsp ()
  "Test if Ruby LSP is working."
  (interactive)
  (let ((test-file "mal-lsp-test.rb"))
    (with-temp-buffer
      (insert "def test_mal\n  puts 'Hello MAL'\nend\n")
      (write-file test-file)
      (ruby-mode)
      (if (featurep 'eglot)
          (progn
            (eglot-ensure)
            (message "Eglot started. Check *EGLOT* buffer for LSP communication."))
        (when (featurep 'lsp-mode)
          (lsp)
          (message "LSP Mode started. Check *lsp-log* buffer for details."))))
    (find-file test-file)))

(provide 'emacs-config)
;;; emacs-config.el ends here