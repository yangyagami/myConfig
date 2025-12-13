;;; qml-comment.el --- 在 QML 块后自动添加注释

(defun extract-id-value (str)
  "从字符串中提取id的值。"
  (when (string-match "id: \\([a-zA-Z]+\\)" str)
    (match-string 1 str)))

(defun process-block (block)
  (let ((lines (split-string block "\n"))
        result
        stop)
    (dolist (line lines)
      (unless stop
        ;; 检查是否包含结束字符
	(message "line: %s" line)
        (if (or (string-match-p "{" line)
                (string-match-p "}" line))
            (setq stop t)  ; 设置停止标志
          ;; 检查是否包含目标单词
	  (let ((id (extract-id-value line)))
	    (when id
	      (message "extrace id success")
              (push id result))))))  ; 将匹配的行添加到结果中
    ;; 返回结果（反转，因为 push 是向前添加的）
    (nreverse result)))

(defvar qml-comment-debug t
  "是否启用调试信息")

(defun qml-comment-debug-log (message &rest args)
  "输出调试信息"
  (when qml-comment-debug
    (apply 'message (concat "[QML-Comment] " message) args)))

(defun qml-comment-get-char-before ()
  "获取光标前一个字符"
  (when (> (point) 1)
    (char-to-string (char-before))))

(defun qml-comment-find-matching-brace ()
  "找到与当前光标前的 '}' 匹配的 '{' 的位置。
  返回一个列表：(brace-pos word)，其中 brace-pos 是 '{' 的位置，word 是前面的单词。
  如果没有找到匹配的 '{'，返回 nil。"
  (save-excursion
    ;; 检查光标前是否是 '}'    
    ;; 使用 Emacs 内置的括号匹配找到匹配的 '{'
    (condition-case err
        (progn
          (backward-sexp 1)  ; 跳转到匹配的 '{'
          
          ;; 现在我们在 '{' 上，获取 '{' 的位置
          (let ((brace-start (point)))
            (qml-comment-debug-log "找到匹配的 '{' 在位置 %d" brace-start)

	    (forward-sexp 1)

	    (let* ((brace-end (point))
		   (block (buffer-substring-no-properties (+ brace-start 1) (+ brace-end 1)))
		   (id (process-block block)))
	      (qml-comment-debug-log "point: %d" (point))
	      (qml-comment-debug-log "block: %s" block)
	      (message "got id: %s" (nth 0 id))

	      (backward-sexp 1)
              
              ;; 向前查找单词（跳过空格、换行等）
	      (backward-sexp 1)
              (let ((word-start (point)))
		(forward-sexp 1)
		(let ((word-end (point)))
                  (qml-comment-debug-log "单词开始位置: %d, 结束位置: %d" word-start word-end)
		  (qml-comment-debug-log "单词: %s" (buffer-substring-no-properties word-start word-end))
	          (list (buffer-substring-no-properties word-start word-end) (nth 0 id)))))))
      
      ;; 处理错误（比如没有找到匹配的括号）
      (error 
       (qml-comment-debug-log "错误: %s" (error-message-string err))
       nil))))

(defun qml-comment-check-before-brace ()
  "检查光标前是否是 '}'，并获取相关信息。
  返回一个列表：(brace-pos word)，如果不符合条件返回 nil。"
  (interactive)
  (let ((result (qml-comment-find-matching-brace)))
    (if result
        (progn
          result)
      (qml-comment-debug-log "失败: 未找到匹配的 '{' 或光标前不是 '}'")
      nil)))

(defun qml-comment-test-brace ()
  "测试函数，用于验证检测功能"
  (interactive)
  (let ((result (qml-comment-check-before-brace)))
    (if result
        (message "成功! '{' 在位置 %d, 单词是: %s" 
                 (nth 0 result) (nth 1 result))
      (message "失败! 光标前不是 '}' 或未找到匹配的 '{'"))))

;; 主功能函数（目前只实现第一步）
;; 主功能函数（目前只实现第一步）
(defun qml-comment-add ()
  "在 QML 块后添加注释（第一步：检测和获取单词）"
  (interactive)
  (let ((result (qml-comment-check-before-brace)))
    (when result
      (let ((word (nth 0 result))
            (id (nth 1 result)))
        (when word
          (message "准备添加注释: %s %s" word id)
          ;; 这里后续会添加第二步和第三步的功能
          (insert (format "  // %s%s" 
                          word
                          (if id (format "($%s)" id) ""))))))))

;; 绑定快捷键 Alt+/
(global-set-key (kbd "M-/") 'qml-comment-add)

;; 为了方便测试，也绑定一个测试快捷键 C-c C-t
(global-set-key (kbd "C-c C-t") 'qml-comment-test-brace)

(provide 'qml-comment)

;;; qml-comment.el ends here
