;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

  (setq org-directory "~/org/")

  (setq user-full-name "Albert Le Batteux"
      user-mail-address "contact@albttx.tech")

      ;;
      ;;; UI

  (setq doom-theme 'catppuccin)
  (setq catppuccin-flavor 'mocha)
;      (setq doom-theme 'doom-dracula
;            doom-font (font-spec :family "JetBrainsMono" :size 12)
;	          doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 13))


  (setq mac-command-modifier 'meta)

(add-to-list 'auto-mode-alist '("\\.gno" . go-mode))

;  (global-set-key (kbd "s-/") 'comment-line)
;  (global-set-key (kbd "M-/") 'comment-line)
;
(global-set-key (kbd "M-<left>") 'evil-window-left)
(global-set-key (kbd "M-<right>") 'evil-window-right)
(global-set-key (kbd "M-<up>") 'evil-window-up)
(global-set-key (kbd "M-<down>") 'evil-window-down)


(map!
   :envi "M-<up>"  #'evil-window-up
   :envi "M-<down>"  #'evil-window-down
   :envi "M-<left>"  #'evil-window-left
   :envi "M-<right>"  #'evil-window-right

   :nvi "C-/" #'comment-line
   :nvi "M-/" #'comment-line
)
