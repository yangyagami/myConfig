;; doom themes
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-dark") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; doom modeline
;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1))

;; icons
;; (use-package all-the-icons
;;   :if (display-graphic-p))
;; (add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

;; 设置modeline高度
(setq doom-modeline-height 35)

;; Whether display the minor modes in the mode-line.
(setq doom-modeline-minor-modes t)

(provide 'init-theme)
