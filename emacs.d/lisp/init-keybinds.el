;; F5重新编译，F6编译
(global-set-key (kbd "<f5>") 'recompile)
(global-set-key (kbd "<f6>") 'compile)

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
