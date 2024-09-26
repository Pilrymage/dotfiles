;;; -*- lexical-binding: t -*-
(require 'package)
;; 初始化包管理器
(package-initialize)

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(add-to-list 'load-path "/home/pilrymage/.guix-profile/share/emacs/site-lisp")
(guix-emacs-autoload-packages) ;; 使用 guix 预加载包

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(use-package quelpa
  :config ; 在 (require) 之后需要执行的表达式
  (use-package quelpa-use-package) ; 把 quelpa 嵌入 use-package 的宏扩展
  (quelpa-use-package-activate-advice)) ; 启用这个 advice

(use-package better-defaults)
(use-package rime
  :bind (:map rime-mode-map
              ("C-`" . 'rime-send-keybinding)
              ("`" . 'rime-inline-ascii))
  :custom (default-input-method "rime")
  (rime-librime-root "~/.emacs.d/librime/dist")
  :config
  (global-set-key (kbd "`") 'rime-inline-ascii) ; 用于切换中英文
  (setq         ;; rime-show-candidate 'posframe ;; 用形码就不需要候选框
        rime-inline-ascii-holder ?x
        rime-user-data-dir "~/.emacs.d/rime"))
(use-package vterm)

;;; =====COMPLETION======
;; company
(use-package company
  :hook (after-init . global-company-mode)
  :init
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never
        company-idle-delay 0.26
        company-global-modes
        '(not erc-mode
              circe-mode
              message-mode
              help-mode
              gud-mode
              vterm-mode)
        company-frontends
        '(company-pseudo-tooltip-frontend  ; always show candidates in overlay tooltip
          company-echo-metadata-frontend)  ; show selected candidate docs in echo area

        ;; Buffer-local backends will be computed when loading a major mode, so
        ;; only specify a global default here.
        company-backends '(company-capf)

        ;; These auto-complete the current selection when
        ;; `company-auto-commit-chars' is typed. This is too magical. We
        ;; already have the much more explicit RET and TAB.
        company-auto-commit nil

        ;; Only search the current buffer for `company-dabbrev' (a backend that
        ;; suggests text your open buffers). This prevents Company from causing
        ;; lag once you have a lot of buffers open.
        company-dabbrev-other-buffers nil
        ;; Make `company-dabbrev' fully case-sensitive, to improve UX with
        ;; domain-specific words with particular casing.
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil)
  :config
  ;; evil 
  )
;; vertico
(use-package vertico
  :custom
  (setq vertico-resize nil
        vertico-count 17
        vertico-scroll-margin 3
        vertico-cycle t)
  :init
  (vertico-mode))
(use-package orderless
  :config
  (setq orderless-affix-dispatch-alist
        '((?! . orderless-without-literal)
          (?& . orderless-annotation)
          (?% . char-fold-to-regexp)
          (?` . orderless-initialism)
          (?= . orderless-literal)
          (?^ . orderless-literal-prefix)
          (?~ . orderless-flex))
        orderless-style-dispatchers
        '(+vertico-orderless-dispatch
          +vertico-orderless-disambiguation-dispatch))
  (add-to-list
   'completion-styles-alist
   '(+vertico-basic-remote
     +vertico-basic-remote-try-completion
     +vertico-basic-remote-all-completions
     "Use basic completion on remote files only"))
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;; note that despite override in the name orderless can still be used in
        ;; find-file etc.
        completion-category-overrides '((file (styles +vertico-basic-remote orderless partial-completion)))
        orderless-component-separator #'orderless-escapable-split-on-space)
  ;; ...otherwise find-file gets different highlighting than other commands
  (set-face-attribute 'completions-first-difference nil :inherit nil))
(use-package consult
  :defer t
  :config
  (setq consult-project-function #'doom-project-root
        consult-narrow-key "<"
        consult-line-numbers-widen t
        consult-async-min-input 2
        consult-async-refresh-delay  0.15
        consult-async-input-throttle 0.2
        consult-async-input-debounce 0.1
        consult-fd-args
        '((if (executable-find "fdfind" 'remote) "fdfind" "fd")
          "--color=never"
          ;; https://github.com/sharkdp/fd/issues/839
          "--full-path --absolute-path"
          "--hidden --exclude .git"
          (if (featurep :system 'windows) "--path-separator=/"))))
(use-package consult-dir
  :defer t)
(use-package consult-flycheck
  :after (consult flycheck))
(use-package consult-yasnippet
  :defer t)
(use-package embark
  :defer t)
(use-package marginalia
  :hook (after-init . marginalia-mode))
(use-package wgrep
  :config (setq wgrep-auto-save-buffer t))
(use-package vertico-posframe
  :hook (vertico-mode . vertico-posframe-mode)
  :config
  (add-hook 'doom-after-reload-hook #'posframe-delete-all))

;;; ====== UI ======
;; theme
(use-package dracula-theme
  :config
  (load-theme 'dracula t))
;; emoji +unicode
(use-package emojify
  :hook (after-init . global-emojify-mode)
  :config (emojify-set-emoji-styles (list 'unicode)))
; hl-todo
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :hook (yaml-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        '(;; For reminders to change or add something at a later date.
          ("TODO" warning bold)
          ;; For code (or code paths) that are broken, unimplemented, or slow,
          ;; and may become bigger problems later.
          ("FIXME" error bold)
          ;; For code that needs to be revisited later, either to upstream it,
          ;; improve it, or address non-critical issues.
          ("REVIEW" font-lock-keyword-face bold)
          ;; For code smells where questionable practices are used
          ;; intentionally, and/or is likely to break in a future update.
          ("HACK" font-lock-constant-face bold)
          ;; For sections of code that just gotta go, and will be gone soon.
          ;; Specifically, this means the code is deprecated, not necessarily
          ;; the feature it enables.
          ("DEPRECATED" font-lock-doc-face bold)
          ;; Extra keywords commonly found in the wild, whose meaning may vary
          ;; from project to project.
          ("NOTE" success bold)
          ("BUG" error bold)
          ("XXX" font-lock-constant-face bold))))
;; hydra is dead
;; indent-guides
(use-package indent-bars
  :hook (prog-mode . indent-bars-mode)
  ;; tree-sitter
  )

;; modeline
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :init
  (setq projectile-dynamic-mode-line nil)
  (setq doom-modeline-bar-width 3
        doom-modeline-github nil
        doom-modeline-mu4e nil
        doom-modeline-persp-name nil
        doom-modeline-minor-modes nil
        doom-modeline-major-mode-icon nil
        doom-modeline-buffer-file-name-style 'relative-from-project
        ;; Only show file encoding if it's non-UTF-8 and different line endings
        ;; than the current OSes preference
        doom-modeline-buffer-encoding 'nondefault
        doom-modeline-default-eol-type 0))
(use-package anzu
  :ensure t
  :defer t
  :hook (isearch-mode . (lambda () (require 'anzu))))
(use-package evil-anzu
  :after (evil)
  :config (global-anzu-mode +1))
;; nav-flash -> pulsar.el
(use-package pulsar)
;; neotree
(use-package neotree
    :commands (neotree-show
             neotree-hide
             neotree-toggle
             neotree-dir
             neotree-find
             neo-global--with-buffer
             neo-global--window-exists-p)
  :init
  (setq neo-create-file-auto-open nil
        neo-auto-indent-point nil
        neo-autorefresh nil
        neo-mode-line-type 'none
        neo-window-width 30
        neo-show-updir-line nil
        neo-theme 'nerd
        neo-banner-message nil
        neo-confirm-create-file #'off-p
        neo-confirm-create-directory #'off-p
        neo-show-hidden-files nil
        neo-keymap-style 'concise
        neo-show-hidden-files t
        neo-hidden-regexp-list
        '(;; vcs folders
          "^\\.\\(?:git\\|hg\\|svn\\)$"
          ;; compiled files
          "\\.\\(?:pyc\\|o\\|elc\\|lock\\|css.map\\|class\\)$"
          ;; generated files, caches or local pkgs
          "^\\(?:node_modules\\|vendor\\|.\\(project\\|cask\\|yardoc\\|sass-cache\\)\\)$"
          ;; org-mode folders
          "^\\.\\(?:sync\\|export\\|attach\\)$"
          ;; temp files
          "~$"
          "^#.*#$")))
;; ophints
(use-package goggles                    ; evil
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (goggles-define +goggles-general-undo undo) ; goggles only supports `primitive-undo' by default
  (goggles-define +goggles-register-paste insert-register)
  (goggles-define +goggles-kill-word backward-kill-word kill-word)
  (goggles-define +goggles-undo-fu undo-fu-only-undo undo-fu-only-redo))
;; popup +defaults
;; treemacs
;; unicode
(use-package unicode-fonts)
;; vc-gutter +pretty
;; vi-tilde-fringe
;; workspaces
;; zen
(use-package writeroom-mode
  :config
  (defvar +zen--old-writeroom-global-effects writeroom-global-effects)
  (setq writeroom-global-effects nil)
  (setq writeroom-maximize-window nil))
(use-package mixed-pitch
  :hook (writeroom-mode . +zen-enable-mixed-pitch-mode-h)
  :config
  (defun +zen-enable-mixed-pitch-mode-h ()
    "Enable `mixed-pitch-mode' when in `+zen-mixed-pitch-modes'."
    (when (apply #'derived-mode-p +zen-mixed-pitch-modes)
      (mixed-pitch-mode (if writeroom-mode +1 -1)))))
;;; ====== editor ======
(defvar +evil-want-o/O-to-continue-comments t
  "If non-nil, the o/O keys will continue comment lines if the point is on a
line with a linewise comment.")

(defvar +evil-want-move-window-to-wrap-around nil
  "If non-nil, `+evil/window-move-*' commands will wrap around.")

(defvar +evil-preprocessor-regexp "^\\s-*#[a-zA-Z0-9_]"
  "The regexp used by `+evil/next-preproc-directive' and
`+evil/previous-preproc-directive' on ]# and [#, to jump between preprocessor
directives. By default, this only recognizes C directives.")
(defvar evil-want-Y-yank-to-eol t)
(defvar evil-want-abbrev-expand-on-insert-exit nil)
(defvar evil-respect-visual-line-mode nil)
(defvar evil-want-C-g-bindings t)
(defvar evil-want-C-i-jump nil)  ; we do this ourselves
(defvar evil-want-C-u-scroll t)  ; moved the universal arg to <leader> u
(defvar evil-want-C-u-delete t)
(defvar evil-want-C-w-delete t)
(use-package evil
  :hook (after-init . evil-mode)
  :ensure t
  :preface
  (setq evil-ex-search-vim-style-regexp t
        evil-ex-visual-char-range t  ; column range for ex commands
        evil-mode-line-format 'nil
        ;; more vim-like behavior
        evil-symbol-word-search t
        ;; if the current state is obvious from the cursor's color/shape, then
        ;; we won't need superfluous indicators to do it instead.
        evil-default-cursor '+evil-default-cursor-fn
        evil-normal-state-cursor 'box
        evil-emacs-state-cursor  '(box +evil-emacs-cursor-fn)
        evil-insert-state-cursor 'bar
        evil-visual-state-cursor 'hollow
        ;; Only do highlighting in selected window so that Emacs has less work
        ;; to do highlighting them all.
        evil-ex-interactive-search-highlight 'selected-window
        ;; It's infuriating that innocuous "beginning of line" or "end of line"
        ;; errors will abort macros, so suppress them:
        evil-kbd-macro-suppress-motion-error t
        evil-undo-system 'undo-redo)
  :config
   (evil-select-search-module 'evil-search-module 'evil-search)

  ;; PERF: Stop copying the selection to the clipboard each time the cursor
  ;; moves in visual mode. Why? Because on most non-X systems (and in terminals
  ;; with clipboard plugins like xclip.el active), Emacs will spin up a new
  ;; process to communicate with the clipboard for each movement. On Windows,
  ;; older versions of macOS (pre-vfork), and Waylang (without pgtk), this is
  ;; super expensive and can lead to freezing and/or zombie processes.
  ;;
  ;; UX: It also clobbers clipboard managers (see emacs-evil/evil#336).
   (setq evil-visual-update-x-selection-p nil)
   ;; Start help-with-tutorial in emacs state
   (advice-add #'help-with-tutorial :after (lambda (&rest _) (evil-emacs-state +1)))
   (defun +evil-default-cursor-fn ()
    (evil-set-cursor-color (get 'cursor 'evil-normal-color)))
  (defun +evil-emacs-cursor-fn ()
    (evil-set-cursor-color (get 'cursor 'evil-emacs-color))))

  ;; Ensure `evil-shift-width' always matches `tab-width'; evil does not police
  ;; this itself, so we must.

(use-package evil-args)
(use-package evil-easymotion
  :config
  ;; Use evil-search backend, instead of isearch
  (evilem-make-motion evilem-motion-search-next #'evil-ex-search-next
                      :bind ((evil-ex-search-highlight-all nil)))
  (evilem-make-motion evilem-motion-search-previous #'evil-ex-search-previous
                      :bind ((evil-ex-search-highlight-all nil)))
  (evilem-make-motion evilem-motion-search-word-forward #'evil-ex-search-word-forward
                      :bind ((evil-ex-search-highlight-all nil)))
  (evilem-make-motion evilem-motion-search-word-backward #'evil-ex-search-word-backward
                      :bind ((evil-ex-search-highlight-all nil)))
    ;; Rebind scope of w/W/e/E/ge/gE evil-easymotion motions to the visible
  ;; buffer, rather than just the current line.
  (put 'visible 'bounds-of-thing-at-point (lambda () (cons (window-start) (window-end))))
  (evilem-make-motion evilem-motion-forward-word-begin #'evil-forward-word-begin :scope 'visible)
  (evilem-make-motion evilem-motion-forward-WORD-begin #'evil-forward-WORD-begin :scope 'visible)
  (evilem-make-motion evilem-motion-forward-word-end #'evil-forward-word-end :scope 'visible)
  (evilem-make-motion evilem-motion-forward-WORD-end #'evil-forward-WORD-end :scope 'visible)
  (evilem-make-motion evilem-motion-backward-word-begin #'evil-backward-word-begin :scope 'visible)
  (evilem-make-motion evilem-motion-backward-WORD-begin #'evil-backward-WORD-begin :scope 'visible)
  (evilem-make-motion evilem-motion-backward-word-end #'evil-backward-word-end :scope 'visible)
  (evilem-make-motion evilem-motion-backward-WORD-end #'evil-backward-WORD-end :scope 'visible))
(use-package evil-embrace
:hook (LaTeX-mode . embrace-LaTeX-mode-hook)
  :hook (LaTeX-mode . +evil-embrace-latex-mode-hook-h)
  :hook (org-mode . embrace-org-mode-hook)
  :hook (ruby-mode . embrace-ruby-mode-hook)
  :hook (emacs-lisp-mode . embrace-emacs-lisp-mode-hook)
  :hook ((c++-mode c++-ts-mode rustic-mode csharp-mode java-mode swift-mode typescript-mode)
         . +evil-embrace-angle-bracket-modes-hook-h)
:hook (scala-mode . +evil-embrace-scala-mode-hook-h)
:config
(setq evil-embrace-show-help-p nil))
(use-package evil-exchange)
(use-package evil-indent-plus)
(use-package evil-lion)
(use-package evil-nerd-commenter)
(use-package evil-numbers)
(use-package evil-surround
 :config (global-evil-surround-mode 1))
(use-package evil-textobj-anyblock)
(use-package evil-traces
:config (evil-traces-mode))

;(use-package evil-visualstar
;  :commands '(evil-visualstar/begin-search
;             evil-visualstar/begin-search-forward
;             evil-visualstar/begin-search-backward)
;(evil-define-key* 'visual 'global
;    "*" #'evil-visualstar/begin-search-forward
;    "#" #'evil-visualstar/begin-search-backward))
(use-package exato
 :commands evil-outer-xml-attr evil-inner-xml-attr)
(use-package evil-quick-diff
  :quelpa (evil-quick-diff :fetcher github :repo "rgrinberg/evil-quick-diff"))

;;;; ============= CONFIG =============

(setq frame-resize-pixelwise t)         ;窗口大小调整像素级别
(setq tab-width 2)                      ;tab宽度
(setq blink-cursor-mode 0)
(setq-default cursor-type 'hollow)
(setq default-frame-alist
      (append ;                        Note: if there are any conflicting settings in ‘default-frame-alist’, it is the one that comes first that gets applied.
       '((undecorated . t)
         (drag-internal-border . t)
         (internal-border-width . 4))
       default-frame-alist))
(setq scroll-margin 4) ; 显示上下边界，让光标不至于在屏幕边缘
(setq display-line-numbers-type t)      ; 行号显示
(setq org-directory "~/org")            ; org主目录，也是很多东西被organized的主目录，简短仅次于根目录
(setq org-roam-directory "~/orgroam")   ; roam特别地需要一个目录
(setq my/org-agenda-inbox "~/org/agenda/inbox.org") ; inbox.org的路径
(setq org-roam-database-connector 'sqlite)

;;; ====== Evil ======
(setq evil-shift-width 2) ; 设置evil的缩进宽度
(setq evil-want-C-i-jump nil)           ; 设置tab键的行为
(defun repeat-command (proc times)      ; 重复执行数次
  (dotimes (_ times)
	(funcall proc)))
(defun my/previous-five-line ()         ; 往下走五行
  (interactive)
  (repeat-command 'evil-previous-line 5))
(defun my/next-five-line ()             ; 往上行五行
  (interactive)
  (repeat-command 'evil-next-line 5))

(setq my/evil-global-binding '(         ; colemak 键位的 vi
        ("u" . evil-previous-line)
        ("e" . evil-next-line)
        ("n" . evil-backward-char)
        ("i" . evil-forward-char)
        ;; ("w" . emt-forward-word)
        ;; ("b" . emt-backward-word)
        (",." . evil-jump-item)
        ("m" . evil-forward-word-end)
        ("M" . evil-forward-WORD-end)
        ("U" . my/previous-five-line)
        ("E" . my/next-five-line)
        ("N" . evil-beginning-of-line)
        ("I" . evil-end-of-line)
        ("j" . evil-undo)
        ("l" . evil-insert)
        ("L" . evil-insert-line)
        ("`" . evil-invert-char)
        ("Q" . kill-current-buffer)
        ("M" . execute-extended-command)
        (";" . evil-ex)
        ("h" . evil-forward-word-end)
        ("H" . evil-forward-word-end)
        ("k" . evil-ex-search-next)
        ("K" . evil-ex-search-previous)
        ("C-w u" . evil-window-up)
        ("C-w e" . evil-window-down)
        ("C-w n" . evil-window-left)
        ("C-w i" . evil-window-right)))

;; 注意到 U 键在 visual line 下不可用，是个 bug
(dolist (pair my/evil-global-binding)
    (evil-global-set-key 'normal (kbd (car pair)) (cdr pair))
    (evil-global-set-key 'visual (kbd (car pair)) (cdr pair)))
(setq my/evil-insert-binding
      '(("C-p" . previous-line)
      ("C-n" . next-line)
      ("C-u" . nil)
      ("C-k". org-kill-line)))
(dolist (pair my/evil-insert-binding)
    (evil-global-set-key 'insert (kbd (car pair)) (cdr pair)))
