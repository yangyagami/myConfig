;; 移动 custom file 到 .emacs.custom.el
(setq custom-file "~/.emacs.d/.emacs.custom.el")

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

(require 'gdscript-mode)
(add-hook 'gdscript-mode-hook #'lsp-mode)

;; dired
(add-hook 'dired-mode-hook (lambda () (dired-omit-mode)))

(use-package gptel
    :ensure t
    :config
    (setq gptel-model "moonshot-v1-8k")
    (setq gptel-use-curl nil)          ;; 我觉得这一句是关键，供你参考
    (setq gptel-default-mode 'org-mode)
    (setq gptel-backend
          (gptel-make-openai "Moonshot"
            :key 'gptel-api-key
            :models '("moonshot-v1-8k"
                      "moonshot-v1-32k"
                      "moonshot-v1-128k")
            :host "api.moonshot.cn")))

(set-frame-parameter nil 'alpha-background 100)

(add-to-list 'default-frame-alist '(alpha-background . 100))

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4))) ; 设置缩进为4个空格，你可以根据需要调整数字

;; 设置垃圾回收大小为64mb
(setq gc-cons-threshold (* 32 1024 1024)
      gc-cons-percentage 0.5
      read-process-output-max (* 8 1024 1024)
      treemacs-space-between-root-nodes nil)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(load-file custom-file)

;; 设置英文字体
(set-face-attribute 'default nil :family "Unifont" :height 240)
