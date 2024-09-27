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
(defvar data-dir "~/.emacs.d/data/")
(defvar cache-dir "~/.emacs.d/cache/")
(defvar user-dir "~/.emacs.d")
(setq byte-compile-warnings '(not interactive-only)) ;报错滚吧
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
   rime-share-data-dir "~/.emacs.d/rime"
   rime-user-data-dir "~/.emacs.d/rime"))

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
          (?~ . orderless-flex)))
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
  :defer t

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
(use-package exato
  :commands evil-outer-xml-attr evil-inner-xml-attr)
(use-package evil-quick-diff
  :quelpa (evil-quick-diff :fetcher github :repo "rgrinberg/evil-quick-diff"))
;; format
(defcustom +format-on-save-disabled-modes
  '(sql-mode           ; sqlformat is currently broken
    tex-mode           ; latexindent is broken
    latex-mode
    LaTeX-mode
    org-msg-edit-mode) ; doesn't need a formatter
  "A list of major modes in which to not reformat the buffer upon saving.

  If it is t, it is disabled in all modes, the same as if the +onsave flag wasn't
  used at all.
  If nil, formatting is enabled in all modes."
  :type '(list symbol))
;; format +onsave
(defvaralias '+format-with 'apheleia-formatter)
(defvaralias '+format-inhibit 'apheleia-inhibit)
(use-package apheleia
  :defer t
  :hook (after-init . apheleia-global-mode))
;; snippets          ; my elves. They type so I don't have to
(defvar yas-snippet-dirs "~/.emacs.d/yasnippet")
(use-package yasnippet
  :init
  (defvar yas-verbosity 2))
(use-package auto-yasnippet
  :defer t
  :config
  (setq aya-persist-snippets-dir +snippets-dir))

;; ====== emacs ======
;;dired             ; making dired pretty [functionul]
(setq dired-dwim-target t  ; suggest a target for moving/copying intelligently
      ;; don't prompt to revert, just do it
      dired-auto-revert-buffer #'dired-buffer-stale-p
      ;; Always copy/delete recursively
      dired-recursive-copies  'always
      dired-recursive-deletes 'top
      ;; Ask whether destination dirs should get created when copying/removing files.
      dired-create-destination-dirs 'ask
      ;; Where to store image caches
      image-dired-dir (concat cache-dir "image-dired/")
      image-dired-db-file (concat image-dired-dir "db.el")
      image-dired-gallery-dir (concat image-dired-dir "gallery/")
      image-dired-temp-image-file (concat image-dired-dir "temp-image")
      image-dired-temp-rotate-image-file (concat image-dired-dir "temp-rotate-image")
      ;; Screens are larger nowadays, we can afford slightly larger thumbnails
      image-dired-thumb-size 150)
(use-package dirvish
  :init
  (setq dirvish-cache-dir (concat cache-dir "dirvish"))
  :config
  (dirvish-override-dired-mode)
  (setq dirvish-reuse-session nil)
  (setq dirvish-attributes '(file-size)
        dirvish-mode-line-format
        '(:left (sort file-time symlink) :right (omit yank index)))
  (setq dirvish-attributes nil
        dirvish-use-header-line nil
        dirvish-use-mode-line nil)
  (setq dirvish-subtree-always-show-state t))
(use-package diredfl
  :hook (dired-mode . diredfl-mode)
  :hook (dirvish-directory-view-mode . diredfl-mode))
(use-package dired-x
  :ensure nil
  :hook (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-verbose nil
        dired-omit-files
        (concat dired-omit-files
                "\\|^\\.DS_Store\\'"
                "\\|^flycheck_.*"
                "\\|^\\.project\\(?:ile\\)?\\'"
                "\\|^\\.\\(?:svn\\|git\\)\\'"
                "\\|^\\.ccls-cache\\'"
                "\\|\\(?:\\.js\\)?\\.meta\\'"
                "\\|\\.\\(?:elc\\|o\\|pyo\\|swp\\|class\\)\\'"))
  ;; Disable the prompt about whether I want to kill the Dired buffer for a
  ;; deleted directory. Of course I do!
  (setq dired-clean-confirm-killing-deleted-buffers nil)
  ;; Let OS decide how to open certain files
  (when-let (cmd (cond ((featurep :system 'macos) "open")
                       ((featurep :system 'linux) "xdg-open")
                       ((featurep :system 'windows) "start")))
    (setq dired-guess-shell-alist-user
          `(("\\.\\(?:docx\\|pdf\\|djvu\\|eps\\)\\'" ,cmd)
            ("\\.\\(?:jpe?g\\|png\\|gif\\|xpm\\)\\'" ,cmd)
            ("\\.\\(?:xcf\\)\\'" ,cmd)
            ("\\.csv\\'" ,cmd)
            ("\\.tex\\'" ,cmd)
            ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|rm\\|rmvb\\|ogv\\)\\(?:\\.part\\)?\\'" ,cmd)
            ("\\.\\(?:mp3\\|flac\\)\\'" ,cmd)
            ("\\.html?\\'" ,cmd)
            ("\\.md\\'" ,cmd)))))
(use-package dired-aux
  :ensure nil
  :defer t
  :init
  (require 'dired-aux)
  :config
  (setq dired-create-destination-dirs 'ask
        dired-vc-rename-file t))
;;electric          ; smarter, keyword-based electric-indent
(defvar-local +electric-indent-words '()
  "The list of electric words. Typing these will trigger reindentation of the
  current line.")

;;使用 with-eval-after-load 顶替 after!
(with-eval-after-load 'electric
  (setq-default electric-indent-chars '(?\n ?\^?))

  (add-hook 'electric-indent-functions-hook
            (defun +electric-indent-char-fn (_c)
              (when (and (eolp) +electric-indent-words)
                (save-excursion
                  (backward-word)
                  (looking-at-p (concat "\\<" (regexp-opt +electric-indent-words))))))))
;;undo              ; persistent, smarter undo for your inevitable mistakes
(use-package undo-fu
  :hook (window-setup-hook . undo-fu-mode)
  :config
  (setq undo-limit 400000           ; 400kb (default is 160kb)
        undo-strong-limit 3000000   ; 3mb   (default is 240kb)
        undo-outer-limit 48000000)  ; 48mb  (default is 24mb)
  (define-minor-mode undo-fu-mode
    "Enables `undo-fu' for the current session."
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map [remap undo] #'undo-fu-only-undo)
              (define-key map [remap redo] #'undo-fu-only-redo)
              (define-key map (kbd "C-_")     #'undo-fu-only-undo)
              (define-key map (kbd "M-_")     #'undo-fu-only-redo)
              (define-key map (kbd "C-M-_")   #'undo-fu-only-redo-all)
              (define-key map (kbd "C-x r u") #'undo-fu-session-save)
              (define-key map (kbd "C-x r U") #'undo-fu-session-recover)
              map)
    :init-value nil
    :global t))
(use-package undo-fu-session
  :hook (undo-fu-mode . global-undo-fu-session-mode)
  :custom (undo-fu-session-directory (concat cache-dir "undo-fu-session"))
  :config
  (setq undo-fu-session-incompatible-files '("\\.gpg$" "/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))

  (when (executable-find "zstd")
    ;; There are other algorithms available, but zstd is the fastest, and speed
    ;; is our priority within Emacs
    (setq undo-fu-session-compression 'zst)))
(use-package vundo
  :defer t
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols
        vundo-compact-display t))
;;vc                ; version-control and Emacs, sitting in a tree
(setq-default vc-handled-backends '(SVN Git Hg))
;; 设置特定模式的初始状态为 emacs
(with-eval-after-load 'log-view
  (evil-set-initial-state 'log-view-mode 'emacs)
  (evil-set-initial-state 'vc-git-log-view-mode 'emacs)
  (evil-set-initial-state 'vc-hg-log-view-mode 'emacs)
  (evil-set-initial-state 'vc-bzr-log-view-mode 'emacs)
  (evil-set-initial-state 'vc-svn-log-view-mode 'emacs))
(use-package vc :ensure nil)
(use-package vc-annotate
  :ensure nil
  :config
  (evil-set-initial-state 'vc-annotate-mode 'normal))
(with-eval-after-load 'vc-dir
  (evil-set-initial-state 'vc-dir-mode 'emacs))
(use-package smerge-mode
  :ensure nil
  :defer t
  :config
  (add-hook 'find-file-hook
            (defun +vc-init-smerge-mode-h ()
              (unless (bound-and-true-p smerge-mode)
                (save-excursion
                  (goto-char (point-min))
                  (when (re-search-forward "^<<<<<<< " nil t)
                    (smerge-mode 1)))))))

(use-package browse-at-remote)
(use-package git-timemachine
  :quelpa (git-timemachine :fetcher github :repo "emacsmirror/git-timemachine")
  :config
  (setq git-timemachine-show-minibuffer-details t)
  (with-eval-after-load 'evil
    (add-hook 'git-timemachine-mode-hook #'evil-normalize-keymaps)))
(use-package git-modes)
;;;;=======term======
;;vterm             ; 用过的最吼的
(use-package vterm
  :hook (vterm-mode . hide-mode-line-mode)
  :config
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 5000)
  (evil-set-initial-state 'vterm-mode 'emacs))


;;:tools
;;(eval +overlay)     ; run code, run (also, repls)
(setq eval-expression-print-length nil
      eval-expression-print-level  nil)
(use-package quickrun
  :config
  (setq quickrun-focus-p nil)
  (add-hook 'quickrun-after-run-hook
            (defun +eval-quickrun-shrink-window-h ()
              "Shrink the quickrun output window once code evaluation is complete."
              (when-let (win (get-buffer-window quickrun--buffer-name))
                (with-selected-window (get-buffer-window quickrun--buffer-name)
                  (let ((ignore-window-parameters t))
                    (shrink-window-if-larger-than-buffer)))))
            (defun +eval-quickrun-scroll-to-bof-h ()
              "Ensures window is scrolled to BOF on invocation."
              (when-let (win (get-buffer-window quickrun--buffer-name))
                (with-selected-window win
                  (goto-char (point-min)))))))
(use-package eros
  :hook (emacs-lisp-mode . eros-mode))

;;(magit +forge)            ; a git porcelain for Emacs
(defvar +magit-open-windows-in-direction 'right
  "What direction to open new windows from the status buffer.
  For example, diffs and log buffers. Accepts `left', `right', `up', and `down'.")

(defvar +magit-fringe-size '(13 . 1)
  "Size of the fringe in magit-mode buffers.

  Can be an integer or a cons cell whose CAR and CDR are integer widths for the
  left and right fringe.

  Only has an effect in GUI Emacs.")
(use-package magit
  :init
  (setq magit-auto-revert-mode nil)  ; we do this ourselves further down
  ;; Must be set early to prevent ~/.config/emacs/transient from being created
  (setq transient-levels-file (concat data-dir "transient/levels")
        transient-values-file (concat data-dir "transient/values")
        transient-history-file (concat data-dir "transient/history"))
  :config
  (setq transient-default-level 5
        magit-diff-refine-hunk t ; show granular diffs in selected hunk
        ;; Don't autosave repo buffers. This is too magical, and saving can
        ;; trigger a bunch of unwanted side-effects, like save hooks and
        ;; formatters. Trust the user to know what they're doing.
        magit-save-repository-buffers nil
        ;; Don't display parent/related refs in commit buffers; they are rarely
        ;; helpful and only add to runtime costs.
        magit-revision-insert-related-refs nil)
  (add-hook 'magit-process-mode-hook #'goto-address-mode)
                                        ; (unless (file-exists-p "~/.git-credential-cache/")
                                        ;   (setq magit-credential-cache-daemon-socket
                                        ;         (doom-glob (or (getenv "XDG_CACHE_HOME")
                                        ;                        "~/.cache/")
                                        ;                    "git/credential/socket")))
  (defvar +magit--pos nil)
  (define-key magit-mode-map "q" #'+magit/quit)
  (define-key magit-mode-map "Q" #'+magit/quit-all)
  (define-key transient-map [escape] #'transient-quit-one))
(use-package forge
  :preface
  (setq forge-database-file (concat data-dir "forge/forge-database.sqlite"))
  (setq forge-add-default-bindings t))
                                        ;(use-package code-review
                                        ;  :after magit
                                        ;  :init
                                        ;  (setq code-review-db-database-file (concat data-dir "code-review/code-review-db-file.sqlite")
                                        ;        code-review-log-file (concat data-dir "code-review/code-review-error.log")
                                        ;        code-review-download-dir (concat data-dir "code-review/")))
;;make              ; run make tasks from Emacs
(use-package makefile-executor)
;;tree-sitter       ; syntax and parsing, sitting in a tree...
(defvar +tree-sitter-hl-enabled-modes '(not web-mode typescript-tsx-mode))
(use-package tree-sitter-langs)
(use-package tree-sitter
  :defer t
  :config
  (require 'tree-sitter-langs)
  ;; This makes every node a link to a section of code
  (setq tree-sitter-debug-jump-buttons t
        ;; and this highlights the entire sub tree in your code
        tree-sitter-debug-highlight-jump-region t))
(use-package tree-sitter-indent)
;;upload            ; map local to remote projects via ssh/ftp
(use-package ssh-deploy
  :init
  (setq ssh-deploy-revision-folder (concat cache-dir "ssh-revisions/")
        ssh-deploy-on-explicit-save 1
        ssh-deploy-automatically-detect-remote-changes nil))
;; lsp
(use-package lsp-mode
                                        ;  :disabled t
  :init
  (setq lsp-session-file (concat cache-dir "lsp-session")
        lsp-server-install-dir (concat data-dir "lsp"))
  (setq lsp-keep-workspace-alive nil)
  (setq lsp-enable-folding nil
        lsp-enable-text-document-color nil)
  ;; Reduce unexpected modifications to code
  (setq lsp-enable-on-type-formatting nil)
  ;; Make breadcrumbs opt-in; they're redundant with the modeline and imenu
  (setq lsp-headerline-breadcrumb-enable nil)
  :config
  (setq lsp-intelephense-storage-path (concat data-dir "lsp-intelephense/")
        lsp-vetur-global-snippets-dir
        (expand-file-name
         "vetur" (or (bound-and-true-p +snippets-dir)
                     (concat user-dir "snippets/")))
        lsp-xml-jar-file (expand-file-name "org.eclipse.lsp4xml-0.3.0-uber.jar" lsp-server-install-dir)
        lsp-groovy-server-file (expand-file-name "groovy-language-server-all.jar" lsp-server-install-dir))
  (add-hook 'lsp-mode-hook #'+lsp-optimization-mode)
  (add-hook 'lsp-completion-mode-hook
            (defun +lsp-init-company-backends-h ()
              (when lsp-completion-mode
                (set (make-local-variable 'company-backends)
                     (cons +lsp-company-backends
                           (remove +lsp-company-backends
                                   (remq 'company-capf company-backends)))))))
  (defvar +lsp--deferred-shutdown-timer nil))
(use-package lsp-ui
                                        ;  :disabled t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-peek-enable 1
        lsp-ui-doc-max-height 8
        lsp-ui-doc-max-width 72         ; 150 (default) is too wide
        lsp-ui-doc-delay 0.75           ; 0.2 (default) is too naggy
        lsp-ui-doc-show-with-mouse nil  ; don't disappear on mouseover
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-ignore-duplicate t
        ;; Don't show symbol definitions in the sideline. They are pretty noisy,
        ;; and there is a bug preventing Flycheck errors from being shown (the
        ;; errors flash briefly and then disappear).
        lsp-ui-sideline-show-hover nil
        ;; Re-enable icon scaling (it's disabled by default upstream for Emacs
        ;; 26.x compatibility; see emacs-lsp/lsp-ui#573)
        lsp-ui-sideline-actions-icon lsp-ui-sideline-actions-icon-default))
(use-package consult-lsp
                                        ;  :disabled t
  :defer t)
;;;; =======os======
;;(:if IS-MAC macos)  ; improve compatibility with macOS
;;(use-package ns-auto-titlebar)
;;tty +osc               ; improve the terminal Emacs experience
(setq xterm-set-window-title t)
(setq visible-cursor nil)
(add-hook 'tty-setup-hook #'xterm-mouse-mode)
(use-package xclip)
(use-package clipetty)
(use-package evil-terminal-cursor-changer
  :hook (tty-setup . evil-terminal-cursor-changer-activate))
(use-package kkp
  :hook (after-init . global-kkp-mode))
;;;; =======lang======
;; ansible
(use-package ansible
  :config
  (setq ansible-section-face 'font-lock-variable-name-face
        ansible-task-label-face 'font-lock-doc-face)
  (add-to-list 'company-backends 'company-ansible))
(use-package ansible-doc
  :config
  (evil-set-initial-state '(ansible-doc-module-mode) 'emacs))
(use-package jinja2-mode
  :disabled t
  :mode "\\.j2\\"
  :config
  (setq jinja2-enable-indent-on-save nil))
(use-package yaml-mode)
(use-package company-ansible)

;;(agda +local)              ; types of types of types of types...
(use-package agda2-mode
  :quelpa (agda2-mode :fetcher github :repo "agda/agda"
                      :files ("src/data/emacs-mode/*.el" (:exclude "agda-input.el"))
                      :nonrecursive t))
;;(cc +lsp)         ; C > C++ == 1
(use-package cmake-mode)
(use-package cuda-mode)
(use-package demangle-mode)
(use-package disaster)
(use-package opencl-c-mode)
(use-package ccls)

;;common-lisp       ; if you've seen one lisp, you've seen them all
;;coq               ; proofs-as-programs
;;emacs-lisp         ; drown in parentheses
(use-package rainbow-delimiters)
(use-package elisp-mode :ensure nil
  :mode ("\\.Cask\\'" . emacs-lisp-mode)
  :config
  (add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)
  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)
  (add-hook 'emacs-lisp-mode-hook #'highlight-quoted-mode))
(use-package ielm
  :defer t
  :config
  (setq ielm-font-lock-keywords
        (append '(("\\(^\\*\\*\\*[^*]+\\*\\*\\*\\)\\(.*$\\)"
                   (1 font-lock-comment-face)
                   (2 font-lock-constant-face)))
                (when (require 'highlight-numbers nil t)
                  (highlight-numbers--get-regexp-for-mode 'emacs-lisp-mode))
                (cl-loop for (matcher . match-highlights)
                         in (append lisp-el-font-lock-keywords-2
                                    lisp-cl-font-lock-keywords-2)
                         collect
                         `((lambda (limit)
                             (when ,(if (symbolp matcher)
                                        `(,matcher limit)
                                      `(re-search-forward ,matcher limit t))
                               ;; Only highlight matches after the prompt
                               (> (match-beginning 0) (car comint-last-prompt))
                               ;; Make sure we're not in a comment or string
                               (let ((state (syntax-ppss)))
                                 (not (or (nth 3 state)
                                          (nth 4 state))))))
                           ,@match-highlights)))))
(use-package highlight-quoted)
(use-package helpful
  :hook (hepful-mode . visual-line-mode)
  :init
  (setq apropos-do-all t)
  (with-eval-after-load 'apropos
    ;; patch apropos buttons to call helpful instead of help
    (dolist (fun-bt '(apropos-function apropos-macro apropos-command))
      (button-type-put
       fun-bt 'action
       (lambda (button)
         (helpful-callable (button-get button 'apropos-symbol)))))
    (dolist (var-bt '(apropos-variable apropos-user-option))
      (button-type-put
       var-bt 'action
       (lambda (button)
         (helpful-variable (button-get button 'apropos-symbol)))))))
(use-package macrostep)
(use-package overseer)
;;;###package overseer
(autoload 'overseer-test "overseer" nil t)
;; Properly lazy load overseer by not loading it so early:
(remove-hook 'emacs-lisp-mode-hook #'overseer-enable-mode)

(use-package elisp-def)
(use-package elisp-demos
  :defer t)
                                        ;(use-package buttercup
                                        ;:defer t
                                        ;:commands (buttercup-run-tests)
                                        ;:config
                                        ;("/test[/-].+\\.el$" . buttercup-minor-mode)
                                        ;(add-hook 'buttercup-minor-mode-hook #'yas-minor-mode)
                                        ;(add-hook 'buttercup-minor-mode-hook #'evil-normalize-keymaps))

;;ess               ; R 语言统计包
;;fsharp            ; ML stands for Microsoft's Language
;;(latex +fold +cdlatex)             ; writing papers in Emacs has never been so fun
;;lean              ; for folks with too much o prove
;;lua               ; one-based indices? one-based indices
;;(markdown +grip)          ; writing docs for people to ignore
(use-package markdown-mode
  :mode ("/README\\(?:\\.md\\)?\\'" . gfm-mode)
  :init
  (setq markdown-italic-underscore t
        markdown-asymmetric-header t
        markdown-gfm-additional-languages '("sh")
        markdown-make-gfm-checkboxes-buttons t
        markdown-fontify-whole-heading-line t
        markdown-fontify-code-blocks-natively t
        markdown-command #'+markdown-compile
        ;; This is set to `nil' by default, which causes a wrong-type-arg error
        ;; when you use `markdown-open'. These are more sensible defaults.
        markdown-open-command
        (cond ((featurep :system 'macos) "open")
              ((featurep :system 'linux) "xdg-open"))

        ;; A sensible and simple default preamble for markdown exports that
        ;; takes after the github asthetic (plus highlightjs syntax coloring).
        markdown-content-type "application/xhtml+xml"
        markdown-css-paths
        '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
          "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css")
        markdown-xhtml-header-content
        (concat "<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>"
                "<style> body { box-sizing: border-box; max-width: 740px; width: 100%; margin: 40px auto; padding: 0 10px; } </style>"
                "<script id='MathJax-script' async src='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js'></script>"
                "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js'></script>"
                "<script>document.addEventListener('DOMContentLoaded', () => { document.body.classList.add('markdown-body'); document.querySelectorAll('pre[lang] > code').forEach((code) => { code.classList.add(code.parentElement.lang); }); document.querySelectorAll('pre > code').forEach((code) => { hljs.highlightBlock(code); }); });</script>")))
(use-package markdown-toc)
;;nix               ; I hereby declare "nix geht mehr!"
;;ocaml             ; an objective camel
;;(org +dragndrop +journal +hugo +present +pomodoro)               ; contacts 与 jupyter 还没相活
(use-package org
  :quelpa (org :fetcher github :repo "emacs-straight/org-mode" :files (:defaults "etc")
               :depth 1 :build t))
                                        ;(use-package org-contrib :quelpa (org-contrib :fetcher github :repo "emacsmirror/org-conrtib"))
(use-package avy)
(use-package htmlize)
(use-package ox-clip)
(use-package toc-org)
(use-package org-cliplink)
(use-package orgit)
(use-package orgit-forge)
(use-package org-download)
(use-package gnuplot)
(use-package gnuplot-mode)
(use-package org-journal)
(use-package org-noter)
(use-package org-superstar)
(use-package centered-window)
(use-package org-tree-slide)
(use-package org-re-reveal)
(use-package revealjs
  :ensure t
  :defer t
  :quelpa (revealjs :fetcher github :repo "hakimel/reveal.js" :files ("css" "dist" "js" "plugin")))
(use-package ob-async)
(use-package ox-pandoc)
;;php               ; perl's insecure younger brother
;;plantuml          ; diagrams for confusing people more
;;(python +conda)            ; beautiful is better than ugly
;;(racket +xp +lsp)            ; a DSL for DSLs
;;(scheme +guile)   ; a fully conniving family of lisps
;;(sh +fish +powershell)  ; she sells {ba,z,fi}sh shells on the C xor
;;web               ; the tubes
;;yaml                ; JSON, but readable
;;:config

;;literate                    ;
;;(default +bindings +smartparens))
(use-package avy
  :config
  (setq avy-all-windows nil
        avy-all-windows-alt t
        avy-background t
        ;; the unpredictability of this (when enabled) makes it a poor default
        avy-single-candidate-jump nil))
(setq tramp-default-method "ssh")
(use-package link-hint)
;;;; ============ CENTAURS ============
(use-package minions
  :hook (doom-modeline-mode . minions-mode))
(use-package nerd-icons
  :config
  (if t (nerd-icons-install-fonts t) nil))
(use-package display-line-numbers
  :ensure nil
  :hook ((prog-mode yaml-mode yaml-ts-mode conf-mode) . display-line-numbers-mode)
  :init (setq display-line-numbers-width-start t))
(setq use-file-dialog nil
      use-dialog-box nil
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-scratch-message nil)
(unless (daemonp)
  (advice-add #'display-startup-echo-area-message :override #'ignore))
(use-package time
  :init (setq display-time-default-load-average nil
              display-time-format "%H:%M"))
(setq scroll-step 1
      scroll-margin 0
      scroll-conservatively 100000
      auto-window-vscroll nil
      scroll-preserve-screen-position t)
(if (fboundp 'pixel-scroll-precision-mode)
    (pixel-scroll-precision-mode t)
  (unless sys/macp
    (use-package good-scroll
      :diminish
      :hook (after-init . good-scroll-mode)
      :bind (([remap next] . good-scroll-up-full-screen)
             ([remap prior] . good-scroll-down-full-screen))))good-scroll)
;; (use-package alert ; 可惜不支持中文
;;   :quelpa (:fetcher github :repo "jwiegley/alert"))
(use-package grip-mode)
(use-package ox-gfm
  :quelpa (:fetcher github
                    :repo "larstvei/ox-gfm"
                    :files ("*.el")))
(use-package helm-bibtex)
(use-package cnfonts)

;; When using bibtex-completion via the `biblio` module
(use-package ob-powershell
  :quelpa (:fetcher github :repo "rkiggen/ob-powershell"))
(use-package bison-mode
  :quelpa (:fetcher github :repo "Wilfred/bison-mode" :files ("*.el")))
(use-package flex-mode
  :quelpa (:fetcher github :repo "manateelazycat/flex" :files ("*.el")))
(use-package j-mode
  :quelpa (:fetcher github :repo "LdBeth/j-mode" :files ("*.el")))
(use-package anki-editor)
;;;; ============= CONFIG =============

(setq frame-resize-pixelwise t)         ;窗口大小调整像素级别
(setq tab-width 2)                      ;tab宽度
(setq blink-cursor-mode 0)
(setq idle-update-delay 1.0)
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
(setq fast-but-imprecise-scrolling t)
(setq redisplay-skip-fontification-on-input t)
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Initial frame
(setq initial-frame-alist '((top . 0.5)
                            (left . 0.5)
                            (width . 0.628)
                            (height . 0.8)
                            (fullscreen)))

(setq-default cursor-type 'hollow)
(setq default-frame-alist
      (append ;                        Note: if there are any conflicting settings in ‘default-frame-alist’, it is the one that comes first that gets applied.
       '(;(undecorated . t)
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
        ("C-f" . forward-char)
        ("C-b" . backward-char)
        ("C-u" . nil)
        ("C-k". org-kill-line)))
(dolist (pair my/evil-insert-binding)
  (evil-global-set-key 'insert (kbd (car pair)) (cdr pair)))
(setq org-startup-numerated t)          ; 设置org目录编号
(setq org-structure-template-alist ; org模板，其他语言
      (append org-structure-template-alist
              '(("el" . "src emacs-lisp")
                ("sh" . "src bash")
                ("py" . "src python :results output")
                ("fi" . "src fish")
                ("js" . "src javascript")
                ("cc" . "src c")
                ("cp" . "src cpp")
                ("plm" . "src plantuml\n@startmindmap")
                ("pw" . "src powershell"))))
(setq system-time-locale "zh_CN")
(setq chinese-calendar-celestial-stem
      ["甲" "乙" "丙" "丁" "戊" "己" "庚" "辛" "壬" "癸"])
(setq chinese-calendar-terrestrial-branch
      ["子" "丑" "寅" "卯" "辰" "巳" "午" "未" "申" "酉" "戌" "亥"])
(defvar chinese-shuxiang-name
  ["鼠" "牛" "虎" "兔" "龙" "蛇" "马" "羊" "猴" "鸡" "狗" "猪"])
(nth 5 (decode-time))

(defun chinese-year (year)
  "返回农历年份"
  (concat
   (aref chinese-calendar-celestial-stem
         (% (- year 4) 10))
   (aref chinese-calendar-terrestrial-branch
         (% (- year 4) 12))
   (aref chinese-shuxiang-name
         (% (- year 4) 12))
   "年"))
(setq chinese-year-now (chinese-year (nth 5 (decode-time))))
(setq org-journal-file-type 'monthly)    ; 设置日记文件类型，每一个文件一个月，因为一年的文件太他妈大而卡死了
(setq org-journal-file-format (concat "%Y-" chinese-year-now)) ; 把年份加入文件名
(setq org-journal-date-format "%Y/%m/%d W%W D%j（%a）")
(format-time-string "%Y/%m/%d W%W D%j (%a)")

;; 这个是手动看字体如何，手动可以调出粗体但是感觉这个来日用还是太粗了
;; 虽然己经等宽了，但是感觉还是用cnfonts 熟悉
(use-package cnfonts
  :ensure t
  :after all-the-icons
  :hook (cnfonts-set-font-finish
         . (lambda (fontsize-list)
             (set-fontset-font t 'unicode (font-spec :family "all-the-icons") nil 'append)
             (set-fontset-font t 'unicode (font-spec :family "file-icons") nil 'append)
             (set-fontset-font t 'unicode (font-spec :family "Material Icons") nil 'append)
             (set-fontset-font t 'unicode (font-spec :family "github-octicons") nil 'append)
             (set-fontset-font t 'unicode (font-spec :family "FontAwesome") nil 'append)
             (set-fontset-font t 'unicode (font-spec :family "Weather Icons") nil 'append)))
  :config
  (set-fontset-font "fontset-default" 'unicode "Apple Color Emoji" nil 'prepend)
  (global-set-key (kbd "C--") 'cnfonts-decrease-fontsize)
  (global-set-key (kbd "C-=") 'cnfonts-increase-fontsize)
  (setq cnfonts-profiles '("normal")
        cnfonts-directory (concat user-dir "cnfonts")
        cnfonts-personal-fontnames
        '(;;英文字体
          ("Liga SFMono Nerd font" "SF Pro Text" "IosevkaTerm Nerd Font Mono"
           "Iosevka Term")
          ;; 中文字体
          ("PingFang SC"
           "Source Han Serif SC"
           "LXGW Wenkai")))
  (cnfonts-enable))
(cnfonts-mode 1)

(use-package pangu-spacing
  :config
  (global-pangu-spacing-mode 1)
  (setq pangu-spacing-real-insert-separtor t))
