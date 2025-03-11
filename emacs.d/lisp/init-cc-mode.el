;; C++ 设置
;; 格式化
(require 'google-c-style)
(require 'lsp-mode)
(require 'company)

(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 2)
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (setq show-trailing-whitespace t)
	    ;; (local-set-key (kbd "C-c d o") 'lsp-ui-doc-toggle)
	    ;; (local-set-key (kbd "C-c g i") 'lsp-goto-implementation)
	    ;; (local-set-key (kbd "C-c g d") 'lsp-goto-type-definition)
	    ;; (lsp)
	    ;; (lsp-inlay-hints-mode)
	    (google-set-c-style)
	    ;; (flycheck-mode)
	    (rainbow-delimiters-mode)
	    (display-fill-column-indicator-mode 1)))

(setq lsp-clients-clangd-args '("--header-insertion=never"))

(provide 'init-cc-mode)
