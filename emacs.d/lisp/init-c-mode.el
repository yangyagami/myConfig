(require 'company)
(require 'lsp-mode)

;; C语言下的设置
(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
         (column (c-langelem-2nd-pos c-syntactic-element))
         (offset (- (1+ column) anchor))
         (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))


(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 8)
            (setq display-fill-column-indicator-column 81)
	    (setq indent-tabs-mode t)
	    (setq show-trailing-whitespace t)
	    (c-set-style "linux-tabs-only")
	    (local-set-key (kbd "C-c d o") 'lsp-ui-doc-toggle)
	    (local-set-key (kbd "C-c g i") 'lsp-goto-implementation)
	    (local-set-key (kbd "C-c g d") 'lsp-goto-type-definition)
	    (lsp)
	    (lsp-inlay-hints-mode)
	    (flycheck-mode)
	    (rainbow-delimiters-mode)
            (display-fill-column-indicator-mode 1)))

(setq lsp-clients-clangd-args '("--header-insertion=never"))

(provide 'init-c-mode)
