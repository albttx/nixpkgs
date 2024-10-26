;;; ~/.doom.d/packages.el

(package! catppuccin-theme)
;; :lang

(package! hcl-mode)

(package! ini-mode)

(package! yaml-pro)

;; required for gno
(package! polymode)
(package! flycheck)

;; My custom packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(package! gno  :recipe (:local-repo "packages/gno" ))
;; (package! gno  :recipe (:local-repo "lisp/gno" :files ("gno.el" "lsp-gno.el")))
;; (package! lsp-gno  :recipe (:local-repo "lisp/gno" :files ("lsp-gno.el")))
;; (package! gno-mode :recipe (:local-repo "lisp/gno" :files ("gno-mode.el")))
