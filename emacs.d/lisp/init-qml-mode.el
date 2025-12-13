(require 'company)
(require 'qml-comment)

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4)
	    (whitespace-mode)
	    (local-set-key (kbd "M-/") 'qml-comment-add)))


(provide 'init-qml-mode)
