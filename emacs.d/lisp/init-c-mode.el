(require 'company)
(require 'lsp-mode)

(add-hook 'c-mode-hook
          (lambda ()
            (setq display-fill-column-indicator-column 81)
	    (setq show-trailing-whitespace t)
	    (c-set-style "linux")
	    (setq indent-tabs-mode nil)
	    (local-set-key (kbd "C-c d o") 'lsp-ui-doc-toggle)
	    (local-set-key (kbd "C-c g i") 'lsp-goto-implementation)
	    (local-set-key (kbd "C-c g d") 'lsp-goto-type-definition)
	    (lsp)
	    ;; (lsp-inlay-hints-mode)
	    (flycheck-mode)
	    (rainbow-delimiters-mode)
            (display-fill-column-indicator-mode 1)))

(setq lsp-clients-clangd-args '("--header-insertion=never"))

(provide 'init-c-mode)

