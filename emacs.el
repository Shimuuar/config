;;;
;;; Alexey Khudyakov
;;; Main emacs configuration file 
;;;

;; Load paths
(defun add-load-path (path)
  (add-to-list 'load-path (expand-file-name path)))
;; Now add default pathes
(add-load-path "~/.emacs.d/lisp-personal")
(mapcar 'add-load-path
	(seq-filter 'file-directory-p
		    (file-expand-wildcards (expand-file-name "~/.emacs.d/lisp/*"))))

; Load files
(require 'my-generic)
(require 'my-text)
(require 'my-programming)
(require 'my-abbrevs)
(require 'my-bindings)
(require 'my-appearance)

(require 'mod-hledger-mode)
; Require local modification (if any)
(require 'my-local "my-local.el" t)
(require 'my-extra "my-extra.el" t)

;; FIXME: is this a right way?
(custom-set-variables
  '(safe-local-variable-values
   (quote
    ((org-todo-keyword-faces
      ("BLOCKED" . "red")
      ("RC" . "yellow"))))))
