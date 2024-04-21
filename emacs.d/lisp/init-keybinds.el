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

(provide 'init-keybinds)
