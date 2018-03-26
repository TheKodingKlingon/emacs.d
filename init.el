;;; .emacs.d/init.el --- -*- lexical-binding: t; -*-

;;; Commentary:

;; A Klingon Koding Warrior's Bat'Leth

;;; Code:

;; Set up package archives
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Set up some custom key bindings
(global-set-key (kbd "C-x k") #'kill-this-buffer)

(use-package zoom-window
  :ensure t
  :defer t
  :bind (("C-x l" . zoom-window-zoom)
         ("C-x j" . zoom-window-next))
  :init
  (setq-default zoom-window-mode-line-color "light blue"))

(global-set-key (kbd "C-x L") #'delete-other-windows)
(global-set-key (kbd "C-x q") #'delete-window)
(global-set-key (kbd "C-x \\") #'split-window-horizontally)
(global-set-key (kbd "C-x -") #'split-window-vertically)

;; Stop cluttering with backup files
(setq backup-directory-alist '((".*" . "~/.emacs.d/.tmp")))
(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files

;; Default web browser
(setq browse-url-browser-function 'browse-url-firefox)

;; Tabs are evil
(setq-default indent-tabs-mode nil)

;; No alarm bells
(setq ring-bell-function 'ignore)

;; Split windows vertically by default
(setq split-width-threshold nil)

;; Select *help* buffer automatically
(setq help-window-select t)

;; Hide things you don't want to see
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

;; Set default font
(set-frame-font "DejaVu Sans Mono-10" nil t)

;; Prefer y/n to yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; No startup screen
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Die whitespaces, die!
(add-to-list 'write-file-functions #'delete-trailing-whitespace)

;; Show row and column numbers
(column-number-mode 1)

;; Try packages without installing them
(use-package try
  :ensure t)

(use-package diminish
  :ensure t)

;; Load theme nord
(use-package nord-theme
  :ensure t
  :config
  (load-theme 'nord t))

;; Highlight matching parens
(use-package paren
  :init
  (show-paren-mode 1))

;; "How can I replace highlighted text with what I type?" (Emacs FAQ)
(use-package delsel
  :config
  (delete-selection-mode 1))

;; Refresh buffer when changed on disk
(use-package autorevert
  :diminish auto-revert-mode
  :config
  (global-auto-revert-mode 1))

;; Highlight hex colours
(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode)

(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(ns x))
  :config
  (exec-path-from-shell-initialize))

(use-package hydra
  :ensure t)

;; Such extensive editor, many key binding, wow
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

;; Enable syntax highlighting in programming modes
(use-package flycheck
  :ensure t
  :init
  (setq-default flycheck-idle-change-delay 0.5)
  :config
  (defhydra hydra-flycheck-error (global-map "C-c ! !")
    "Flycheck errors"
    ("n" flycheck-next-error "next error")
    ("p" flycheck-previous-error "previous error"))
  (add-hook 'prog-mode-hook #'flycheck-mode))

;; Enable autocomplete in programming modes
(use-package company
  :ensure t
  :diminish company-mode
  :init
  (setq-default company-echo-delay 0
                company-idle-delay 0.2
                company-minimum-prefix-length 3)
  :config
  (add-hook 'prog-mode-hook #'company-mode))


(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode))

;; Sometimes the best fix is turning it off and on again
(use-package restart-emacs
  :ensure t
  :defer t
  :bind (("C-x M-r" . restart-emacs))
  :init
  (setq restart-emacs-restore-frames t))

;; Move Where I Mean
(use-package mwim
  :ensure t
  :defer t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
	 ("C-e" . mwim-end)))

;; Win at windowing
(use-package ace-window
  :ensure t
  :defer t
  :bind (("C-x o" . ace-window))
  :init
  (setq aw-keys '(?h ?j ?k ?l ?a ?s ?d ?f)))

(use-package feature-mode
  :ensure t
  :mode ("\\.feature\\'". feature-mode))

(use-package json-mode
  :ensure t
  :mode ("\\.json\\'" . json-mode)
  :init
  (setq-default js-indent-level 2))

;; Add JS support
(use-package js2-mode
  :ensure t
  :mode ("\\.js\\'" . js2-mode)
  :defer t
  :bind (:map js2-mode-map
         ("C-c C-j" . counsel-imenu))
  :init
  (setq-default js2-basic-offset 2
		js2-strict-trailing-comma-warning nil)
  :config
  (add-hook 'js2-mode-hook #'js2-imenu-extras-mode))

(use-package company-tern
  :disabled
  :ensure t
  :diminish term-mode
  :after js2-mode
  :init
  (add-hook 'js2-mode-hook (lambda () (add-to-list 'company-backend 'company-tern)))
  :config
  (add-hook 'js2-mode-hook #'tern-mode))

(use-package js2-refactor
  :ensure t
  :diminish js2-refactor-mode
  :after js2-mode
  :defer t
  :bind (:map js2-mode-map
         ("C-k" . js2r-kill))
  :init
  (js2r-add-keybindings-with-prefix "C-c C-r")
  :config
  (add-hook 'js2-mode-hook #'js2-refactor-mode))

(use-package xref-js2
  :disabled
  :ensure t
  :after js2-mode
  :defer t
  :bind (:map js-mode-map
         ("M-." . nil))
  :config
  (add-hook 'js2-mode-hook (lambda () (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t))))

(use-package rjsx-mode
  :ensure t
  :defer t
  :init
  (setq-default js2-strict-trailing-comma-warning nil))

(use-package prettier-js
  :ensure t
  :diminish prettier-js-mode
  :after (rjsx-mode js2-mode)
  :init
  (add-hook 'rjsx-mode-hook 'prettier-js-mode)
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  :config
  (setq prettier-js-args '("--trailing-comma" "all"
			   "--single-quote" "true")))

(use-package typescript-mode
  :ensure t
  :mode ("\\.ts\\'" "\\.tsx\\'"))

(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package fill-column-indicator
  :ensure t
  :init
  (add-hook 'python-mode-hook #'fci-mode))

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :defer t
  :bind (:map python-mode-map
         ("C-c C-j" . counsel-imenu))
  :init
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "--simple-prompt -i"
        python-shell-virtualenv-root "~/.venv"
        python-shell-completion-native-disabled-interpreters '("ipython" "pypy")))

(use-package company-jedi
  :ensure t
  :after python
  :defer t
  :bind (:map python-mode-map
         ("M-." . jedi:goto-definition)
         ("M-," . jedi:goto-definition-pop-marker))
  :init
  (setq jedi:complete-on-dot t)
  (add-hook 'python-mode-hook (lambda () (add-to-list 'company-backends 'company-jedi))))

(use-package yapfify
  :ensure t
  :after python
  :init
  (add-hook 'python-mode-hook 'yapf-mode))

(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "sbcl"
	slime-contribs '(slime-fancy)))

(use-package geiser
  :ensure t)

(use-package csv-mode
  :ensure t
  :mode ("\\.csv\\'" . csv-mode))

(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" . yaml-mode))

(use-package treemacs
  :ensure t)

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package sql
  :mode ("\\.sql\\'" . sql-mode)
  :init
  (add-hook 'sql-interactive-mode-hook #'smartparens-mode))

(use-package undo-tree
  :ensure t
  :defer t
  :diminish undo-tree-mode
  :bind (("C-x u" . undo-tree-visualize))
  :init
  (setq undo-tree-visualizer-diff t
        undo-tree-visualizer-timestamps t)
  (global-undo-tree-mode)
  :config
  ;; NOTE: `undo-tree-visualizer-diff' is disabled on exit for some reason, turn it back on!
  (advice-add 'undo-tree-visualizer-quit :after (lambda () (setq undo-tree-visualizer-diff t))))

;; Magit is magical
(use-package magit
  :ensure t
  :bind (("C-c m b" . magit-blame)
         ("C-c m l" . magit-log-current)
         ("C-c m m" . magit-show-refs-head)
         ("C-c m s" . magit-status))
  :init
  (setq magit-diff-refine-hunk 'all)
  (advice-add 'magit-show-refs-head :after #'delete-other-windows)
  (advice-add 'magit-status :after #'delete-other-windows))

(use-package git-timemachine
  :ensure t
  :defer t
  :bind (("C-c m t" . git-timemachine)))

(use-package vc-git
  :defer t
  :bind (("C-c m a" . vc-annotate)))

(use-package browse-at-remote
  :ensure t
  :defer t
  :bind (("C-c m w" . browse-at-remote)))

(use-package edit-server
  :ensure t)

;; Smart parentheses are smart
(use-package smartparens
  :ensure t
  :defer t
  :diminish smartparens-mode
  :bind (("C-k" . sp-kill-hybrid-sexp)
         :map smartparens-mode-map
         ("<C-M-backspace>" . sp-splice-sexp)
         ("C-M-]" . sp-select-next-thing)
         ("C-M-}" . sp-select-previous-thing)
         ("C-M-a" . sp-backward-down-sexp)
         ("C-M-b" . sp-backward-sexp)
         ("C-M-d" . sp-down-sexp)
         ("C-M-e" . sp-up-sexp)
         ("C-M-f" . sp-forward-sexp)
         ("C-M-n" . sp-next-sexp)
         ("C-M-p" . sp-previous-sexp)
         ("C-M-u" . sp-backward-up-sexp)
         ("C-]" . sp-select-next-thing-exchange))
  :init
  ;; Use it everywhere
  (smartparens-global-mode 1)
  :config
  ;; Use default config
  (use-package smartparens-config)
  ;; Apply strict mode to all Lisp modes
  (mapc (lambda (mode)
          (add-hook (intern (format "%s-hook" (symbol-name mode)))
                    'smartparens-strict-mode))
        sp-lisp-modes))

;; Dumb jump is smart too!
(use-package dumb-jump
  :ensure t
  :defer t
  :bind (("C-c C-." . dumb-jump-go)
         ("C-c C-," . dumb-jump-back))
  :init
  (setq-default dumb-jump-selector 'ivy
                dumb-jump-prefer-search 'rg))

;; Use `browse-kill-ring' instead of `counsel-yank-pop'
(use-package browse-kill-ring
  :ensure t
  :defer t
  :bind (("C-c r y" . browse-kill-ring)
         :map browse-kill-ring-mode-map
         ("C-g" . browse-kill-ring-quit))
  :init
  (setq browse-kill-ring-highlight-current-entry t
        browse-kill-ring-highlight-inserted-item t
        browse-kill-ring-display-duplicates nil
        browse-kill-ring-resize-window '(25 . 25)
        browse-kill-ring-show-preview nil))

;; Make M-x smart again
(use-package smex
  :ensure t
  :init
  (smex-initialize))

(use-package avy
  :ensure t
  :defer t
  :bind (("C-'" . avy-goto-word-1))
  :config
  (avy-setup-default))

(use-package ivy
  :ensure t
  :diminish ivy-mode
  :defer t
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-c r r" . ivy-resume))
  :init
  (setq enable-recursive-minibuffers t
        ivy-display-style 'fancy
        ivy-fixed-height-minibuffer t
        ivy-height 20
        ivy-use-virtual-buffers t
        ivy-wrap t)
  :config
  (ivy-mode 1))

(use-package ivy-hydra
  :ensure t
  :config
  (define-key ivy-minibuffer-map "\C-o"
    (defhydra soo-ivy (:hint nil :color pink)
      "
 Move     ^^^^^^^^^^ | Call         ^^^^ | Cancel^^ | Options^^ | Action _w_/_s_/_a_: %s(ivy-action-name)
----------^^^^^^^^^^-+--------------^^^^-+-------^^-+--------^^-+---------------------------------
 _g_ ^ ^ _p_ ^ ^ _u_ | _f_orward _o_ccur | _i_nsert | _c_alling: %-7s(if ivy-calling \"on\" \"off\") _C_ase-fold: %-10`ivy-case-fold-search
 ^↨^ _h_ ^+^ _l_ ^↕^ | _RET_ done     ^^ | _q_uit   | _m_atcher: %-7s(ivy--matcher-desc) _t_runcate: %-11`truncate-lines
 _G_ ^ ^ _n_ ^ ^ _d_ | _TAB_ alt-done ^^ | ^ ^      | _<_/_>_: shrink/grow
"
      ;; arrows
      ("n" ivy-next-line)
      ("p" ivy-previous-line)
      ("l" ivy-alt-done)
      ("h" ivy-backward-delete-char)
      ("g" ivy-beginning-of-buffer)
      ("G" ivy-end-of-buffer)
      ("d" ivy-scroll-up-command)
      ("u" ivy-scroll-down-command)
      ("e" ivy-scroll-down-command)
      ;; actions
      ("q" keyboard-escape-quit :exit t)
      ("C-g" keyboard-escape-quit :exit t)
      ("<escape>" keyboard-escape-quit :exit t)
      ("C-o" nil)
      ("i" nil)
      ("TAB" ivy-alt-done :exit nil)
      ("C-j" ivy-alt-done :exit nil)
      ;; ("d" ivy-done :exit t)
      ("RET" ivy-done :exit t)
      ("C-m" ivy-done :exit t)
      ("f" ivy-call)
      ("c" ivy-toggle-calling)
      ("m" ivy-toggle-fuzzy)
      (">" ivy-minibuffer-grow)
      ("<" ivy-minibuffer-shrink)
      ("w" ivy-prev-action)
      ("s" ivy-next-action)
      ("a" ivy-read-action)
      ("t" (setq truncate-lines (not truncate-lines)))
      ("C" ivy-toggle-case-fold)
      ("o" ivy-occur :exit t))))

(use-package counsel
  :ensure t
  :defer t
  :after ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable)
         ("C-h M-f" . counsel-describe-face)
         ("C-x r b" . counsel-bookmark)
         ("C-c C-j" . counsel-imenu)
         ("C-x M-t" . counsel-load-theme)))

(use-package swiper
  :ensure t
  :defer t
  :bind (("C-s" . swiper))
  :after ivy
  :config
  (defun swiper-at-point ()
    (interactive)
    (swiper (thing-at-point 'symbol))))

;; Project management at its best
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :init
  (setq-default projectile-switch-project-action 'magit-show-refs-head
                projectile-completion-system 'ivy)
  :config
  (projectile-mode))

;; When Counsel meets Projectile (NOTE: Requires `rg')
(use-package counsel-projectile
  :ensure t
  :defer t
  :bind (:map projectile-mode-map
         ("C-c p s s" . counsel-projectile-rg))
  :init
  (setq-default counsel-projectile-mode t))


;;; init.el ends here
