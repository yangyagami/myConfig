;; lua 设置

(add-hook 'lua-ts-mode-hook
          (lambda ()
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (setq show-trailing-whitespace t)
	    (display-fill-column-indicator-mode 1)))


(provide 'init-lua-mode)
