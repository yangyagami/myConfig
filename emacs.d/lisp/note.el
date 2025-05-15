;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with ‘C-x C-f’ and enter text in its buffer.

;; 定义笔记模式（继承自org-mode）
(define-derived-mode note-mode org-mode "Note"
  "Major mode for quick note taking."
  (local-set-key (kbd "C-c c") #'note-save))

(defun note-create ()
  "创建新笔记buffer，包含选中内容"
  (interactive)
  (let ((content (if (use-region-p)
                     (buffer-substring (region-beginning) (region-end))
                   "")))
    (switch-to-buffer-other-window (get-buffer-create "*Note*"))
    (note-mode)
    (erase-buffer)
    (insert "Description: \n" content)
    (goto-char (point-min))
    (end-of-line)))

(defun note-save ()
  "保存笔记到指定文件"
  (interactive)
  (let* ((header (string-trim (buffer-substring (point-min) (line-end-position))))
         (content (string-trim (buffer-substring (line-beginning-position 2) (point-max))))
         (file-path (expand-file-name "~/Documents/note.org"))
         (timestamp (format-time-string "[%Y-%m-%d %a %H:%M]")))
    (when (string-blank-p header)
      (user-error "笔记描述不能为空"))
    
    (with-current-buffer (find-file-noselect file-path)
      (goto-char (point-max))
      (insert (format "\n* %s\n%s\n%s\n" 
                     (string-remove-prefix "Description: " header)
                     timestamp
                     content))
      (save-buffer))
    
    (kill-buffer (current-buffer))
  (message "笔记保存成功！")))

;; 绑定快捷键（建议使用C-c n创建笔记）
(global-set-key (kbd "C-c n") 'note-create)
  
;; 新增搜索功能
(defun note-search ()
  "搜索笔记内容并快速跳转"
  (interactive)
  ;; 解析笔记文件生成条目列表
  (let* ((entries (note-parse-entries))
         (keyword (read-string "搜索笔记: "))
         (candidates (note-filter-entries entries keyword)))
    (cond
     ((null candidates) (message "没有找到匹配的笔记"))
     ((= (length candidates) 1) (note-jump-to-entry (car candidates)))
     (t (note-choose-from-list candidates)))))

(defun note-parse-entries ()
  "解析笔记文件返回结构化条目列表"
  (when (file-exists-p note-file)
    (with-temp-buffer
      (insert-file-contents note-file)
      (goto-char (point-min))
      (let (entries)
        (while (re-search-forward "^\\* \\(.+?\\)\n\\(\\[.+?\\]\\)\n\\(\\(?:.\\|\n\\)*?\\)\n*" nil t)
          (push (list :title (match-string 1)
                      :timestamp (match-string 2)
                      :content (match-string 3)
                      :position (copy-marker (match-beginning 0)))
                entries))
        (reverse entries)))))

(defun note-filter-entries (entries keyword)
  "过滤匹配关键字的笔记条目"
  (cl-remove-if-not
   (lambda (entry)
     (cl-find-if 
      (lambda (field)
        (string-match-p (regexp-quote keyword)
                        (downcase (format "%s" (plist-get entry field)))))
      '(:title :timestamp :content)))
   entries))

(defun note-choose-from-list (candidates)
  "从候选列表中选择笔记"
  (let* ((items (mapcar
                 (lambda (entry)
                   (cons (format "%s %s - %s"
                                  (plist-get entry :timestamp)
                                  (plist-get entry :title)
                                  (truncate-string-to-width 
                                   (plist-get entry :content) 40 nil nil "..."))
                         entry))
                 candidates))
         (selection (completing-read "选择笔记: " items nil t)))
    (note-jump-to-entry (alist-get selection items nil nil #'equal))))

(defun note-jump-to-entry (entry)
  "跳转到指定笔记位置"
  (find-file note-file)
  (goto-char (plist-get entry :position))
  (recenter))

;; 绑定搜索快捷键（建议使用C-c s）
(global-set-key (kbd "C-c s") 'note-search)

(provide 'note)
