;; utf-8
(prefer-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))
(setq-default pathname-coding-system 'utf-8)

;; font 等距更纱黑体 SC-12.0
(set-frame-font "Sarasa Mono SC-12.0")

;; 设置窗口为 80%屏宽，40%屏高
(if (not (eq window-system nil))
    (progn
      ;; pixel 即屏幕分辨率，char-height 根据字体设置而不同（本机为 20）
      ;; top, left 为像素值，height, width 为字符值
      ;; 如下的 top 取值为屏幕高的 1/25，在 2560x1440 的屏幕上约为 57 像素
      ;; height 取值为 1440x4 / (20*5)，约为 57 行
      (add-to-list 'default-frame-alist
                   (cons 'top  (/ (x-display-pixel-height) 25)))
      (add-to-list 'default-frame-alist
                   (cons 'left (/ (x-display-pixel-width) 25)))
      (add-to-list 'default-frame-alist
                   (cons 'height (/ (* 4 (x-display-pixel-height))
                                    (* 5 (frame-char-height)))))
      (add-to-list 'default-frame-alist
                   (cons 'width (/ (* 2 (x-display-pixel-width))
                                   (* 5 (frame-char-width)))))))

;; 处理 emacsclient 连接时不加载字体等问题
;; default-frame-alist 设置无法立即生效，需要使用 set-frame-系列函数
;; 此处根据本机情况直接取值，为适应不同机器，需要用如上公式求值
(add-hook 'after-make-frame-functions
          (lambda (new-frame)
            (select-frame new-frame)
            (set-frame-font "Sarasa Mono SC-12.0")
            (set-frame-height (selected-frame) 65)
            (set-frame-width (selected-frame) 140)
            (set-frame-position (selected-frame) 40 40)))

;; 在中英文间加上空格分隔
;; 设置 pangu-spacing，在中英文间自动加上空格分隔
;; (require 'pangu-spacing)
(use-package pangu-spacing
  :ensure t
  :config
  (global-pangu-spacing-mode 1)
;; really insert spaces, not visually
  (setq pangu-spacing-real-insert-separtor t))

;; PYIM 输入法
;; (use-package pyim
;;   :ensure nil
;;   :demand t
;;   :config
;;   (use-package pyim-basedict
;;     :ensure nil
;;     :config (pyim-basedict-enable))
;;   (use-package pyim-wbdict :ensure nil :config (pyim-wbdict-freeime-enable))
;;   (setq default-input-method "pyim")
;; ;; 使用五笔，辅助用全拼（按 TAB）
;;   (setq pyim-default-scheme 'wubi)
;;   (setq pyim-assistant-scheme 'quanpin)
;; ;; 使用 'posframe 绘制候选框，需要手动安装 posframe 包。
;; ;; (use-package posframe :ensure t)
;;   (setq pyim-page-tooltip 'posframe)
;; ;; 选词框显示 5 个候选词
;;   (setq pyim-page-length 5)
;; ;; 中文使用全角标点，英文使用半角标点。
;;   (setq pyim-punctuation-translate-p '(auto yes no))
;; ;; 根据环境切换中英文和半角全角标点
;;   (setq-default pyim-english-input-switch-functions
;;               '(pyim-probe-dynamic-english
;;                 pyim-probe-isearch-mode
;;                 pyim-probe-program-mode
;;                 pyim-probe-org-structure-template))
;;   (setq-default pyim-punctuation-half-width-functions
;;               '(pyim-probe-punctuation-line-beginning
;;                 pyim-probe-punctuation-after-punctuation))
;; ;; 转换前面输入的拼音字母为汉字
;;   (global-set-key (kbd "C-;") 'pyim-convert-string-at-point)
;; ;; 转换前面输入的标点为全角/半角
;;   (global-set-key (kbd "C-.") 'pyim-punctuation-translate-at-point)
;; ;; 设置全局按键启用输入法
;;   (global-set-key (kbd "C-\\") 'toggle-input-method))

;; emacs-rime
(use-package rime
  :load-path "~/.emacs.d/rime"
  :custom
  (default-input-method "rime")
  (rime-librime-root "~/.emacs.d/librime/dist/")
  (rime-emacs-module-header-root "~/.emacs.d/rime")
  (rime-user-data-dir "~/.emacs.d/rime-user-data")
  (rime-share-data-dir "~/.emacs.d/rime-data")
  (rime-show-candidate 'posframe)
  (rime-inline-ascii-trigger 'shift-l)
  :bind
  (:map rime-mode-map
        ("C-0" . 'rime-send-keybinding)))
;; 解决在中文文档中输入英文符号时受输入法影响，如 ; 和 [ ]
(setq rime-disable-predicates
        ;; 行首输入符号
      '(rime-predicate-punctuation-line-begin-p
        ;; 中文字符加空格之后输入符号
        rime-predicate-punctuation-after-space-cc-p
        ;; 中文字符加空格之后输入英文
        rime-predicate-space-after-cc-p
        ;; 英文使用半角符号
        rime-predicate-punctuation-after-ascii-p
        ;; 编程模式，只在注释中输入中文
        rime-predicate-prog-in-code-p))

;; tabnine 自动补全
(use-package company-tabnine :ensure t)
(add-to-list 'company-backends #'company-tabnine)
;; 此时，还需要 M-x company-tabnine-install-binary
;; Trigger completion immediately.
(setq company-idle-delay 0)
;; Number the candidates (use M-1, M-2 etc to select completions).
(setq company-show-numbers t)

;; 设置 ledger 模式记账
(use-package ledger-mode
  ;; 添加模式对应扩展名，.ledger 已默认
  :mode "\\.journal\\'")
;;   :config
;;   如果 ledger 不在 path 环境变量中
;;   (setq ledger-binary-path "/path/to/ledger.exe")

;; slime
;; quicklisp-slime-helper 带有自己的 slime，重复加载特别慢，不用
(use-package slime-autoloads
;;  :ensure nil
;;  :demand t
  :config
  (setq inferior-lisp-program "d:/SBCL/1.4.14/sbcl.exe")
  (setq slime-lisp-implementations
      '((sbcl ("sbcl" "--core" "d:/SBCL/1.4.14/sbcl.core-for-slime"))))
  (setq slime-contribs '(slime-fancy)))

(use-package go-mode)
