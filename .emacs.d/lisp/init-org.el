(use-package org
  :bind (("C-c r" . denote-dired-rename-files)
         :map dired-mode-map)
  :hook (((org-babel-after-execute org-mode) . org-redisplay-inline-images) ; display image
         (visual-line-mode . org-mode)
         (org-indent-mode . (lambda()
                              ;; HACK: Prevent text moving around while using brackets
                              ;; @see https://github.com/seagle0128/.emacs.d/issues/88
                              (make-variable-buffer-local 'show-paren-mode)
                              (setq show-paren-mode nil))))
  :config
  ;; Define a custom face for list markers

  ;; Apply the custom face to unordered and ordered list markers
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "SPC") nil))


  (font-lock-add-keywords
   'org-mode
   '(("^\\( *[-+*]\\) " 1 'org-level-1 prepend)  ;; Unordered lists
     ;; ("^\\( *[0-9]+\\(?:\\.\\|)\\) )" 1 'org-level-1 prepend)
     ("^\\( *[0-9]+[\\.)]\\) " 1 'org-level-1 prepend)
     )) ;; Ordered lists
  (setq org-modules nil
        org-directory "~/org"
        org-todo-keywords
        '((sequence "TODO(t)" "DOING(i)" "HANGUP(h)" "|" "DONE(d)" "CANCEL(c)")
          (sequence "⚑(T)" "🏴(I)" "❓(H)" "|" "✔(D)" "✘(C)"))
        org-todo-keyword-faces '(("HANGUP" . warning)
                                 ("❓" . warning))
        org-priority-faces '((?A . error)
                             (?B . warning)
                             (?C . success))
        org-tags-column -80
        org-log-done 'time
        org-catch-invisible-edits 'smart
        org-startup-indented t
        org-startup-truncated nil
        org-ellipsis (if (char-displayable-p ?⏷) "\t⏷" nil)
        org-pretty-entities nil
        org-hide-emphasis-markers t)
  )

                                        ;(use-package org-contrib :straight (org-contrib :host github :repo "emacsmirror/org-conrtib"))


;; Prettify UI
(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))
(use-package avy
  :defer t)
(use-package htmlize
  :defer t)
(use-package ox-clip
  :defer t)
(use-package toc-org
  :defer t
  :hook (org-mode . toc-org-mode))
(use-package org-cliplink
  :defer t)

(use-package org-rich-yank
  :bind (:map org-mode-map
              ("C-M-y" . org-rich-yank)))
(use-package orgit
  :defer t)
(use-package orgit-forge
  :defer t)
(use-package org-download
  :defer t)
;; Preview
(use-package org-preview-html
  :diminish
  :bind (:map org-mode-map
              ("C-c C-h" . org-preview-html-mode))
  :init (when (and (featurep 'xwidget-internal) (display-graphic-p))
          (setq org-preview-html-viewer 'xwidget)))

(use-package gnuplot
  :defer t)
(use-package gnuplot-mode
  :defer t)
(use-package org-journal
  :defer t)
(use-package org-noter
  :defer t)
(use-package org-superstar
  :defer t)
(use-package centered-window
  :defer t)
;; Presentation
(use-package org-tree-slide
  :diminish
  :functions (org-display-inline-images
              org-remove-inline-images)
  :bind (:map org-mode-map
              ("s-<f7>" . org-tree-slide-mode)
              :map org-tree-slide-mode-map
              ("<left>" . org-tree-slide-move-previous-tree)
              ("<right>" . org-tree-slide-move-next-tree)
              ("S-SPC" . org-tree-slide-move-previous-tree)
              ("SPC" . org-tree-slide-move-next-tree))
  :hook ((org-tree-slide-play . (lambda ()
                                  (text-scale-increase 4)
                                  (org-display-inline-images)
                                  (read-only-mode 1)))
         (org-tree-slide-stop . (lambda ()
                                  (text-scale-increase 0)
                                  (org-remove-inline-images)
                                  (read-only-mode -1))))
  :init (setq org-tree-slide-header nil
              org-tree-slide-slide-in-effect t
              org-tree-slide-heading-emphasis nil
              org-tree-slide-cursor-init t
              org-tree-slide-modeline-display 'outside
              org-tree-slide-skip-done nil
              org-tree-slide-skip-comments t
              org-tree-slide-skip-outline-level 3))
(use-package org-re-reveal
  :defer t)
(require 'org-tempo)
(use-package revealjs
  :defer t
  :straight (revealjs :host github :repo "hakimel/reveal.js" :files ("css" "dist" "js" "plugin")))
(use-package ob-async
  :defer t)
(use-package ox-pandoc
  :defer t)
(use-package denote
  :bind
  :config
  (setq denote-directory (expand-file-name "~/Dropbox/denote")
        denote-sort-keywords nil
        denote-backlinks-show-context t
        denote-known-keywords '("项目" "领域" "资源" "归档")
        denote-file-type nil)
  (setq my/evil-org-binding
        '(("SPC n a" . org-toggle-narrow-to-subtree)
          ("SPC n A" . org-tree-to-indirect-buffer)
          ("SPC n n" . denote)
          ("SPC n d" . denote-sort-dired)
          ("SPC n i" . org-cliplink)
          ("SPC n l" . denote-link)
          ("SPC n L" . denote-add-links)
          ("SPC n b" . denote-backlinks)
          ("SPC n o" . denote-open-or-create)
          ("SPC n p" . org-priority)
          ("SPC n q" . org-set-tags-command)
          ("SPC n r" . denote-rename-file)
          ("SPC n R" . denote-rename-file-using-front-matter)
          ("SPC n t" . org-todo)))
  (dolist (pair my/evil-org-binding)
    (evil-define-key 'normal org-mode-map (kbd (car pair)) (cdr pair))))

(setq org-startup-numerated t)          ; 设置 org 目录编号
(setq org-tempo-keywords-alist ; org 模板，其他语言
      (append org-tempo-keywords-alist
              '(("el" . "src emacs-lisp")
                ("sh" . "src bash")
                ("py" . "src python :results output")
                ("fi" . "src fish")
                ("js" . "src javascript")
                ("cc" . "src c")
                ("cp" . "src cpp")
                ("plm" . "src plantuml\n@startmindmap")
                ("pw" . "src powershell"))))
                                        ; org 主目录，也是很多东西被 organized 的主目录，简短仅次于根目录
(setq org-roam-directory "~/orgroam")   ; roam 特别地需要一个目录
(setq my/org-agenda-inbox "~/org/agenda/inbox.org") ; inbox.org 的路径
(setq org-roam-database-connector 'sqlite)
(setq org-startup-numerated t)          ; 设置 org 目录编号
(setq org-confirm-babel-evaluate nil
      org-src-fontify-natively t
      org-src-tab-acts-natively t)
(setq org-journal-file-type 'monthly)    ; 设置日记文件类型，每一个文件一个月，因为一年的文件太他妈大而卡死了
;; (setq org-journal-file-format (concat "%Y-" chinese-year-now)) ; 把年份加入文件名
(setq org-journal-date-format "%Y/%m/%d W%W D%j（%a）")
(format-time-string "%Y/%m/%d W%W D%j (%a)")
(provide 'init-org)
;; Babel
