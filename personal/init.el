;; Add all sub directories under /usr/share/emacs/site-lisp
;;(let ((default-directory "/usr/share/emacs/site-lisp/"))
;;  (normal-top-level-add-subdirs-to-load-path))

(defmacro depend (module &rest body)
  "Logs that the module is being loaded, loads it, and if successfull, runs
 the body"
  (let ((library-location
         (list 'locate-library (symbol-name (eval module)))))
    (list
     'if library-location
      (list 'progn
            (list 'message "Loading %s..."
                  (symbol-name (eval module)))
            (list 'when (list 'load library-location)
                  (cons 'progn
                        (append body
                                (list (list
                                       'message
                                       "Loaded %s" (symbol-name (eval module))))
                                )
                        )))
      (list 'message "Could not locate file for %s"
            (symbol-name (eval module))))))

;; Mingus
(depend 'mingus
  (global-set-key (kbd "C-x C-p") 'mingus)
  (global-set-key (kbd "C-x C-l") 'mingus-browse)
  )

;; Go
(add-to-list 'load-path "/home/laurie/Code/Go/go/misc/emacs" t)
(depend 'go-mode-load
  (add-hook 'go-mode-hook (lambda () (setq tab-width 4))))

;; Flymake
(depend 'flymake
  (require 'fringe-helper)
  (require 'flymake-extension)
  (require 'cl)
  (require 'flymake-cursor)
  (require 'fringe-helper)

  ;; Use pyflakes for python files
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "pyflakes" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init))
  (add-hook 'find-file-hook 'flymake-find-file-hook)

  ;; Use make to build C files
  (setq flymake-allowed-file-name-masks
        (cons '(".+\\.c$"
                flymake-simple-make-init
                flymake-simple-cleanup
                flymake-get-real-file-name)
              flymake-allowed-file-name-masks)))

; Python
(setq auto-mode-alist (append '(("/*.\.py$" . python-mode)) auto-mode-alist))

;; Markdown
(setq auto-mode-alist (append '(("\\.md$" . markdown-mode)) auto-mode-alist))

;; Haskell
(depend 'haskell-mode
  (require 'inf-haskell)
  (setq auto-mode-alist
        (append auto-mode-alist
                '(("\\.[hg]s$"  . haskell-mode)
                  ("\\.hi$"     . haskell-mode))
                ))
  (add-hook 'haskell-mode-hook 'turn-on-haskell-font-lock)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-decl-scan)
  )

;; Color scheme
(load-theme 'solarized-dark t)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(inhibit-default-init nil)
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(tool-bar-mode nil))

(defun set-paragraph-on-brackets ()
  (interactive)
  (setq paragraph-separate ".*[{}].*")
  (setq paragraph-start ".*[{}].*"))

;; D-mode
(depend 'd-mode
        (setq auto-mode-alist (append '(("/*.\.d$" . d-mode)) auto-mode-alist))
        (add-hook 'd-mode-hook 'set-paragraph-on-brackets)
        )

;; Lua
(depend 'lua-mode
  (setq auto-mode-alist (cons '("\.lua$" . lua-mode) auto-mode-alist)))

;; Shortcuts
(global-set-key (kbd "C-R") 'replace-string)
(global-set-key (kbd "C-T") 'goto-line)
(global-set-key (kbd "C-O") 'other-window)
(global-unset-key (kbd "C-x C-c"))

;; Marmalade
(depend 'package
  (add-to-list 'package-archives
               '("marmalade" . "http://marmalade-repo.org/packages/"))
  )

;; Clojure
(require 'clojure-mode)

; Slime
(setq inferior-lisp-program "/path/to/lisp-executable")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
(require 'slime)
(slime-setup)
(add-hook 'slime-repl-mode-hook (lambda () (paredit-mode +1)))

(add-to-list 'auto-mode-alist '("/*.md$" . markdown-mode))
