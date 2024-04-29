;; Key-binds
;; 绑定C-'执行命令
(global-set-key (kbd "C-'") 'execute-extended-command)

;; 使用C-,, C-.来替代Alt-<,Alt->
(global-set-key (kbd "C-,") 'beginning-of-buffer) ; 绑定 C-SPC-n 到移动到文档顶部
(global-set-key (kbd "C-.") 'end-of-buffer) ; 绑定 C-SPC-p 到移动到文档底部

;; 使用ace-window替换默认的窗格切换
(global-set-key (kbd "C-x o") 'ace-window)

;; F5重新编译
(global-set-key (kbd "<f5>") 'recompile)

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

;; 超过两个窗格时，kill buffer自动关闭当前窗格
(defun my-close-buffer-or-window ()
  "Close buffer if there's only one window, otherwise close both buffer and window."
  (interactive)
  (if (one-window-p)
      (kill-buffer)
    (kill-buffer)
    (delete-window)))
(global-set-key (kbd "C-x C-k") 'my-close-buffer-or-window)

(provide 'init-keybinds)
