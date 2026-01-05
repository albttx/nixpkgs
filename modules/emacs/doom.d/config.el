;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

(setq org-directory "~/org/")

(setq user-full-name "Albert Le Batteux"
      user-mail-address "contact@albttx.tech")

;;
;;; UI

(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'mocha)

(setq mac-command-modifier 'meta)

(setq doom-modeline-vcs-max-length 24)

(add-to-list 'auto-mode-alist '("\\.gno" . go-mode))

;; Ansible hosts file syntax color
(add-to-list 'auto-mode-alist '("hosts\\'" . ini-mode))

(global-set-key (kbd "M-<left>") 'evil-window-left)
(global-set-key (kbd "M-<right>") 'evil-window-right)
(global-set-key (kbd "M-<up>") 'evil-window-up)
(global-set-key (kbd "M-<down>") 'evil-window-down)

(setq evil-move-beyond-eol t)
(map!
 :envi "M-<up>"  #'evil-window-up
 :envi "M-<down>"  #'evil-window-down
 :envi "M-<left>"  #'evil-window-left
 :envi "M-<right>"  #'evil-window-right

 :envi "<home>"  #'evil-beginning-of-line
 :envi "<end>"   #'evil-end-of-line

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

;; Kill the workspace when the last window is closed
(defun my/kill-workspace-on-last-window ()
  "Kill the current workspace if it's the last window."
  (when (and (bound-and-true-p +workspace-mode)
             (= (count-windows) 1))
    (+workspace/delete (+workspace-current-name))))

(add-hook 'delete-window-hook #'my/kill-workspace-on-last-window)


;; Override SPC TAB TAB to use consult
(map! :leader
      :desc "Switch workspace" "TAB TAB" #'+workspace/switch-to)


;; Use consult for switching workspaces
(defun +workspace/switch-to ()
  "Use `consult` to switch to a workspace."
  (interactive)
  (let* ((current (or (+workspace-current-name) ""))
         (workspace (consult--read (persp-names)
                                   :prompt "Switch to workspace: "
                                   :require-match t
                                   :default current)))
    (+workspace-switch workspace)))

;; (use-package flycheck
;;   :ensure t
;;   :init (global-flycheck-mode t))

;; (defun my/vertico-git-hunks ()
;;   (interactive)
;;   (require 'magit)
;;   (let* ((hunks (magit-changed-hunk-sections 'unstaged))
;;          (titles (mapcar (lambda (hunk) (oref hunk title)) hunks))
;;          (choice (completing-read "Select hunk: " titles nil t))
;;          (selected-hunk (seq-find (lambda (hunk) (string= (oref hunk title) choice)) hunks)))
;;     (magit-diff-visit-file (oref selected-hunk value) (oref selected-hunk start))))

;; (map! :leader
;;       "b g" #'my/vertico-git-hunks)

;; (add-load-path! "lisp/gno")
;; (use-package gno
;;   :load-path "lisp/gno")

;;(use-package color-theme-approximate
;;  :config
;;  (color-theme-approximate-on)
;;  )
