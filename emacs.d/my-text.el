;;;
;;; Alexey Khudyakov
;;; Text editing customization
;;;

(defun my/tex-switch-quotes ()
  "Hack to replace TeX english `` and '' quotes with << >>"
  (interactive)
  (if (string-equal tex-open-quote  "``")
    (set-variable 'tex-open-quote   "<<")
    (set-variable 'tex-open-quote   "``"))
  (if (string-equal tex-close-quote "''")
    (set-variable 'tex-close-quote  ">>")
    (set-variable 'tex-close-quote  "''")))

(defun my/recode-buffer-safe (target-coding-system)
  "* Recode buffer as if it were encoded with `target-coding-system'.
  If current buffer is write-protected (`buffer-read-only'), do nothing."
  (interactive "zEnter target coding system: ")
  (unless buffer-read-only
    (encode-coding-region (point-min)
                          (point-max)
                          buffer-file-coding-system)
    (decode-coding-region (point-min)
                          (point-max)
                          target-coding-system)
    (set-buffer-file-coding-system target-coding-system)))

(defun my/change-encoding (actual-encoding) 
  "Sets file encoding
  I'm not sure that it would work as intended everywhere, but it work at least"
  (interactive "zEnter file encoding: ")
  (recode-region (point-min) (point-max)
                 actual-encoding buffer-file-coding-system)
  (set-buffer-file-coding-system actual-encoding))

(defun my/switch-dict ()
  "Swtich between dictionaries"
  (interactive)
  (ispell-change-dictionary (if (string= "ru" ispell-dictionary)
				"en" "ru")))


;; ================================================================
;; Global settings
;; ================================================================

; orphography check
(setq         ispell-dictionary   "en"    )
(setq-default ispell-program-name "aspell")



;; =========================================================
;; Hooks
;; =========================================================
; Basic text hook
(defun my/base-text-hooks()
  "Common hooks for text mode"
  (auto-fill-mode  1 )
  (set-fill-column 80)
  (flyspell-mode   t )
  )

(defun my/tex-hooks()
  "Hooks for TeX mode"
  (my/base-text-hooks)
  (my/make-hook)
  (local-set-key (kbd "C-c q") 'my/tex-switch-quotes)
  (local-set-key (kbd "C-c SPC") (lambda ()
    (interactive)
    (insert "~")
    ))
  (local-set-key (kbd "C-c -") (lambda ()
    (interactive)
    (insert "~---")
    ))
  ; Add more known blocks (esp. for beamer)
  (set-variable 'latex-standard-block-names
    (append '("frame" "block" "exampleblock" "alertblock"
	      "columns" "column" "align" "aligned"
	      )
	    latex-standard-block-names
	    ))
  (set-variable 'latex-block-args-alist
    (append '(("column" nil ?\{ (skeleton-read "Width: ") ?\})
	      ("block"        nil ?\{ (skeleton-read "Title: ") ?\})
	      ("exampleblock" nil ?\{ (skeleton-read "Title: ") ?\})
	      ("alertblock"   nil ?\{ (skeleton-read "Title: ") ?\})
	      )
	    latex-block-args-alist))
  )
; TeX template
(defun my/tex-insert-template()
  (interactive)
  (insert
"\\documentclass[a4paper]{article}

\\usepackage[russian]{babel}
\\usepackage[utf8]{inputenc}
\\usepackage{fullpage}
\\usepackage{indentfirst}
% \\usepackage{graphicx}

\\begin{document}
\\end{document}
"))

(add-hook 'latex-mode-hook 'my/tex-hooks)
(add-hook 'tex-mode-hook   'my/tex-hooks)
(add-hook 'text-mode-hook  'my/base-text-hooks)

(provide 'my-text)


;; =========================================================
;; hledger-mode
;; =========================================================
(when (require 'hledger-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.journal\\'" . hledger-mode))
  )

;; =========================================================
;; org-mode
;; =========================================================
(setq org-todo-keywords
      '((sequence "TODO" "PROG" "RC" "BLOCKED" "|" "DONE" "DROPPED")))
; Support for mobile
(setq org-mobile-directory      "~/Dropbox/org-mode")
(setq org-directory             "~/work/tracker")
(setq org-mobile-inbox-for-pull "~/work/tracker/flagged.org")
(setq org-mobile-files          '("todo.org" "etc.org"))
