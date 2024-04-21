;; C++ 设置
;; 格式化
(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 2)
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (setq show-trailing-whitespace t)
	    (display-fill-column-indicator-mode 1)))

(provide 'init-cc-mode)
