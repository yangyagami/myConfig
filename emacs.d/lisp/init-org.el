(setq org-todo-keywords
      '((sequence "TODO" "DOING" "DONE")))

(add-hook 'org-mode-hook (lambda ()
			   (setq line-spacing 0.45)
			   (visual-line-mode)
			   (auto-fill-mode 0)
			   (org-indent-mode)))

(defun my-org-insert-entry ()
  (interactive)
  (insert (format "#+TITLE: %s\n" buffer-file-name))
  (insert "#+DATE: DATE\n")
  (insert "#+AUTHOR: yangsiyu\n"))


(provide 'init-org)
