;; C++ 设置
;; 格式化
(require 'google-c-style)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 2)
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (setq show-trailing-whitespace t)
	    (display-fill-column-indicator-mode 1)))

(add-hook 'c++-mode-hook 'google-set-c-style)
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c++-mode-hook 'rainbow-delimiters-mode)

(require 'lsp)
(add-hook 'c++-mode-hook 'lsp-mode)

(provide 'init-cc-mode)
