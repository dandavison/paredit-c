;;; paredit-c-mode.el --- paredit mode for C-style languages

(require 'paredit)

(defvar paredit-c-mode-map paredit-mode-map)

(define-minor-mode paredit-c-mode
  "paredit-mode for C-style languages

\\{paredit-c-mode-map}"
  nil " Paredit-c" nil
  (cond
   (paredit-c-mode
    ;; turn on
    (condition-case nil
      (progn
        (paredit-mode 1)
        (set (make-local-variable
              'paredit-space-for-delimiter-predicates)
             '((lambda (&rest args) nil)))
        (local-set-key "{" 'paredit-open-curly)
        (local-set-key "'" 'paredit-c/singlequote)
        (local-set-key ";" 'self-insert-command)
        (local-set-key "\M-q" 'fill-paragraph)
        (when (eq major-mode 'python-mode)
	  (local-set-key [backspace] 'paredit-c/py-backspace-w-paredit)))
    (error (message "Failed to activate paredit-c mode"))))
   (t
    ;; turn off
    (paredit-mode -1))))


(defun paredit-c/py-backspace-w-paredit ()
  "backspace binding for python-mode with paredit"
  (interactive)
  (condition-case nil
      (call-interactively
       (if (looking-back "^[ \t]+")
           (cond
	    ((fboundp 'python-indent-dedent-line-backspace)
	     'python-indent-dedent-line-backspace)
	    ((fboundp 'py-electric-backspace) py-electric-backspace)
	    ((fboundp 'python-backspace) 'python-backspace))
         'paredit-backward-delete))
    (error (call-interactively 'delete-backward-char))))

(defun paredit-c/singlequote (&optional n)
  "Copied from `paredit-doublequote'"
  (interactive "P")
  
  (if (null paredit-mode) (insert "'")
    (cond ((paredit-in-string-p)
           (if (eq (cdr (paredit-string-start+end-points))
                   (point))
               (forward-char) ; We're on the closing quote.
             (insert ?\\ ?\' )))
          ((paredit-in-comment-p)
           (insert ?\' ))
          ((not (paredit-in-char-p))
           (paredit-insert-pair n ?\' ?\' 'paredit-forward-for-quote)))))

(provide 'paredit-c)
