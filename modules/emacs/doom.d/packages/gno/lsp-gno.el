;; lsp-gno.el --- LSP client for the Gno Programming Language -*- lexical-binding: t -*-

;; Author: Guilhem Fanton <guilhem.fanton@gmail.com>
;; Version: 0.1
;; Package-Requires: ((lsp-mode "6.3.2"))
;; Keywords: languages, gno, lsp
;; URL: https://github.com/gfanton/gno-mode

;;; Commentary:

;; This package integrates the Gno Programming Language with Emacs, using
;; the LSP protocol and the gnopls language server. It provides features like
;; autocompletion, diagnostics, and other IDE-like functionalities.
;;
;; To use this package, ensure that the `gnopls` language server is installed
;; and available on your PATH.

;;; Code:

(require 'lsp-mode)
(require 'gno-mode)
(require 'lsp-completion)

(defgroup lsp-gno nil
  "LSP support for the Gno Programming Language, using the gnopls language server."
  :group 'lsp-mode
  :package-version '(lsp-mode . "6.3.2"))

(defcustom lsp-gno-gnopls-server-path "gnopls"
  "Path to gnopls server binary."
  :type 'string
  :group 'lsp-gno)

(defcustom lsp-gno-gnopls-gnokey-path "gnokey"
  "Path to gnokey binary."
  :type 'string
  :group 'lsp-gno)

(defcustom lsp-gno-precompile-on-save nil
  "If true, the server will precompile the file before saving it."
  :type 'boolean
  :group 'lsp-gno)

(defcustom lsp-gno-build-on-save nil
  "If true, the server will build the file before saving it."
  :type 'boolean
  :group 'lsp-gno)

(defcustom lsp-gno-root ""
  "Path to a local copy of the gno repository. GNOROOT will be used as a fallback."
  :type '(choice (directory :tag "Root directory") (const :tag "Unspecified" nil))
  :group 'lsp-gno)

(lsp-register-custom-settings
 '(("gnopls.gno" lsp-gno-gnopls-server-path)
   ("gnopls.gnokey" lsp-gno-gnopls-gnokey-path)
   ("gnopls.precompileOnSave" lsp-gno-precompile-on-save t)
   ("gnopls.buildOnSave" lsp-gno-build-on-save t)
   ("gnopls.root" lsp-gno-root)))

(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection
                                   (lambda ()
                                     (if lsp-gno-root
                                         (list lsp-gno-gnopls-server-path "serve")
                                       (message "lsp-gno-root is not specified")
                                       nil)))
                  :activation-fn (lsp-activate-on "gno" "gnomod")
                  :priority 1 ;; should override gopls
                  :server-id 'gnopls
                  :completion-in-comments? t))

(lsp-consistency-check lsp-gno)

;;;###autoload
(defun lsp-gno-setup ()
  "Set up LSP for GNO."
  (add-to-list 'lsp-language-id-configuration '(gno-mode . "gno"))
  (add-to-list 'lsp-language-id-configuration '(go-dot-mod-mode . "gnomod")))

(provide 'lsp-gno)
;;; lsp-gno.el ends here
