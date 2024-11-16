(use-package rime
  :custom
  (default-input-method "rime"))

(setq rime-disable-predicates
      '(rime-predicate-after-alphabet-char-p
	rime-predicate-after-ascii-char-p
	rime-predicate-space-after-cc-p))


(global-set-key (kbd "C-\\")
		(lambda ()
		  (interactive)
		  (toggle-input-method)
		  (rime-force-enable)))
(local-set-key (kbd "M-j") 'rime-force-enable)
(add-hook 'kill-emacs-hook #'rime-lib-finalize)

(provide 'init-rime)
