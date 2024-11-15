(setq org-todo-keywords
      '((sequence "TODO" "DOING" "DONE")))

(add-hook 'org-mode-hook (lambda ()
			   (setq line-spacing 0.45)
			   (visual-line-mode)
			   (auto-fill-mode 0)))

(defun my-org-insert-entry ()
  (interactive)
  (insert "#+TITLE: TITLE")
  (insert "#+DATE: DATE")
  (insert "#+AUTHOR: yangsiyu"))


(provide 'init-org)
