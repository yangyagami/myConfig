(add-hook 'lua-mode-hook
          (lambda ()
            (setq fill-column 81)
            (setq indent-tabs-mode nil)
	    (setq show-trailing-whitespace t)
	    ;; (local-set-key (kbd "C-c d o") 'lsp-ui-doc-toggle)
	    ;; (local-set-key (kbd "C-c g i") 'lsp-goto-implementation)
	    ;; (local-set-key (kbd "C-c g d") 'lsp-goto-type-definition)
	    ;; (lsp)
	    ;; (lsp-inlay-hints-mode)
	    (flycheck-mode)
	    (rainbow-delimiters-mode)
	    (display-fill-column-indicator-mode 1)))

(provide 'init-lua-mode)

