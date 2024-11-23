(setq org-todo-keywords
      '((sequence "TODO" "DOING" "DONE")))

(add-hook 'org-mode-hook (lambda ()
			   (setq line-spacing 0.45)
			   (visual-line-mode)
			   (auto-fill-mode 0)))

(defun my-org-insert-entry ()
  (interactive)
  (insert "#+TITLE: TITLE\n")
  (insert "#+DATE: DATE\n")
  (insert "#+AUTHOR: yangsiyu\n"))


(provide 'init-org)
