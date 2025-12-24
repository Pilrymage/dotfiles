;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

(setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10\\..*\\|192\\.168\\..*\\)")
        ("http" . "127.0.0.1:7890")
        ("https" . "127.0.0.1:7890")))

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(dolist (path '("site-lisp"
                "site-lisp/core"
                "site-lisp/modules"
                "site-lisp/lang"
                "site-lisp/local"))
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
(require 'general)
(require 'lang-org)

; local
(require 'chord-highlight)

(message "emacs init time %s" (emacs-init-time))

;;; init.el ends here
