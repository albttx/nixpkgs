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

;; Ansible hosts file syntax color
(add-to-list 'auto-mode-alist '("hosts\\'" . ini-mode))

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

;; Increase window size
;; TODO: down left and right
(after! evil
  (define-key evil-normal-state-map (kbd "C-S-<up>") 'evil-window-decrease-height)
  (define-key evil-normal-state-map (kbd "C-S-<down>") 'evil-window-increase-height)
)


;; Move the view in the buffer
(after! evil
  (define-key evil-normal-state-map (kbd "C-<up>") (lambda () (interactive) (evil-scroll-up 1)))
  (define-key evil-normal-state-map (kbd "C-<down>") (lambda () (interactive) (evil-scroll-down 1)))
)
