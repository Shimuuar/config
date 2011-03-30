;;;
;;; Alexey Khudyakov
;;; Programming enhancement
;;;

;; =========================================================
;; Useful functions 
;; =========================================================
(defun my-insert-guard(title)
  "Insert C/C++ header guards quickly"
  (interactive "sType guard name: ")
  (insert "#ifndef " title 
          "\n#define " title 
          "\n\n#endif /* " title " */\n" ))

(defun my-insert-c-template(foo)
  "Insert C program template"
  (interactive "i")
  (insert
"
#include <stdlib.h>
#include <stdio.h>


int main(int argc, char** argv)
{
    return 0;
}
"))

(defun my-insert-c++-template(foo)
  "Insert C program template"
  (interactive "i")
  (insert
"
#include <iostream>


int main(int argc, char** argv)
{
    return 0;
}
"))

(defun my-indent-buffer()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(defun my-indent-line()
  "indent line and move to next"
  (interactive)
  (indent-according-to-mode)
  (next-line))

(defun my-match-paren (arg)
  "Jump to matching parenthesis"
  (interactive "p")
  (cond ((looking-at  "[\[<\(\{]") (forward-list  1))
        ((looking-back "[]>\)\}]") (backward-list 1))))

(defun my-comment-or-uncomment-line ()
  "Comment or uncomment line under cursor"
  (interactive)
  (comment-or-uncomment-region (point-at-bol) (point-at-eol)))

(defun my-settab(wid)
  "Set tab width"
  (interactive "nType tab width ")
  (setq tab-width wid))

;; =================


;; ===============================================
;; Syntax highlighting
;; ===============================================
; turn on syntax highlighting
(global-font-lock-mode t)
; Highlight parensthesis
(show-paren-mode t) 
; Highlight whole expression if it's not fully visible
(setq show-paren-style 'mixed) 
;; =================


;; ===============================================
;; Indentation
;; ===============================================
; Could be set with c-set-style
(defconst my-c-tab-style
  '( "bsd"
	(indent-tabs-mode . t)
	(tab-width        . 4)
	(c-basic-offset   . 4)
 	(c-echo-syntactic-information-p . t)
 	)
  )
(defconst my-c-ws-style
  '( "bsd"
	(indent-tabs-mode . nil)
	(tab-width        . 4)
	(c-basic-offset   . 4)
 	(c-echo-syntactic-information-p . t)
 	)
  )

(c-add-style "bsd-tab" my-c-tab-style)
(c-add-style "bsd-ws"  my-c-ws-style)
(setq c-default-style "bsd-ws")
;; =================


;; ========================================================
;; Define hooks 
;; =========================================================
(defun my-c-indent-hook()
  "Allow to change indentation "
  (local-set-key (kbd "C-c C-<tab>") (lambda () (interactive)
				       (c-set-style "bsd-tab")))
  (local-set-key (kbd "C-c C-SPC")   (lambda () (interactive) 
				       (c-set-style "bsd-ws")))
  )

(defun my-indent-hook()
  "Make new lines indented"
  (local-set-key (kbd "RET") 'newline-and-indent))

(defun my-folding-hooks()
  "Hook for code folding"
  (hs-minor-mode t)
  (local-set-key (kbd "C-S-<left>") 'hs-hide-block)
  (local-set-key (kbd "C-S-<right>") 'hs-show-block)
  )

(defun my-comment-hooks ()
  "Hooks for commenting"
  (local-set-key (kbd "C-c C-c") 'comment-or-uncomment-region)
  (local-set-key (kbd "C-c C-v") 'my-comment-or-uncomment-line)
  )

(defun my-python-hooks ()
  "Hooks specific to python"
  (setq tab-width 4)			; Override tab width
  (setq indent-tabs-mode nil)		; Use spaces for indent
  (abbrev-mode t)			; Set abberviation mode
  ;; Insert shebang into empty files
  (my-insert-if-empty "#!/usr/bin/python\n"
                      "\"\"\"\n"
                      "\"\"\"\n"))

(defun my-haskell-hooks ()
  "Hooks specific to haskell"
  (abbrev-mode t)
  )
    
;; C hooks
(add-hook-list 'c-mode-hook          '(my-indent-hook my-c-indent-hook my-comment-hooks my-folding-hooks))
;; C++ hooks 
(add-hook-list 'c++-mode-hook        '(my-indent-hook my-c-indent-hook my-comment-hooks my-folding-hooks))
;; Python hooks 
(add-hook-list 'python-mode-hook     '(my-indent-hook my-folding-hooks my-python-hooks))
;; Shell hooks 
(add-hook-list 'sh-mode-hook         '(my-indent-hook (lambda () (my-insert-if-empty "#!/bin/sh\n\n"))))
;; Lisp hooks
(add-hook-list 'lisp-mode-hook       '(my-indent-hook my-comment-hooks))
;; Elisp hooks
(add-hook-list 'emacs-lisp-mode-hook '(my-indent-hook my-comment-hooks))
;; Haskell hooks
(add-hook-list 'haskell-mode-hook    '(my-comment-hooks my-haskell-hooks))
;; =================

(provide 'my-programming)
