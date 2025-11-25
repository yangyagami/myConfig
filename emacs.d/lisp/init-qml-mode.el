(require 'company)

;; qml 设置
(add-hook 'qml-mode-hook
          (lambda ()
            (setq-default qml-indent-offset 4)
	    (whitespace-mode)
	    ))


(provide 'init-qml-mode)
