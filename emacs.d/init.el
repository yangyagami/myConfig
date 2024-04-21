;; 添加.emacs.d/lisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

(require 'init-elpa)
(require 'init-theme)
(require 'init-basic)
(require 'init-org)
(require 'init-c-mode)
(require 'init-cc-mode)
(require 'init-keybinds)
(require 'init-dashboard)
(require 'init-tab)
;; lsp
;; (require 'lsp-mode)
;; (add-hook 'c++-mode-hook #'lsp)

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4))) ; 设置缩进为4个空格，你可以根据需要调整数字


;; 设置垃圾回收大小为100mb
(setq gc-cons-threshold (* 512 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-idle-delay 0.1)  ;; clangd is fast

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   '("6f96a9ece5fdd0d3e04daea6aa63e13be26b48717820aa7b5889c602764cf23a" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" "7964b513f8a2bb14803e717e0ac0123f100fb92160dcf4a467f530868ebaae3e" "d6b934330450d9de1112cbb7617eaf929244d192c4ffb1b9e6b63ad574784aad" default))
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
 '(org-agenda-files nil)
 '(package-selected-packages
   '(dashboard ace-window which-key flycheck lsp-ui company lsp-mode qml-mode fancy-compilation all-the-icons-gnus all-the-icons-nerd-fonts all-the-icons-dired melpa-upstream-visit magit doom-modeline doom-themes)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "RobotoMono Nerd Font" :foundry "pyrs" :slant normal :weight medium :height 128 :width normal))))
 '(fancy-compilation-default-face ((t (:inherit ansi-color-white :background "white smoke")))))
(put 'upcase-region 'disabled nil)
