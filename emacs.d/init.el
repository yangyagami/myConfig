;; 初始化melpa
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; doom themes
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; icons
(use-package all-the-icons
  :if (display-graphic-p))
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

;; 在底部打开term
(defun bterm ()
  (interactive)
  (let ((buf (generate-new-buffer "*bterm*")))
    (split-window-below 30)
    (other-window 1)
    (switch-to-buffer buf)
    (term-mode)
    (term buf)))

;; modeline显示时间
(setq display-time-format "%Y-%m-%d %H:%M:%S")
(display-time-mode 1)

;; 显示行号
(global-display-line-numbers-mode)

;; 显示列数
(column-number-mode 1)

;; C语言下的设置
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-basic-offset 8)
            (setq display-fill-column-indicator-column 81)
            (display-fill-column-indicator-mode 1)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
 '(package-selected-packages
   '(fancy-compilation all-the-icons-gnus all-the-icons-nerd-fonts all-the-icons-dired melpa-upstream-visit magit doom-modeline doom-themes)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "RobotoMono Nerd Font" :foundry "pyrs" :slant normal :weight medium :height 128 :width normal)))))
(put 'upcase-region 'disabled nil)
