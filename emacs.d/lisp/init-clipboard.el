;; 系统剪贴板共享 (Hyprland / Wayland)
;;
;; 在 Wayland 下 xclip 走的是 XWayland 的 X11 剪贴板，与 Wayland 原生
;; 剪贴板不同步（Hyprland 不桥接 X11 -> Wayland），导致浏览器等
;; Wayland 原生应用读不到 Emacs 复制的内容。
;; 因此这里让 xclip.el 改用 wl-clipboard (wl-copy / wl-paste)。
(require 'xclip)
(setq xclip-method 'wl-copy
      ;; xclip-program 默认值是加载时对 xclip-method 的快照，必须手动同步
      xclip-program "wl-copy")
(xclip-mode 1)

(provide 'init-clipboard)
