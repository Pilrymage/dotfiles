;;; modules/apps.el --- Productivity apps -*- lexical-binding: t; -*-

(use-package elfeed
  :defer t
  :config
  (setq elfeed-curl-extra-arguments '("-xhttp://localhost:7897"))
  (setf url-queue-timeout 30
        elfeed-set-max-connections 1)
  (with-eval-after-load 'evil
    (evil-set-initial-state 'elfeed-search-mode 'emacs)
    (evil-set-initial-state 'elfeed-show-mode 'emacs)))

;; (use-package elfeed-org
;;   :defer t
;;   :init (elfeed-org))
;; (use-package elfeed-protocol
;;   :ensure t
;;   :config
;;   (setq elfeed-use-curl t)
;;   (elfeed-set-timeout 36000)
;;   (setq elfeed-curl-extra-arguments '("--insecure")) ;necessary for https without a trust certificate

;;   ;; setup feeds
;;   (setq elfeed-protocol-fever-update-unread-only nil)
;;   (setq elfeed-protocol-fever-fetch-category-as-tag t)
;;   (setq elfeed-protocol-feeds '(("fever+http://admin@127.0.0.1"
;;                                  :api-url "http://127.0.0.1/fever"
;;                                 :password "123456")))

;;   ;; enable elfeed-protocol
;;   (setq elfeed-protocol-enabled-protocols '(fever))
;;   )

(provide 'apps)

;;; modules/apps.el ends here


