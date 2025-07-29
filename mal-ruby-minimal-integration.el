;;; mal-ruby-minimal-integration.el --- Integration with existing mal-ruby-minimal.el

;; This integrates the enhanced mal-mode with your existing configuration

(require 'mal-mode)
(require 'mal-ruby-minimal)

;; Override the basic mal-mode from mal-ruby-minimal.el
;; The new mal-mode provides better syntax highlighting and indentation

;; Integrate with your existing keybindings
(define-key mal-ruby-mode-map (kbd "C-c C-z") 'mal-repl)
(define-key mal-ruby-mode-map (kbd "C-c C-e") 'mal-eval-last-sexp)

;; Use your project-specific REPL command
(setq mal-program-name mal-ruby-repl-command)

;; Hook to enable mal-ruby-mode features in mal-mode
(add-hook 'mal-mode-hook #'mal-ruby-maybe-enable)

(provide 'mal-ruby-minimal-integration)
