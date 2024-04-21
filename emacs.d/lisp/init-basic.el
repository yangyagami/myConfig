;; 平滑滚动
(pixel-scroll-precision-mode 1)

;; whichkey
(require 'which-key)
(which-key-mode 1)

;; 默认打开fancy-compilation
(fancy-compilation-mode 1)

;; 关闭tool bar
(tool-bar-mode 0)

;; tabbar
(tab-bar-mode 1)

;; company mode
(global-company-mode)

;; 在底部打开term
(defun bterm ()
  (interactive)
  (let ((buf (generate-new-buffer "*bterm*")))
    (split-window-below 30)
    (other-window 1)
    (switch-to-buffer buf)
    (term-mode)
    (term buf)))

;; modeline显示时间
(setq display-time-format "%Y-%m-%d %H:%M")
(display-time-mode 1)

;; 显示行号
(global-display-line-numbers-mode)

;; 显示列数
(column-number-mode 1)

(provide 'init-basic)
