;; 移动 custom file 到 .emacs.custom.el
(setq custom-file "~/.emacs.d/.emacs.custom.el")

;; 添加.emacs.d/lisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/3rdparty/qml-ts-mode"))

(require 'init-elpa)
(require 'init-theme)
(require 'init-basic)
(require 'init-org)
(require 'init-c-mode)
(require 'init-cc-mode)
(require 'init-lua-mode)
(require 'init-qml-mode)
(require 'init-keybinds)
(require 'init-dashboard)
(require 'init-tab)
(require 'init-rime)
(require 'init-dired)
(require 'init-ivy)
(require 'note)

;; (require 'gdscript-mode)
;; (add-hook 'gdscript-mode-hook #'lsp-mode)

;; dired
(add-hook 'dired-mode-hook (lambda () (dired-omit-mode)))

;; (use-package gptel
;;     :ensure t
;;     :config
;;     (setq gptel-model "moonshot-v1-8k")
;;     (setq gptel-use-curl nil)          ;; 我觉得这一句是关键，供你参考
;;     (setq gptel-default-mode 'org-mode)
;;     (setq gptel-backend
;;           (gptel-make-openai "Moonshot"
;;             :key 'gptel-api-key
;;             :models '("moonshot-v1-8k"
;;                       "moonshot-v1-32k"
;;                       "moonshot-v1-128k")
;;             :host "api.moonshot.cn")))

;; tramp
(setq remote-file-name-inhibit-locks t
      tramp-use-scp-direct-remote-copying t
      remote-file-name-inhibit-auto-save-visited t)

(setq tramp-copy-size-limit (* 1024 1024) ;; 1MB
      tramp-verbose 2)

(connection-local-set-profile-variables
 'remote-direct-async-process
 '((tramp-direct-async-process . t)))

(connection-local-set-profiles
 '(:application tramp :protocol "scp")
 'remote-direct-async-process)

;; (setq magit-tramp-pipe-stty-settings 'pty)

(set-frame-parameter nil 'alpha-background 100)

(add-to-list 'default-frame-alist '(alpha-background . 100))

;; 设置垃圾回收大小为64mb
(setq gc-cons-threshold (* 32 1024 1024)
      gc-cons-percentage 0.5
      read-process-output-max (* 8 1024 1024)
      treemacs-space-between-root-nodes nil)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(load-file custom-file)
