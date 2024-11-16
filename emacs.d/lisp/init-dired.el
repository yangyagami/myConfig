(add-hook 'dired-mode-hook
	  (lambda ()
	    (dired-hide-details-mode)
	    (local-set-key (kbd "C-c c") 'dired-create-empty-file)))

(provide 'init-dired)
