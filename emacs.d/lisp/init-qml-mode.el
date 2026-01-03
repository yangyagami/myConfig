(require 'company)
(require 'qml-comment)
(require 'qml-ts-mode)

(use-package qml-ts-mode
  :after lsp-mode
  :config
  (add-to-list 'lsp-language-id-configuration '(qml-ts-mode . "qml-ts"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("qmlls6"))
                    :activation-fn (lsp-activate-on "qml-ts")
                    :server-id 'qmlls))
  (add-hook 'qml-ts-mode-hook (lambda ()
                                (setq-local electric-indent-chars '(?\n ?\( ?\) ?{ ?} ?\[ ?\] ?\; ?,))
				(setq indent-tabs-mode nil)
				(setq-default qml-indent-offset 4)
				(whitespace-mode 1)
				(local-set-key (kbd "M-/") 'qml-comment-add)
                                (lsp-deferred))))


(provide 'init-qml-mode)
