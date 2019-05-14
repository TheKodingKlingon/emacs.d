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

;; Minimise distraction
(blink-cursor-mode 0)

;; Stop cluttering with backup files
(setq backup-directory-alist '((".*" . "~/.emacs.d/.tmp")))
(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files

;; Tabs are evil
(setq-default indent-tabs-mode nil)

;; No alarm bells
(setq ring-bell-function 'ignore)

;; Select *help* buffer automatically
(setq help-window-select t)

;; Hide things you don't want to see
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

;; Set default font
(set-frame-font "DejaVu Sans Mono-10" nil t)

;; No startup screen
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Die whitespaces, die!
(add-to-list 'write-file-functions #'delete-trailing-whitespace)

;; Customisation info to be saved in a separate file
(setq custom-file "~/.emacs.d/custom.el")

;; Show row and column numbers
(column-number-mode 1)

;; Load theme
(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :config
  (load-theme 'sanityinc-tomorrow-night t))

;; Highlight matching parens
(use-package paren
  :init
  (show-paren-mode 1))

;; Refresh buffer when changed on disk
(use-package autorevert
  :diminish auto-revert-mode
  :init
  (setq auto-revert-interval 2)
  :config
  (global-auto-revert-mode 1))

;; Try packages without installing them
(use-package try
  :ensure t)

(use-package diminish
  :ensure t)

(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode)

(use-package hydra
  :ensure t)

;; Enable autocomplete in programming modes
(use-package company
  :ensure t
  :diminish company-mode
  :init
  (setq-default company-echo-delay 0
                company-idle-delay 0.2
                company-minimum-prefix-length 1)
  :config
  (add-hook 'prog-mode-hook #'company-mode))

(use-package company-quickhelp
  :ensure t
  :hook (company-mode . company-quickhelp-mode))

;; Enable syntax highlighting in programming modes
(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :init
  (setq-default flycheck-idle-change-delay 0.5
                flycheck-check-syntax-automatically '(mode-enabled save))
  :config
  (add-hook 'prog-mode-hook #'flycheck-mode))

(use-package flymake
  :diminish flymake-mode
  :config
  (defhydra hydra-flymake-error (global-map "C-c ! !")
    "Flymake errors"
    ("n" flymake-goto-next-error "next error")
    ("p" flymake-goto-prev-error "previous error")))

;; Such extensive editor, many key binding, wow
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

(use-package eglot
  :ensure t
  :config
  (add-to-list 'eglot-server-programs '(python-mode . ("pyls")))
  (add-to-list 'eglot-server-programs '(js2-mode . ("javascript-typescript-stdio")))
  (add-to-list 'eglot-server-programs '(typescript-mode . ("javascript-typescript-stdio")))
  (add-to-list 'eglot-server-programs '(javascript-mode . ("javascript-typescript-stdio"))))

(use-package lsp-mode
  :ensure t
  :init
  (add-hook 'python-mode-hook #'lsp)
  (add-hook 'js2-mode-hook #'lsp)
  (add-hook 'javascript-mode-hook #'lsp)
  (add-hook 'typescript-mode-hook #'lsp))

(use-package company-lsp
  :ensure t
  :after lsp-mode
  :init
  (setq company-lsp-async t
        company-lsp-enable-recompletion t
        company-lsp-enable-snippet nil)
  :config
  (push 'company-lsp company-backends))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode))

(use-package mwim
  :ensure t
  :defer t
  :bind (("C-a" . mwim-beginning-of-code-or-line)))

;; Add JS support
(use-package js2-mode
  :ensure t
  :mode ("\\.js\\'" . js2-mode)
  :defer t
  :bind (:map js2-mode-map
         ("C-c C-j" . counsel-semantic-or-imenu)
         ("M-." . lsp-find-definition)
         ("C-c C-c C-d" . eglot-help-at-point))
  :init
  (setq-default js2-basic-offset 2)
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

(use-package json-mode
  :ensure t
  :mode ("\\.[json|tpl]\\'" . json-mode)
  :init
  (setq-default js-indent-level 2))

(use-package prettier-js
  :ensure t
  :diminish prettier-js-mode
  :hook
  (js2-mode . prettier-js-mode)
  (typescript-mode . prettier-js-mode))

(use-package typescript-mode
  :ensure t
  :mode ("\\.ts\\'" . typescript-mode))

(use-package tide
  :ensure t
  :diminish tide-mode
  :after typescript-mode
  :config
  (add-hook 'typescript-mode-hook #'tide-setup))

(use-package fill-column-indicator
  :disabled
  :ensure t
  :init
  (setq fci-rule-column 99)
  (add-hook 'python-mode-hook #'fci-mode))

(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" . yaml-mode))

(use-package treemacs
  :disabled
  :ensure t)

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
  (advice-add 'undo-tree-visualizer-quit :after (lambda () (setq undo-tree-visualizer-diff t))))

;; Magit is magical
(use-package magit
  :ensure t
  :bind (("C-c m b" . magit-blame-addition)
         ("C-c m l" . magit-log-current)
         ("C-c m L" . magit-log-buffer-file)
         ("C-c m m" . magit-show-refs-head)
         ("C-c m s" . magit-status))
  :init
  (setq-default magit-diff-refine-hunk 'all
                projectile-switch-project-action 'magit-show-refs-head))

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

(use-package git-gutter
  :disabled
  :ensure t
  :bind (("C-c m g" . git-gutter-mode))
  :init
  (setq git-gutter:always-show-separator t
        git-gutter:window-width 1)
  (global-git-gutter-mode 1))


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
         ("C-]" . sp-select-next-thing-exchange)
         ("C-)" . sp-forward-slurp-sexp)
         ("C-<right>" . sp-forward-slurp-sexp)
         ("C-}" . sp-forward-barf-sexp)
         ("C-<left>" . sp-forward-barf-sexp)
         ("C-(" . sp-backward-slurp-sexp)
         ("C-M-<left>" . sp-backward-slurp-sexp)
         ("C-{" . sp-backward-barf-sexp)
         ("C-M-<right>" . sp-backward-barf-sexp))
  :init
  ;; Use it everywhere
  (smartparens-global-mode 1)
  (show-smartparens-mode 1)
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

;; Make M-x smart again
(use-package smex
  :ensure t
  :init
  (smex-initialize))

(use-package avy
  :ensure t
  :defer t
  :bind (("C-:" . avy-goto-word-1))
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
  :diminish counsel-mode
  :defer t
  :after ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable)
         ("C-h M-f" . counsel-describe-face)
         ("C-x r b" . counsel-bookmark)
         ("C-c C-j" . counsel-semantic-or-imenu)
         ("C-x M-t" . counsel-load-theme)
         ("M-y" . counsel-yank-pop)
         :map ivy-minibuffer-map
         ("M-y" . ivy-next-line)
         ("M-Y" . ivy-previous-line))
  :init
  (setq counsel-yank-pop-separator "
                    
")
  (counsel-mode))

;; Be helpful (Override counsel key bindings where possible)
(use-package helpful
  :ensure t
  :after counsel
  :bind (("C-h f" . helpful-callable)
         ("C-h F" . helpful-function)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-c C-d" . helpful-at-point)
         ("C-c C" . helpful-command)))

(use-package elisp-mode
  :bind ("C-c C-k" . eval-buffer))

(use-package swiper
  :ensure t
  :defer t
  :bind (("C-s" . swiper))
  :after ivy
  :config
  (defun swiper-at-point ()
    (interactive)
    (swiper (thing-at-point 'symbol))))

(use-package ivy-lobsters
  :ensure t)

;; Project management at its best
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :init
  (setq-default projectile-completion-system 'ivy
                projectile-keymap-prefix (kbd "C-c p")
                projectile-project-compilation-cmd ""
                projectile-project-run-cmd ""
                projectile-project-test-cmd "")
  :config
  (projectile-mode)
  (define-key projectile-mode-map (kbd "C-c p F") #'counsel-fzf))

;; When Counsel meets Projectile (NOTE: Requires `rg')
(use-package counsel-projectile
  :ensure t
  :defer t
  :bind (:map projectile-mode-map
         ("C-c p s s" . counsel-projectile-rg))
  :init
  ;; NOTE: Only counsel-projectile-rg command is needed from this package, do not override projectile key bindings
  (setq-default counsel-projectile-mode nil))

(use-package fzf
  :ensure t
  :init
  (setq fzf/position-bottom t
        fzf/window-height 20))

;;; init.el ends here
