
;; (beacon-mode 1)                         ; 光标跳动，如有神力，let there be light
;; 可惜现有更帅的光标了，不再考虑

;; (defun my/open-agenda-inbox-capture ()
;;   "打开inbox.org并且插入一个新的headline"
;;   (interactive)
;;   (find-file my/org-agenda-inbox)
;;   (goto-char (point-max))
;;   (evil-append 1)

;; (setq indent-line-function 'insert-tab)
;;   (yas-expand-snippet (yas-lookup-snippet "new_headline")))



(setq org-agenda-hide-tags-regexp ".*") ; agenda隐藏tag

(setq org-agenda-prefix-format
      '((agenda . " %i %?-12t% s")
        (todo . " %i ")
        (tags . " %i ")
        (search . " %i ")))

(after! evil (setq evil-shift-width 2)) ; 设置evil的缩进宽度
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

(set-evil-initial-state! 'vterm-mode 'emacs) ; vterm 下使用 emacs 模式
(set-evil-initial-state! 'dired-mode 'emacs) ;dired 下使用 emacs 模式
;; (set-evil-initial-state! 'elfeed-search-mode 'emacs) ;elfeed 下使用 emacs 模式
;; (setq elfeed-org t)

(map! :after org                        ; roam 的补全
      :map evil-normal-state-map
      :prefix "SPC i"
      :desc "Set input method"
      "i" #'set-input-method)

(use-package! rime
  :bind (:map rime-mode-map
              ("C-`" . 'rime-send-keybinding)
              ("`" . 'rime-inline-ascii))
  :custom (default-input-method "rime")
  (rime-librime-root "~/.emacs.d/librime/dist")
  :config
  (global-set-key (kbd "`") 'rime-inline-ascii) ; 用于切换中英文
  (setq         ;; rime-show-candidate 'posframe ;; 用形码就不需要候选框
   rime-inline-ascii-holder ?x
   rime-user-data-dir "~/.emacs.d/Rime")) ;

(after! magit
  ;; 检视一些仓库
  (setq magit-repository-directories '(("~/org/blog" . 0)
                                       ("~/.doom.d/" . 0))))

(setq org-startup-numerated t)          ; 设置org目录编号
(use-package! grip-mode  ; 用于在网页端实时预览 markdown、org
  :ensure t
  :config (setq grip-preview-use-webkit t))
(use-package! ox-gfm)  ; 预览上色
(use-package! paredit :hook ((scheme-mode racket-mode) . paredit-mode))
(use-package! evil-paredit :hook ((paredit-mode) . evil-paredit-mode))
(require 'org-tempo) ; org模板，<s 补全
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

(after! org
  (setq org-latex-default-packages-alist
        (append org-latex-default-packages-alist
                '(("" "multirow" t)("" "ctex" t)))
        org-latex-compiler "xelatex"    ; 设置latex编译器，xelatex支持中文
        org-format-latex-options (plist-put org-format-latex-options :scale 2))
  (setq org-babel-python-command "/usr/local/Caskroom/miniforge/base/bin/python") ; org python 解释器的路径
  (after! cdlatex                         ; cdlatex 快速插入
    (setq cdlatex-math-symbol-alist
          '((?c ("\\mathcal\{\}" nil nil nil))
            (?v ("\\vee" "\\downarrow" nil nil))
            (?< ("\\leftarrow" "\\langle" nil nil))
            (?> ("\\rightarrow" "\\rangle" nil nil))
            (?+ ("\\cup" "\\dag" nil nil))
            (?o ("\\omega" "\\circ" nil nil)))))
  ;; Define a custom face for Org-mode quote blocks with a yellow font color.
  (defface my-org-quote-yellow-face
    '((t (:foreground "yellow")))  ;; Set the font color to yellow
    "Custom face for Org-mode quote blocks.")

  ;; Apply the custom face to the org-quote face.
  (defun my-custom-org-quote-color ()
    (set-face-attribute 'org-quote nil :inherit 'my-org-quote-yellow-face))

  ;; Add a hook to ensure the custom face is applied in Org-mode.
  (add-hook 'org-mode-hook #'my-custom-org-quote-color))

(map! :after org                        ; roam 的补全
      :map evil-normal-state-map
      :prefix "SPC n r"
      :desc "Add completion"
      "m" #'completion-at-point)

(map! :after org                        ; 打开 roam ui
      :map evil-normal-state-map
      :prefix "SPC n r"
      :desc "Go to map"
      "G" #'org-roam-ui-open)

(use-package! websocket :after org-roam) ; websocket 用于 roam ui
(defun nom/org-roam-capture-create-id ()
  "Create id for captured note and add it to org-roam-capture-template."
  (when (and (not org-note-abort)
             (org-roam-capture-p))
    (org-roam-capture--put :id (org-id-get-create))))
(add-hook 'org-capture-prepare-finalize-hook 'nom/org-roam-capture-create-id)
(setq org-roam-capture-templates
      '(("d" "default" entry "\n* %?"
         :target (file+head
                  "${slug}.org" ;; 这里设置了存放路径 notes/ 并且删除了默认的 %<%Y%m%d%H%M%S>
		  "#+TITLE: ${title}\n\n")
         :empty-lines 1
         :immediate-finish t
         :kill-buffer t)))
(use-package! emacsql)
(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

(after! org
  (setq org-agenda-files '("~/org/agenda")) ; 设置agenda文件夹
  (setq org-agenda-start-day "0d")          ; 设置agenda开始时间
  (setq org-todo-repeat-to-state t)         ; 可重复任务的状态
  (setq org-agenda-custom-commands
        '(("i" "GTD任务"
           ((agenda ""
                    ((org-agenda-overriding-header "定期任务安排")
                     (org-agenda-span '3)))
            (tags-todo "@inbox"
                       ((org-agenda-overriding-header "收件箱")))
            (tags-todo "@next-@read+TODO=\"TODO\"|@next-@read+TODO=\"STRT\""
                       ((org-agenda-overriding-header "采取行动")))
            (tags-todo "@project"
                       ((org-agenda-overriding-header "项目")))
            (tags-todo "@next+@read+TODO=\"TODO\""
                       ((org-agenda-overriding-header "阅读列表")))
            (tags-todo "@waiting"
                       ((org-agenda-overriding-header "等待中")
                        (org-agenda-sorting-strategy
                         '(time-up)))))
           nil)
          ("x" "搁置任务"
           ((tags-todo "@stucked|@someday"
                       ((org-agenda-overriding-header "搁置任务（someday, tickler, reference）"))))
           nil nil)))

  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo   . " %i %-12:c")
          (tags   . " %i %-12:c")
          (search . " %i %-12:c"))))


(map! :after org :map evil-normal-state-map
      :prefix "SPC"
      :desc "open GTD"
      "d" (lambda () (interactive) (org-agenda nil "i") ))

;; (setq org-refile-targets '((org-agenda-files :maxlevel . 3))) ; 设置refile目标
;; (setq org-refile-use-outline-path 'file)
;; (setq org-outline-path-complete-in-steps nil)

;; (defun org-summary-todo (n-done n-not-done)
;;   "DEPRECATED"
;;   (let (org-log-done org-log-states)   ; turn off logging
;;     (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

;; (defun org-summary-todo-after-state-change ()
;;   "DEPRECATED Switch headline to DONE when all subentries are DONE, to TODO otherwise."
;;   (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
;;          (parent-end (save-excursion (org-up-heading-safe) (point)))
;;          (n-done 0)
;;          (n-not-done 0))
;;     (save-excursion
;;       (org-back-to-heading t)
;;       (org-show-subtree)
;;       (while (and (< (point) subtree-end)
;;                   (re-search-forward org-heading-regexp subtree-end t))
;;         (let ((state (org-get-todo-state)))
;;           (if (string= state "DONE")
;;               (setq n-done (1+ n-done))
;;             (setq n-not-done (1+ n-not-done)))))
;;     (when (= n-not-done 0)
;;       (save-excursion
;;         (goto-char parent-end)
;;         (org-todo "DONE"))))))

;; (add-hook 'org-after-todo-statistics-hook #'org-summary-todo)
;; (add-hook 'org-after-todo-state-change-hook #'org-summary-todo-after-state-change)

;; (defun org-turn-subentries-to-todo (headline-point)
;;     (save-excursion
;;         (org-map-entries (lambda () (org-todo "TODO")) "/+DONE" 'tree)))

;; (defun org-toggle-subentries-to-todo ()
;;   "Toggle all subentries under a headline to TODO state."
;;   (interactive)
;;   (let ((headline-point (org-get-at-bol 'org-hd-marker)))
;;     (org-turn-subentries-to-todo headline-point)))

;; (map! :after org :map evil-normal-state-map
;;       :prefix "SPC m"
;;       :desc "Toggle subentries to TODO"
;;       "X" #'org-toggle-subentries-to-todo)


;; (setq org-hierarchical-todo-statistics t)

(setq reftex-default-bibliography '("~/org/references.bib"))
(setq reftex-bibliography-commands '("bibliography" "nobibliography" "addbibresource"))

(use-package! org-ref
  :config
  (setq bibtex-completion-bibliography '("~/org/references.bib") ; bibtex 引用
        citar-bibliography '("~/org/references.bib")  ; citar 的 bibtex 引用
	;; bibtex-completion-library-path '("~/Dropbox/emacs/bibliography/bibtex-pdfs/")
	;; bibtex-completion-notes-path "~/Dropbox/emacs/bibliography/notes/"
	;; citar-library-path '("~/Dropbox/emacs/bibliography/bibtex-pdfs/")
	;; citar-notes-path "~/Dropbox/emacs/bibliography/notes/"
	;; bibtex-completion-notes-template-multiple-files "* ${author-or-editor}, ${title}, ${journal}, (${year}) :${=type=}: \n\nSee [[cite:&${=key=}]]\n"

	bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath))))

(use-package! org-roam-bibtex           ; org roam 的 bibtex，抄的配置
  :after (org-roam citar-org-rom)
  :config
  (require 'citar-org-roam)
  (citar-register-notes-source
   'orb-citar-source (list :name "Org-Roam Notes"
                           :category 'org-roam-node
                           :items #'citar-org-roam--get-candidates
                           :hasitems #'citar-org-roam-has-notes
                           :open #'citar-org-roam-open-note
                           :create #'orb-citar-edit-note
                           :annotate #'citar-org-roam--annotate))
  (setq citar-notes-source 'orb-citar-source))

(use-package! citar-org-roam            ; citar 的 org roam
  :after (citar org-roam)
  :config (citar-org-roam-mode))

(map! :after org :map evil-normal-state-map ; 添加引用的快捷键
      :prefix "SPC n e"
      :desc "Insert citation"
      "b" #'citar-insert-citation
      :desc "Open notes"
      "o" #'citar-open-files
      :desc "Insert reference"
      "p" #'org-noter
      :desc "启动org-note"
      "r" #'citar-insert-reference
      :desc "Insert node citation"
      "i" #'orb-insert-link)

(after! org-noter
  (add-hook 'pdf-view-mode-hook 'pdf-view-fit-width-to-window)
  (setq doc-view-continuous t)
  (setq org-noter-notes-search-path '("/Users/pilrymage/Zotero/storage/org-noter"))
  (setq org-noter-auto-save-last-location t)
  (setq org-noter-max-short-selected-text-length 20)
  (setq org-noter-default-heading-title "第 $p$ 页的笔记"))

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
(setq org-journal-file-type 'yearly)    ; 设置日记文件类型，每年一个文件
(setq org-journal-file-format (concat "%Y-" chinese-year-now)) ; 把年份加入文件名
(setq org-journal-date-format "%Y/%m/%d W%W D%j（%a）")
(format-time-string "%Y/%m/%d W%W D%j (%a)")

(setq yas-snippet-dirs (append yas-snippet-dirs '("~/.doom.d/snippets")))

(setq org-contacts-files '("~/org/contacts.org")) ; 设置联系人文件

;; (map! :after org :map evil-normal-state-map
;;       :prefix "SPC n e"
;;       :desc "open elfeed"               ; 进入博客文件编辑
;;       "h" (lambda () (interactive) (find-file "~/org/blog/content-org/all-posts.org")))

(defun my-random-file-from-directory (directory) ; by GPT
  "Return a random file path from DIRECTORY."
  (let ((files (directory-files directory t)))
    (when files
      (let ((random-file (nth (random (length files)) files)))
        (when (file-regular-p random-file)
          random-file)))))
(use-package! dashboard                 ; 启动界面
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startupify-list '(dashboard-insert-banner)) ; 无内鬼，来点笑话
  (setq dashboard-center-content nil)
  (setq dashboard-startup-banner (my-random-file-from-directory "~/org/emacs-meme")))

(setq company-minimum-prefix-length 6)  ; company 补全最小长度

;; doom 就是很难设字体，想定制 Emacs 了
;; (setq doom-font (font-spec :family "IosevkaTerm Nerd Font Mono" :size 16)
;;       doom-serif-font doom-font
;;       doom-symbol-font (font-spec :family "LXGW WenKai" :size 16)
;;       doom-variable-pitch-font (font-spec :family "LXGW WenKai" :size 16))
;; (setq use-default-font-for-symbols t)
;; (setq doom-font (font-spec :family "Iosevka" :size 18 ))
(defun init-cjk-fonts()
  (dolist (charset '(kana han cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset (font-spec :family "LXGW WenKai" :size 18))))
(add-hook 'doom-init-ui-hook 'init-cjk-fonts)
;; ;; Doom 的字体加载顺序问题, 如果不设定这个 hook, 配置会被覆盖失效
;; (add-hook! 'after-setting-font-hook
;;   (set-fontset-font t 'latin (font-spec :family "IosevkaTerm Nerd Font Mono"))
;;   (set-fontset-font t 'symbol (font-spec :family "Apple Symbols"))
;;   (set-fontset-font t 'mathematical (font-spec :family "Apple Symbols"))
;;   (set-fontset-font t 'emoji (font-spec :family "Apple Symbols")))

;; 这个是手动看字体如何，手动可以调出粗体但是感觉这个来日用还是太粗了
(set-fontset-font t 'latin (font-spec :family "Iosevka"))
(set-fontset-font t 'han (font-spec :family "LXGW WennKai" :weight 'bold))
;; 虽然己经等宽了，但是感觉还是用cnfonts 熟悉
(use-package! cnfonts
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
  (global-set-key (kbd "s--") 'cnfonts-decrease-fontsize)
  (global-set-key (kbd "s-=") 'cnfonts-increase-fontsize)
  (setq cnfonts-personal-fontnames
        '(;;英文字体
          ("Liga SFMono Nerd font" "SF Pro Text" "IosevkaTerm Nerd Font Mono"
           "Iosevka Term")
          ;; 中文字体
          ("PingFang SC"
           "Source Han Serif SC"
           "LXGW Wenkai")))
  (cnfonts-enable))
(cnfonts-mode 1)

(use-package! sage-shell-mode)          ; sage shell
(use-package! ob-sagemath
  :config
  (setq org-babel-default-header-args:sage '((:session . t)
                                             (:results . "output"))
        sage-shell::sage-root "/usr/local/bin/sage"
        org-confirm-babel-evaluate nil
        org-export-babel-evaluate nil
        org-startup-with-inline-images t))

(use-package! ob-powershell
  :config
  (add-to-list 'load-path "~/.emacs.d/lisp/ob-powershell"))

                                        ; 人工智能为写作赋能
(use-package! copilot
  ;; :hook (org-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

(use-package! lilypond-mode)
(after! lilypond-mode
  (add-to-list 'auto-mode-alist '("\\.ly" . LilyPond-mode)))

(setq auth-sources '("~/.authinfo"))

;; (use-package! wolfram-mode)
;; (use-package! matlab-mode)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((erlang . t)
   (emacs-lisp . t)
   (plantuml . t)
   (jupyter . t)))

(use-package! telega
  :commands (telega)
  :defer t
  :hook
  ('telega-root-mode . #'evil-emacs-state)
  ('telega-chat-mode . #'evil-emacs-state)
  :config
  ;; (telega-mode-line-mode 1)
  (setq telega-use-svg-base-uri nil)
  (setq telega-avatar-workaround-gaps-for '(return t))
  (setq telega-proxies
        (list
         '(:server "localhost" :port 7890 :enable t :type (:@type "proxyTypeHttp")))))
(map! :leader
      "t e" telega-prefix-map)

(defcustom emacs-daily-start-count 0
  "Count of times Emacs has been started today."
  :type 'integer
  :group 'personal)

(defcustom last-emacs-start-date ""
  "Date of the last Emacs start."
  :type 'string
  :group 'personal)

(add-hook 'emacs-startup-hook 'update-emacs-start-count)
(defvar my/start-time nil)
(defvar my/end-time nil)
(save-mark-and-excursion (find-file "~/Documents/Sn5Pb95.txt"))
(defun my/start-time-hook ()
  (setq my/start-time (current-time)))
(defun pomodoro-to-excel (&rest e)
  (let ((python-script "/Users/pilrymage/Script/emacs-excel-pomodoro.py"))
    (apply #'start-process
           (append `("pomodoro-to-excel"
                     "*pomodoro-to-excel*"
                     "python3"
                     ,python-script)
                   e))))
(defun output-excel-hook ()
  (setq my/end-time (current-time))
  (let* ((start-time my/start-time)
         (end-time my/end-time)
         (headline (prog2 (progn (push-mark (point))
                                 (org-clock-goto))
                       (nth 4 (org-heading-components))
                     (pop-global-mark)))
         (work-state "工作"))
    ;; 调用 Python 脚本 在 Emacs 里 clock in 的headline 任务，如何
    (pomodoro-to-excel (format "%s" headline)
                       (format-time-string "%Y/%m/%d %H:%M:%S" start-time)
                       (format-time-string "%Y/%m/%d %H:%M:%S" end-time)
                       (format "%s" work-state))))
(defun rest-excel-hook ()
  (let* ((start-time my/end-time)
         (end-time (current-time))
         (headline (prog2 (progn (push-mark (point))
                                 (org-clock-goto))
                       (nth 4 (org-heading-components))
                     (pop-global-mark)))
         (work-state "休息"))
    ;; 调用 Python 脚本
    (pomodoro-to-excel (format "%s" headline)
                       (format-time-string "%Y/%m/%d %H:%M:%S" start-time)
                       (format-time-string "%Y/%m/%d %H:%M:%S" end-time)
                       (format "%s" work-state))))
(add-hook 'org-pomodoro-started-hook 'my/start-time-hook)
(add-hook 'org-pomodoro-finished-hook 'output-excel-hook)
(add-hook 'org-pomodoro-killed-hook 'output-excel-hook)
(add-hook 'org-pomodoro-break-finished-hook 'rest-excel-hook)
                                        ; (my/org-pomodoro)
                                        ; (setq org-pomodoro-length 1)
(defun my/org-pomodoro-custom ()
  (interactive)
  (setq org-pomodoro-length 90)
  (org-pomodoro)
  (setq org-pomodoro-length 25))

(map! :after org :map evil-normal-state-map
      :prefix "SPC t"
      :desc "custom clock"
      "T" #'my/org-pomodoro-custom)
(setq custom-file "~/.doom.d/custom.el")
(load custom-file)
(defun update-emacs-start-count ()
  "Update the count of Emacs starts for the day."
  (let ((today (format-time-string "%Y-%m-%d")))
    (if (string= last-emacs-start-date today)
        (setq emacs-daily-start-count (1+ emacs-daily-start-count))
      (setq emacs-daily-start-count 1)
      (setq last-emacs-start-date today)))
  ;; Save the updated values to disk
  (customize-save-variable 'emacs-daily-start-count emacs-daily-start-count)
  (customize-save-variable 'last-emacs-start-date last-emacs-start-date))

(defun my/notify-osx (title message)
  "Display a macOS notification."
  (let ((script (format "display notification \"%s\" with title \"%s\""
                        (replace-regexp-in-string "\"" "\\\\\"" message)
                        (replace-regexp-in-string "\"" "\\\\\"" title))))
    (do-applescript script)))


(add-hook 'org-pomodoro-started-hook
          (lambda () (shell-command "shortcuts run 'Turn Focus On'")))

(add-hook 'org-pomodoro-finished-hook
          (lambda ()
            (progn
              (my/notify-osx
               "工作时间到！"
               (concat "你完成了第" (number-to-string org-pomodoro-count) "个番茄钟🍅 "))
              (shell-command "shortcuts run 'Turn Focus Off'"))))
(add-hook 'org-pomodoro-short-break-finished-hook
          (lambda () (my/notify-osx "休息时间到！" "继续努力吧")))
(add-hook 'org-pomodoro-long-break-finished-hook
          (lambda () (my/notify-osx "休息时间到！" "继续努力吧")))

(defun add-space-between-chinese-and-english ()
  "在中英文之间自动添加空格。"
  (let ((current-char (char-before))
        (prev-char (char-before (1- (point)))))
    (when (and current-char prev-char
               (or (and (is-chinese-character prev-char) (is-halfwidth-character current-char))
                   (and (is-halfwidth-character prev-char) (is-chinese-character current-char)))
               (not (eq prev-char ?\s))) ; 检查前一个字符不是空格
      (save-excursion
        (goto-char (1- (point)))
        (insert " ")))))

(defun is-chinese-character (char)
  "判断字符是否为中文字符。"
  (and char (or (and (>= char #x4e00) (<= char #x9fff))
                (and (>= char #x3400) (<= char #x4dbf))
                (and (>= char #x20000) (<= char #x2a6df))
                (and (>= char #x2a700) (<= char #x2b73f))
                (and (>= char #x2b740) (<= char #x2b81f))
                (and (>= char #x2b820) (<= char #x2ceaf)))))

(defun is-halfwidth-character (char)
  "判断字符是否为半角字符，包括英文字母、数字和标点符号。"
  (and char (or (and (>= char ?a) (<= char ?z))
                (and (>= char ?A) (<= char ?Z))
                (and (>= char ?0) (<= char ?9))
                )))

(defun delayed-add-space-between-chinese-and-english ()
  "延迟执行，在中英文之间自动添加空格。"
  (run-with-idle-timer 0 nil 'add-space-between-chinese-and-english))

(define-minor-mode auto-space-mode
  "在中英文之间自动添加空格的模式。"
  :lighter " Auto-Space"
  :global t
  (if auto-space-mode
      (add-hook 'post-self-insert-hook 'add-space-between-chinese-and-english)
    (remove-hook 'post-self-insert-hook 'add-space-between-chinese-and-english)))
(auto-space-mode t)

;; (use-package! emt
;;   :hook (after-init . emt-mode))

(use-package! j-mode)

(setq plantuml-jar-path "/usr/local/bin/plantuml")
(setq org-plantuml-jar-path "/usr/local/bin/plantuml")
(setq plantuml-default-exec-mode 'executable)

(use-package! anki-editor)
(map! :after org :map evil-normal-state-map ; 设置快捷键
      :prefix "SPC n k"
      :desc "Anki editor operation"
      "p" #'anki-editor-push-notes
      "k" #'anki-editor-insert-note
      "c" #'anki-editor-cloze-dwim
      )
(map! :after org :map evil-visual-state-map ; 设置快捷键
      :prefix "SPC n k"
      :desc "Anki editor operation"
      "c" #'anki-editor-cloze-dwim)

(defvar sticky-buffer-previous-header-line-format)
(define-minor-mode sticky-buffer-mode
  "Make the current window always display this buffer."
  nil " sticky" nil
  (if sticky-buffer-mode
      (progn
        (set (make-local-variable 'sticky-buffer-previous-header-line-format)
             header-line-format)
        (set-window-dedicated-p (selected-window) sticky-buffer-mode))
    (set-window-dedicated-p (selected-window) sticky-buffer-mode)
    (setq header-line-format sticky-buffer-previous-header-line-format)))
(my/notify-osx "Emacs，启动！"
               (concat "你今天启动了 " (number-to-string emacs-daily-start-count) " 次 Emacs"))
