(setq-default cursor-type 'bar) ; 设置光标为方块 
(blink-cursor-mode -1) 
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
;;(put 'set-goal-column 'disabled nil)

;;don't like backup
(setq backup-inhibited t)
(define-prefix-command 'my-map)
(global-set-key (kbd "C-z") 'my-map)
(global-set-key (kbd "C-z s") 'shell) 
(global-set-key (kbd "C-z r") 'rename-buffer) 
(global-set-key (kbd "C-z m") 'man) 
(global-set-key (kbd "C-z v") 'revert-buffer)
;;(global-set-key (kbd "C-z C-l") 'move-beginning-of-line 'kill-line)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-o") 'backward-list)
(global-set-key (kbd "C-z g") 'goto-line)

;;ido mode
(ido-mode t)
(setq ido-everywhere t)

;;cscope
(add-hook 'c-mode-common-hook
  '(lambda ()
    (require 'xcscope)
    (define-prefix-command 'my-cscope-map)
    (define-key cscope:map (kbd "C-\\") 'my-cscope-map)
    (define-key cscope:map (kbd "C-]") 'cscope-find-global-definition) 
    (define-key cscope:map (kbd "C-O") 'cscope-pop-mark) 
    (define-key cscope:map (kbd "C-\\ g") 'cscope-find-global-definition)   
    (define-key cscope:map (kbd "C-\\ s") 'cscope-find-this-symbol)   
    (define-key cscope:map (kbd "C-\\ c") 'cscope-find-functions-calling-this-function)   
))
(setq cscope-do-not-update-database t)

;;org
(add-hook 'org-mode-hook
  '(lambda()
	(define-key global-map (kbd "C-M-j") 'org-insert-heading) 
	(setq truncate-lines nil)))

;;hide-show
;;(add-to-list 'hs-minor-mode 'python-mode)
(add-hook 'python-mode-hook 'hs-minor-mode)
(global-set-key (kbd "C-z f") 'hs-toggle-hiding)


;;flymake
;; python need to install pyflakes
(when (load "flymake" t) 
  (defun flymake-pyflakes-init () 
    (let* ((temp-file (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace)) 
	   (local-file (file-relative-name temp-file (file-name-directory buffer-file-name)))) 
      (list "pyflakes" (list local-file)))) 
  (add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-pyflakes-init))) 

(add-hook 'find-file-hook 'flymake-find-file-hook)

;;yas
(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet")
(require 'yasnippet) ;; not yasnippet-bundle
;; Develop and keep personal snippets under ~/emacs.d/mysnippets
(setq yas/root-directory "~/.emacs.d/plugins/yasnippet/snippets")
;; Load the snippets
(yas/load-directory yas/root-directory)
(setq yas-global-mode nil)

;;auto-complete
(add-to-list 'load-path "~/.emacs.d/plugins/ac")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/plugins/ac/ac-dict")
(ac-config-default)
(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
(setq ac-auto-start 4)
(add-to-list 'ac-modes 'shell-mode)
(add-to-list 'ac-modes 'text-mode)
(add-to-list 'ac-modes 'org-mode)

;;ace-jump
(add-to-list 'load-path "~/.emacs.d/plugins/acejump")
(autoload  'ace-jump-mode  "ace-jump-mode"  "Emacs quick move minor mode"  t)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(autoload  'ace-jump-mode-pop-mark  "ace-jump-mode"  "Ace jump back:-)"  t)
(eval-after-load "ace-jump-mode"  '(ace-jump-mode-enable-mark-sync))
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
