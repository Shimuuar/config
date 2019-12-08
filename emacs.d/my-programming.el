;;;
;;; Alexey Khudyakov
;;; Programming enhancement
;;;

;; =========================================================
;; Useful functions
;; =========================================================
(defun my/haskell-insert-inline ()
  "Insert INLINE pragma. It inserts pragma in directly above the
line."
  (interactive)
  ; Find out indentation and identifier name
  (if (save-excursion
	(move-beginning-of-line 1)
	(looking-at "^\\([ \t]*\\)\\([a-zA-Z][a-zA-Z_1-9]*\\)")
	)
    (let ((spaces (buffer-substring (match-beginning 1) (match-end 1))) ; Indentation
	  (ident  (buffer-substring (match-beginning 2) (match-end 2))) ; Binding name
	  )
      ; Insert pragma
      (save-excursion
	(move-beginning-of-line 1)
	(insert (concat spaces "{-# INLINE " ident " #-}\n")))
      )
    (error "No identifier here!"))
  )

(defun my/haskell-insert-language-pragma()
  "Insert LANGUAGE pragmas at top of the file"
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (insert "{-# LANGUAGE ")
    (insert (completing-read "Language extension: " my/haskell-language-pragmas))
    (insert " #-}\n")
    ))

(defun my/haskell-find-pragma-region()
  "Find region which contains LANGUAGE pragmas"
  (let* ((find (lambda (n)
		 (goto-line n)
		 (if (looking-at "^ *{-# +LANGUAGE +\\([a-zA-Z0-9]+\\) +#-} *$")
		     (funcall find (+ n 1))
		     (- (point-at-bol) 1))))
	 (p1 (point-min))
	 (p2 (save-excursion (funcall find 1)))
	 )
    (cons p1 p2)))

(defun my/haskell-align-language-pragmas()
  "Align and sort language pragmas"
  (interactive)
  (pcase (my/haskell-find-pragma-region)
    (`(,p1 . ,p2)
     (save-excursion
       (save-restriction
	 (narrow-to-region p1 p2)
	 (replace-regexp "^ +" "")
	 (align-regexp           (point-min) (point-max) "\\(\\s-*\\)#-}")
	 (sort-lines nil         (point-min) (point-max))
	 (delete-duplicate-lines (point-min) (point-max))
	 )))
    ))

(defun my/haskell-insert-module-stub()
  "Insert stub declaration for haskell module"
  (interactive)
  (insert "-- |\n")
  (insert (concat "module " (haskell-guess-module-name) " where\n"))
  )

;; ===============================================
;; Syntax highlighting
;; ===============================================
(global-font-lock-mode t)      ; turn on syntax highlighting
(show-paren-mode t)            ; Highlight parenthesis
(setq show-paren-style 'mixed) ; Highlight whole expression if it's not fully visible



;; ================================================================
;; Flycheck hooks
;; ================================================================
(add-hook 'flycheck-mode-hook (lambda ()
  #'flycheck-haskell-setup
  ; Redefine flycheck prefix. "C-c !" is insane
  (define-key flycheck-mode-map flycheck-keymap-prefix nil)
  (setq flycheck-keymap-prefix (kbd "C-c c"))
  (define-key flycheck-mode-map flycheck-keymap-prefix
              flycheck-command-map)
  ; Increase delay before displaying error
  (set-variable 'flycheck-display-errors-delay 2)
  ))


;; ================================================================
;; Haskell hooks
;; ================================================================

(when (require 'haskell nil t)
  (require 'haskell-mode)
  (require 'haskell-cabal)
  (require 'haskell-indentation)
  (require 'haskell-move-nested)
  (require 'haskell-navigate-imports)
  (require 'haskell-sort-imports)
  (require 'haskell-font-lock)
  ;;
  (setq auto-mode-alist
	(append
	 '(("cabal.project" . haskell-cabal-mode)
	   ) auto-mode-alist))

  ;; Generate TAGS
  (custom-set-variables '(haskell-tags-on-save t))
  ;; ----------------------------------------------------------------
  ;; Change keybindings
  (define-key haskell-mode-map (kbd "C-c C-v") 'my/comment-or-uncomment)
  (define-key haskell-mode-map (kbd "C-c v")   'haskell-cabal-visit-file)
  (define-key haskell-mode-map (kbd "C-c u")
    (lambda () (interactive)
      (insert "undefined")))
  ;; Move nested blocks
  (define-key haskell-mode-map (kbd "M-<left>")
    (lambda () (interactive)
      (haskell-move-nested -1)))
  (define-key haskell-mode-map (kbd "M-<right>")
    (lambda () (interactive)
      (haskell-move-nested  1)))
  ;; Comments
  (define-key haskell-mode-map (kbd "M-[") 'haskell-navigate-imports)
  (define-key haskell-mode-map (kbd "M-]") 'haskell-navigate-imports-return)
  ;; PRAGMAS
  (define-key haskell-mode-map (kbd "C-c i i") 'my/haskell-insert-inline)
  (define-key haskell-mode-map (kbd "C-c i l") 'my/haskell-insert-language-pragma)
  (define-key haskell-mode-map (kbd "C-c i a") 'my/haskell-align-language-pragmas)
  (define-key haskell-mode-map (kbd "C-c i m") 'my/haskell-insert-module-stub)
  ;; Remove unneeded keybindings
  (define-key interactive-haskell-mode-map (kbd "C-c C-v") nil)

  ;; Constants definition
  (defcustom my/haskell-language-pragmas
    (split-string (shell-command-to-string "ghc --supported-extensions"))
    "List of language pragmas supported by the installed version of GHC."
    :group 'my/haskell
    :type  '(repeat string))
  (defcustom my/haskell-ghc-options
    (split-string (shell-command-to-string "ghc --show-options"))
    "List of all GHC's command line options"
    :group 'my/haskell
    :type  '(repeat string))

  (add-hook 'haskell-mode-hook (lambda ()
    "Hooks specific to haskell"
    (turn-on-haskell-indentation)
    ;; generic part
    (my/comment-hooks)
    (abbrev-mode t)
    (interactive-haskell-mode)
    ;; Rename buffer on import.
    (when (buffer-file-name)
      (let ((nm (haskell-guess-module-name)))
	(if (and nm (not (string-equal nm "")))
	    (rename-buffer (concat "{" nm "}") t)))
      (my/try-flycheck)
      )
    ))
  )

;; ================================================================
;; Agda mode
;; ================================================================
(when (executable-find "agda-mode")
  (load-file (let ((coding-system-for-read 'utf-8))
	          (shell-command-to-string "agda-mode locate")))
  )

;; ================================================================
;; Python hooks
;; ================================================================

(add-hook 'python-mode-hook (lambda ()
  "Python hooks"
  (abbrev-mode t)
  (my/try-flycheck)
  (my/hook/indent)
  (my/hook/folding)
  (my/hook/comment)
  ; Python specific hooks
  (setq tab-width        4  )		; Override tab width
  (setq indent-tabs-mode nil)		; Use spaces for indent
  (setq python-indent    4  )		; Python indentation
  ;; Insert shebang into empty files
  (my/insert-if-empty "#!/usr/bin/python\n"
                      "\"\"\"\n"
                      "\"\"\"\n")
  ))


;; ================================================================
;; Set up hooks
;; ================================================================
;; Shell hooks
(add-hook 'sh-mode-hook (lambda ()
  (my/hook/indent)
  (my/insert-if-empty "#!/bin/sh\n\n")
  ))
;; Lisp hooks
(add-hook 'lisp-mode-hook (lambda ()
  (my/hook/indent)
  (my/hook/comment)
  ))
;; Elisp hooks
(add-hook 'emacs-lisp-mode-hook (lambda ()
  (my/hook/indent)
  (my/hook/comment)
  ))
;; JavaScript hooks
(add-hook 'js-mode-hook (lambda ()
  (my/hook/indent)
  (my/hook/comment)
  (my/hook/folding)
  (setq js-indent-level  2)
  (setq indent-tabs-mode nil)
  ))

(provide 'my-programming)
