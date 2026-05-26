;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
        ("http" . "127.0.0.1:7897")
        ("https" . "127.0.0.1:7897")))

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(dolist (path '("site-lisp"
                "site-lisp/01-core"
                "site-lisp/02-modules"
                "site-lisp/03-lang"
                "site-lisp/04-local"))
  (add-to-list 'load-path (expand-file-name path user-emacs-directory)))

                                        ; core
(require 'bootstrap)
(require 'options)

                                        ; modules
(require 'completion)
(require 'ui)
(require 'editor)
(require 'terminal)
(require 'os)
(require 'apps)

                                        ; lang
(require 'lang-general)
(require 'lang-org)

                                        ; local
(require 'chord-highlight)
(require 'org-wc-diff)
(require 'send-to-emacs)
(setq org-wc-diff-tracked-files '("D:/github/notes.org/2026.org"))
(global-org-wc-diff-mode 1)

(message "emacs init time %s" (emacs-init-time))

;;; init.el ends here

(load-file (let ((coding-system-for-read 'utf-8))
             (shell-command-to-string "agda-mode.exe locate")))
