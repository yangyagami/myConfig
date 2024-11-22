;; 平滑滚动
(pixel-scroll-precision-mode 1)

;; ido
(ido-mode)
(ido-everywhere)

;; 高亮光标所在行
(global-hl-line-mode 1)

;; whichkey
(require 'which-key)
(which-key-mode 1)

;; 关闭启动页面
(setq inhibit-startup-screen t)

;; 默认打开fancy-compilation
(fancy-compilation-mode 1)

;; winum
(setq winum-keymap
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "C-`") 'winum-select-window-by-number)
      (define-key map (kbd "C-²") 'winum-select-window-by-number)
      (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
      (define-key map (kbd "M-1") 'winum-select-window-1)
      (define-key map (kbd "M-2") 'winum-select-window-2)
      (define-key map (kbd "M-3") 'winum-select-window-3)
      (define-key map (kbd "M-4") 'winum-select-window-4)
      (define-key map (kbd "M-5") 'winum-select-window-5)
      (define-key map (kbd "M-6") 'winum-select-window-6)
      (define-key map (kbd "M-7") 'winum-select-window-7)
      (define-key map (kbd "M-8") 'winum-select-window-8)
      map))
(require 'winum)
(winum-mode)

;; 关闭toolbar
(tool-bar-mode 0)
;; 关闭menubar
(menu-bar-mode 0)
;; 关闭scrollbar
(scroll-bar-mode 0)

;; tabbar
(tab-bar-mode 1)

;; modeline显示时间
(setq display-time-format "%Y-%m-%d %H:%M")
(display-time-mode 1)

;; 显示行号
(global-display-line-numbers-mode)

;; 显示列数
(column-number-mode 1)

;; rainbow
(rainbow-delimiters-mode 1)

(provide 'init-basic)
