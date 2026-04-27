;;; lang/org.el --- Org-mode setup -*- lexical-binding: t; -*-

(use-package org
  :bind (("C-c r" . denote-dired-rename-files)
         :map dired-mode-map)
  :hook (((org-babel-after-execute org-mode) . org-redisplay-inline-images) ; display image
         (visual-line-mode . org-mode))
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
        ;; org-tags-column -80
        org-log-done 'time
        org-catch-invisible-edits 'smart
        org-startup-indented t
        org-startup-truncated nil
        org-ellipsis (if (char-displayable-p ?⏷) "\t⏷" nil)
        org-pretty-entities nil
        org-attach-auto-tag nil
        org-hide-emphasis-markers t)
  )

                                        ;(use-package org-contrib :straight (org-contrib :host github :repo "emacsmirror/org-conrtib"))


;; Prettify UI
(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)))
(use-package org-modern-indent
  :ensure t
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))
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
  :config
  ;; 关键修改：必须使用 setq-default 全局修改这两个 buffer-local 变量
  (setq-default org-download-image-dir "./images")
  (setq-default org-download-heading-lvl nil)
  
  (setq org-download-timestamp "_%Y%m%d-%H%M%S")
  (add-hook 'dired-mode-hook 'org-download-enable))
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

(defgroup my/org-bullets nil
  "Bold + colored bullets by list indent level."
  :group 'org)

(defcustom my/org-bullet-colors
  ;; 可按主题自行调整
  '("DodgerBlue" "DarkOrange" "ForestGreen" "MediumOrchid"
    "Goldenrod" "IndianRed" "SteelBlue" "DarkCyan")
  "Colors used for list bullets by indent level (cycled)."
  :type '(repeat string))

(defun my/org--ensure-bullet-faces ()
  (cl-loop for i from 1 to (length my/org-bullet-colors) do
           (let* ((name (format "my/org-list-bullet-level-%d" i))
                  (face (intern name))
                  (color (nth (1- i) my/org-bullet-colors)))
             (unless (facep face) (make-face face))
             (set-face-attribute face nil :weight 'bold :foreground color))))

(defun my/org--indent-level-at (pos)
  "Compute list indent level at POS by indentation and org-list-indent-offset."
  (save-excursion
    (goto-char pos)
    (back-to-indentation)
    (let* ((indent (current-column))
           (offset (if (boundp 'org-list-indent-offset)
                       (max 1 org-list-indent-offset)
                     2)))
      (1+ (/ indent offset)))))

(defun my/org--bullet-face-for-level (level)
  (let* ((n (length my/org-bullet-colors))
         (idx (1+ (mod (1- level) n)))
         (sym (intern (format "my/org-list-bullet-level-%d" idx))))
    sym))

(defun my/org--fontify-list-bullets (limit)
  "Font-lock matcher to apply faces to list bullets by indent level."
  (my/org--ensure-bullet-faces)
  (let (found)
    (while (and (not found)
                (re-search-forward
                 ;; 匹配无序列表 (- + *) 或有序列表 (1. 1)
                 "^[ \\t]*\\\\([-*+]\\\\|[0-9]+[.)]\\\\)\\\\([ \\t]\\\\|$\\\\)"
                 limit t))
      (let* ((beg (match-beginning 1))
             (end (match-end 1))
             (lvl (my/org--indent-level-at beg))
             (face (my/org--bullet-face-for-level lvl)))
        (add-text-properties beg end `(face ,face))
        (setq found t)))
    found))
(defun my/org-bullets-enable ()
  "Enable colored bold bullets for org lists in this buffer."
  (font-lock-add-keywords
   nil
   '((my/org--fontify-list-bullets 0 nil))
   'append)
  (when (fboundp 'font-lock-flush) (font-lock-flush))
  (when (fboundp 'font-lock-ensure) (font-lock-ensure)))
  (add-hook 'org-mode-hook #'my/org-bullets-enable)
(use-package org-superstar
  :defer t
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("●" "○" "◆" "◇" "►" "▸")
           org-superstar-item-bullet-alist
           '((?* . ?•) (?+ . ?◦) (?- . ?▪ ))))
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
(use-package ox-hugo
  :after ox)
(use-package cdlatex
  :ensure t
  :hook (org-mode . turn-on-org-cdlatex))
(use-package auctex
  :ensure t)
(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  ;; 这一行必须为 t，否则 org-appear 不会工作
  (setq org-hide-emphasis-markers t)
  
  ;; 以下设置为可选，开启更多自动展开功能
  (setq org-appear-autoentities t)  ; 光标进入时展开 HTML 实体，如 \alpha
  (setq org-appear-autolinks t)     ; 光标进入链接描述时，展开显示完整的 URL
  (setq org-appear-autosubmarkers t)) ; 展开下标/上标标记，如 text_{sub}
(use-package org-fragtog
  :ensure t
  :hook (org-mode . org-fragtog-mode))
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
          ("SPC n c" . org-cliplink)
          ("SPC n n" . denote)
          ("SPC n d" . denote-sort-dired)
          ("SPC n f" . org-footnote-new)
          ("SPC n i" . org-insert-link)
          ("SPC n l" . denote-link)
          ("SPC n L" . denote-add-links)
          ("SPC n b" . denote-backlinks)
          ("SPC n o" . denote-open-or-create)
          ("SPC n p" . org-download-clipboard)
          ("SPC n q" . org-set-tags-command)
          ("SPC n r" . denote-rename-file)
          ("SPC n R" . denote-rename-file-using-front-matter)
          ("SPC n t" . org-todo)))
  (with-eval-after-load 'evil
    (dolist (pair my/evil-org-binding)
      (evil-define-key 'normal org-mode-map (kbd (car pair)) (cdr pair)))))

(setq org-startup-numerated t)          ; 设置 org 目录编号
;; (setq org-tempo-keywords-alist ; org 模板，其他语言
;;       (append org-tempo-keywords-alist
;;               '(("el" . "src emacs-lisp")
;;                 ("sh" . "src bash")
;;                 ("py" . "src python :results output")
;;                 ("fi" . "src fish")
;;                 ("js" . "src javascript")
;;                 ("cc" . "src c")
;;                 ("cp" . "src cpp")
;;                 ("plm" . "src plantuml\n@startmindmap")
;;                 ("pw" . "src powershell"))))
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

;; 用于 Windows 的 Latex
(setq temporary-file-directory "C:/Users/pilrymage/AppData/Local/Temp/")
(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
(setq org-preview-latex-default-process 'imagemagick)
(with-eval-after-load 'org
  ;; 1. 先将默认的 dvisvgm 配置从列表中完全删除
  (setq org-preview-latex-process-alist
        (assq-delete-all 'dvisvgm org-preview-latex-process-alist))
  
  ;; 2. 重新加入一个干净的、专为 xelatex 定制的 dvisvgm 节点
  (add-to-list 'org-preview-latex-process-alist
               '(imagemagick
                  :programs ("xelatex" "magick" "gswin64c")
                  :description "pdf > png"
                  :message
                  "you need to install the programs: xelatex and imagemagick."
                  :image-input-type "pdf" :image-output-type "png"
                  :image-size-adjust (1.0 . 1.0) :latex-compiler
                  ("xelatex -interaction nonstopmode -output-directory %o %f")
                  :image-converter
                  ("magick -density %D %f -trim -antialias -quality 100 %O"))))

(modify-syntax-entry ?> "w" org-mode-syntax-table)
(modify-syntax-entry ?> "w" org-mode-syntax-table)

(provide 'init-org)
;; Babel

(provide 'lang-org)

;;; lang/org.el ends here
