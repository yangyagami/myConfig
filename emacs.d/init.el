;; 添加.emacs.d/lisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

(require 'init-elpa)
(require 'init-theme)
(require 'init-basic)
(require 'init-org)
(require 'init-c-mode)
(require 'init-cc-mode)
(require 'init-lua-mode)
(require 'init-keybinds)
(require 'init-dashboard)
(require 'init-tab)
;; (require 'init-ivy)

;; 关闭启动页
(setq inhibit-startup-screen t)

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4))) ; 设置缩进为4个空格，你可以根据需要调整数字

;; 设置垃圾回收大小为16mb
(setq gc-cons-threshold (* 32 1024 1024)
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
   '("88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e"
     "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2"
     "691d671429fa6c6d73098fc6ff05d4a14a323ea0a18787daeb93fde0e48ab18b"
     "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8"
     "6f96a9ece5fdd0d3e04daea6aa63e13be26b48717820aa7b5889c602764cf23a"
     "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69"
     "7964b513f8a2bb14803e717e0ac0123f100fb92160dcf4a467f530868ebaae3e"
     "d6b934330450d9de1112cbb7617eaf929244d192c4ffb1b9e6b63ad574784aad"
     default))
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
 '(org-agenda-files nil)
 '(package-selected-packages
   '(ace-window all-the-icons-dired all-the-icons-gnus
		all-the-icons-nerd-fonts cmake-mode company counsel
		dashboard docker doom-modeline doom-themes
		fancy-compilation flycheck google-c-style ivy lsp-mode
		lsp-ui magit magit-svn melpa-upstream-visit qml-mode
		rainbow-delimiters swiper treesit-auto vterm which-key))
 '(package-vc-selected-packages
   '((lua-ts-mode :vc-backend Git :url
		  "https://git.sr.ht/~johnmuhl/lua-ts-mode")))
 '(vterm-shell "/bin/fish")
 '(vterm-tramp-shells '(("docker" "/bin/bash"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "RobotoMono Nerd Font" :foundry "pyrs" :slant normal :weight medium :height 128 :width normal))))
 '(ansi-color-bright-black ((t (:background "#dfdfdf" :foreground "dim gray"))))
 '(fancy-compilation-default-face ((t (:inherit ansi-color-white :background "gray9"))))
 '(term-color-black ((t (:background "#f1f1f1" :foreground "dim gray"))))
 '(vterm-color-black ((t (:background "#f4f4f4" :foreground "red")))))
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
