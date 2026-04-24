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

(use-package elfeed-org
  :defer t
  :init (elfeed-org))

(provide 'apps)

;;; modules/apps.el ends here


