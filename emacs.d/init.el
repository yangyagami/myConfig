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
(require 'init-rime)
;; (require 'init-ivy)

(set-frame-parameter nil 'alpha-background 80)

(add-to-list 'default-frame-alist '(alpha-background . 80))

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4))) ; 设置缩进为4个空格，你可以根据需要调整数字

;; 设置垃圾回收大小为64mb
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.5
      read-process-output-max (* 8 1024 1024)
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
   '("dccf4a8f1aaf5f24d2ab63af1aa75fd9d535c83377f8e26380162e888be0c6a9" "7e377879cbd60c66b88e51fad480b3ab18d60847f31c435f15f5df18bdb18184" "b754d3a03c34cfba9ad7991380d26984ebd0761925773530e24d8dd8b6894738" "9f297216c88ca3f47e5f10f8bd884ab24ac5bc9d884f0f23589b0a46a608fe14" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" "6f96a9ece5fdd0d3e04daea6aa63e13be26b48717820aa7b5889c602764cf23a" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" "7964b513f8a2bb14803e717e0ac0123f100fb92160dcf4a467f530868ebaae3e" "d6b934330450d9de1112cbb7617eaf929244d192c4ffb1b9e6b63ad574784aad" default))
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
 '(org-agenda-files nil)
 '(package-selected-packages
   '(winum rime docker lua-mode counsel swiper ivy lsp-ui lsp-mode vterm cmake-mode rainbow-delimiters magit-svn google-c-style dashboard which-key flycheck company qml-mode fancy-compilation all-the-icons-gnus all-the-icons-nerd-fonts all-the-icons-dired melpa-upstream-visit magit doom-modeline doom-themes))
 '(vterm-tramp-shells '(("docker" "/bin/bash"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "RobotoMono Nerd Font" :foundry "pyrs" :slant normal :weight medium :height 128 :width normal))))
 '(fancy-compilation-default-face ((t (:inherit ansi-color-white :background "gray6")))))
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
