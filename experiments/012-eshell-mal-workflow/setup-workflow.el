;;; setup-workflow.el --- MAL eshell workflow setup

;;; Commentary:
;; This file sets up an Emacs workflow for MAL development
;; with mal-mode for editing and eshell for REPL interaction

;;; Code:

;; Load mal-mode from project root
(let ((mal-mode-path (expand-file-name "../../mal-mode.el"
                                        (file-name-directory load-file-name))))
  (when (file-exists-p mal-mode-path)
    (load-file mal-mode-path)))

(defun mal-eshell-workflow ()
  "Setup MAL development workflow with code and REPL."
  (interactive)
  ;; Delete other windows for clean start
  (delete-other-windows)
  
  ;; Open example MAL file
  (let ((example-file (expand-file-name "workflow.mal"
                                        (file-name-directory load-file-name))))
    (if (file-exists-p example-file)
        (find-file example-file)
      ;; Create example if it doesn't exist
      (find-file example-file)
      (insert ";; MAL Workflow Example\n\n")
      (insert ";; Define a simple function\n")
      (insert "(def! square (fn* (x) (* x x)))\n\n")
      (insert ";; Test it\n")
      (insert "(print \"5 squared is: \")\n")
      (insert "(print (square 5))\n")
      (save-buffer)))
  
  ;; Split window - adjust ratio as needed
  (split-window-below -12)
  
  ;; Move to bottom window
  (other-window 1)
  
  ;; Start eshell
  (eshell)
  
  ;; Clear eshell buffer
  (eshell/clear)
  
  ;; Change to project root
  (eshell/cd (expand-file-name "../.." (file-name-directory load-file-name)))
  
  ;; Run MAL REPL
  (insert "ruby mal_minimal.rb")
  (eshell-send-input)
  
  ;; Return to top window
  (other-window 1)
  
  ;; Display helper message
  (message "MAL workflow ready! Use C-x o to switch windows"))

(defun mal-send-to-eshell (text)
  "Send TEXT to eshell running MAL REPL."
  (let ((eshell-buffer (get-buffer "*eshell*")))
    (when eshell-buffer
      (with-current-buffer eshell-buffer
        (goto-char (point-max))
        (insert text)
        (eshell-send-input)))))

(defun mal-eval-last-sexp ()
  "Evaluate last s-expression in MAL REPL."
  (interactive)
  (let ((sexp (buffer-substring-no-properties
               (save-excursion (backward-sexp) (point))
               (point))))
    (mal-send-to-eshell sexp)))

(defun mal-eval-region (start end)
  "Evaluate region in MAL REPL."
  (interactive "r")
  (let ((text (buffer-substring-no-properties start end)))
    (mal-send-to-eshell text)))

(defun mal-load-current-file ()
  "Load current file in MAL REPL."
  (interactive)
  (when (buffer-file-name)
    (save-buffer)
    (mal-send-to-eshell 
     (format "(load-file \"%s\")" 
             (file-relative-name (buffer-file-name)
                                 (expand-file-name "../.." 
                                                   (file-name-directory load-file-name)))))))

;; Key bindings for mal-mode
(with-eval-after-load 'mal-mode
  (define-key mal-mode-map (kbd "C-c C-e") 'mal-eval-last-sexp)
  (define-key mal-mode-map (kbd "C-c C-r") 'mal-eval-region)
  (define-key mal-mode-map (kbd "C-c C-l") 'mal-load-current-file)
  (define-key mal-mode-map (kbd "C-c C-z") 'eshell))

;; Auto-start workflow if loaded interactively
(when (and (boundp 'command-line-args)
           (member "--mal-workflow" command-line-args))
  (mal-eshell-workflow))

;; Provide feature
(provide 'setup-workflow)

;;; setup-workflow.el ends here