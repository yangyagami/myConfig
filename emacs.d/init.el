;; 添加.emacs.d/lisp
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

(require 'init-elpa)
(require 'init-theme)
(require 'init-basic)
(require 'init-org)

;; C语言下的设置
(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 8)
            (setq display-fill-column-indicator-column 81)
            (display-fill-column-indicator-mode 1)))

;; C++ 设置
;; 格式化
(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 2)
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (display-fill-column-indicator-mode 1)))
;; lsp
;; (require 'lsp-mode)
;; (add-hook 'c++-mode-hook #'lsp)

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4))) ; 设置缩进为4个空格，你可以根据需要调整数字

;; 切换window快捷键(shift + arrow)
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; Key-binds
;; 绑定C-'执行命令
(global-set-key (kbd "C-'") 'execute-extended-command)
;; 使用C-,, C-.来替代Alt-<,Alt->
(global-set-key (kbd "C-,") 'beginning-of-buffer) ; 绑定 C-SPC-n 到移动到文档顶部
(global-set-key (kbd "C-.") 'end-of-buffer) ; 绑定 C-SPC-p 到移动到文档底部
;; 插入一行
(global-set-key (kbd "<C-return>") (lambda () (interactive) (end-of-line) (newline-and-indent)))
(global-set-key (kbd "<C-S-return>") 'insert-line-above)
(defun insert-line-above ()
  "Insert a new line above the current line."
  (interactive)
  (move-beginning-of-line 1)
  (newline-and-indent)
  (previous-line)
)
;; 删除一整行
(global-set-key (kbd "<C-backspace>") 'delete-whole-line)
(defun delete-whole-line ()
  "Delete the current line."
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
)

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
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
 '(org-agenda-files '("/tmp/today.org"))
 '(package-selected-packages
   '(which-key flycheck lsp-ui company lsp-mode qml-mode fancy-compilation all-the-icons-gnus all-the-icons-nerd-fonts all-the-icons-dired melpa-upstream-visit magit doom-modeline doom-themes)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "RobotoMono Nerd Font" :foundry "pyrs" :slant normal :weight medium :height 128 :width normal)))))
(put 'upcase-region 'disabled nil)
