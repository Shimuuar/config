;;;
;;; Alexey Khudyakov
;;; Emacs appearance
;;;


;; Font faces
(set-face-foreground font-lock-comment-face "red")
;;(set-face-font 'default "-xos4-terminus-bold-r-normal--20-200-72-72-c-100-iso10646-1")
;;(set-face-font 'variable-pitch "-*-helvetica-*-*-*-*-18-*-*-*-*-*-iso10646-*")
;; default "-xos4-terminus-bold-r-normal--20-200-72-72-c-100-iso10646-1")

; No startup message
(setq inhibit-startup-message t)

;; Line and column numbering
(line-number-mode   t)
(column-number-mode t)

;; Display time (May be it's useful)
(display-time)

;; No menu, no toolbar, no scroll bar. 
(tool-bar-mode   nil)
(scroll-bar-mode nil)
(menu-bar-mode   nil)

;; No annoying beeps
(setq visible-bell t)

;; Set cursor and mouse-pointer colours
(set-cursor-color "red")
(set-mouse-color  "goldenrod")
(set-face-background 'region "gray30")
(set-foreground-color "white")
(set-background-color "black")


(provide 'my-appearance)
