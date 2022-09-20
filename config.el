;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; Basics
(setq-default tab-width 4
              indent-tabs-mode nil
              fill-column 100
              vc-handled-backends '(Git))

(add-hook! fundamental-mode 'flyspell-mode)
(add-hook! fundamental-mode 'turn-on-auto-fill)
(add-hook! fundamental-mode 'display-fill-column-indicator-mode)
(add-hook! markdown-mode 'turn-on-auto-fill)
(add-hook! org-mode 'turn-on-auto-fill)

(add-hook 'dired-after-readin-hook 'dired-git-info-auto-enable)

(defun haskell-company-backends ()
  (set (make-local-variable 'company-backends)
       (append '((company-capf company-dabbrev-code company-yasnippet)) company-backends)))

(set-formatter! 'fourmolu "fourmolu" :modes '(haskell-mode))

(setq haskell-stack-compile-command "stack build --test --bench --no-run-tests --no-run-benchmarks --ghc-options='-j4 +RTS -A256m -I0 -RTS -Wwarn' --no-interleaved-output"
      haskell-stack-test-command "stack build --test"
      lsp-haskell-server-path "haskell-language-server-wrapper"
      lsp-haskell-formatting-provider "fourmolu"
      lsp-haskell-tactic-on nil
      lsp-haskell-diagnostics-on-change nil)

(setq-hook! 'haskell-mode-hook
  compile-command haskell-compile-cabal-build-command
  display-fill-column-indicator-column 100
  ormolu-process-path "fourmolu")

(add-hook! haskell-mode 'display-fill-column-indicator-mode)
(add-hook! haskell-mode 'ormolu-format-on-save-mode)
(add-hook! haskell-mode 'haskell-company-backends)
(add-hook! haskell-mode (set (make-local-variable 'compile-command)
                             haskell-stack-compile-command))

;; LSP
(setq
 lsp-ui-sideline-enable nil
 lsp-ui-doc-enable nil
 lsp-ui-doc-max-height 30
 lsp-ui-doc-max-height 100
 lsp-enable-file-watchers nil
 lsp-before-save-edits nil)

(setq +format-on-save-enabled-modes
      '(not emacs-lisp-mode
	    haskell-mode
	    sql-mode
            yaml-mode))

;; Ivy
(setq! ivy-case-fold-search t
       ivy-virtual-abbreviate 'full
       ivy-extra-directories nil)
(add-to-list 'completion-ignored-extensions ".hie")
(add-to-list 'completion-ignored-extensions ".stack-work")

;; Smudge
(after! smudge
  (setq! smudge-oauth2-client-secret "")
  (setq! smudge-oauth2-client-id "")
  (define-key smudge-mode-map (kbd "C-c .") 'smudge-command-map)
  (setq! smudge-transport 'connect))

;; Slack
(setq! slack-prefer-current-team t)
(setq! slack-buffer-emojify t)

;; Secrets
(when (file-exists-p! "secrets.el" doom-user-dir)
  (load! "secrets.el" doom-user-dir))

(require 'org-table)
(defun md-table-align ()
  (interactive)
  (org-table-align)
  (save-excursion
    (goto-char (point-min))
    (while (search-forward "-+-" nil t) (replace-match "-|-"))))


(after! projectile
  (projectile-register-project-type 'haskell-stack '("stack.yaml")
                                    :compile haskell-stack-compile-command
                                    :test haskell-stack-test-command))

(set-eshell-alias! "shake" "stack exec shake --")

(add-hook! rjsx-mode 'prettier-js-mode)

;; (setq! doom-font (font-spec :name "terminus" :size 24))

(put 'haskell-hoogle-command 'safe-local-variable #'stringp)
(put 'haskell-hoogle-server-command 'safe-local-variable (lambda (_) t))
