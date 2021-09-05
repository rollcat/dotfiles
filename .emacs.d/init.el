;; System
(setq system-is-gnu (string-prefix-p "gnu" (symbol-name system-type)))
(setq system-is-mac (equal 'darwin system-type))
(setq system-is-bsd (or
                     (equal 'berkeley-unix system-type)
                     system-is-mac))

(progn
  ;; startup, general configuration
  (setq inhibit-startup-message t)
  (setq visible-bell nil)
  (blink-cursor-mode -1)
  (column-number-mode t)
  (delete-selection-mode t)
  (tooltip-mode -1)
  (when window-system
    (set-fringe-mode 6)
    (tool-bar-mode -1)
    (mouse-wheel-mode)
    nil)
  (unless system-is-mac
    (menu-bar-mode -1)
    nil)
  (setq ring-bell-function 'ignore)
  ;; This will cause the pasted text to appear at point (like what you'd
  ;; see in xterm), instead of where the mouse cursor is pointing.
  (setq mouse-yank-at-point t)
  nil)

(when window-system
  ;; Find a font we like
  (defun font-exists-p (name)
    (if (find-font (font-spec :name name)) t nil))
  (require 'seq)
  (let ((font (seq-find 'font-exists-p '("Inconsolata 22" "Terminus 12"))))
    (when font
      (add-to-list 'default-frame-alist `(font . ,font))
      (set-face-attribute 'default t :font font)
      (set-frame-font font))))

(progn
  ;; Store local customized variables in a separate file.
  (setq custom-file "~/.emacs.d/custom.el")
  (unless (file-exists-p custom-file) (make-empty-file custom-file))
  (load custom-file))

;; Initialize package system
(require 'package)

(setq package-archives
      '(("org"   . "https://orgmode.org/elpa/")
        ("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Use-package for civilized configuration
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Reset the environment to what our .profile instructs.
(let* ((raw-env (shell-command-to-string ". ~/.profile && env"))
       (env-lines (split-string raw-env "\n"))
       (env-pairs
        (seq-filter (lambda (s) (equal 2 (length s)))
         (mapcar (lambda (s) (split-string s "=")) env-lines))))
  (mapcar (lambda (pair)
            (setenv (car pair) (cadr pair)))
          env-pairs)
  nil)
(let* ((path (split-string (getenv "PATH") ":")))
  (setq exec-path path)
  (cd (getenv "HOME"))
  nil)

;; Backups
(setq
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist '(("." . "~/.emacs.d/backups/"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)

;; Make it easier to discover key shortcuts

(use-package which-key
  :diminish
  :config
  (which-key-mode)
  (which-key-setup-side-window-bottom)
  (setq which-key-idle-delay 0.1))

;; Do not show some common modes in the modeline, to save space

(use-package diminish
  :defer 5
  :config
  (diminish 'org-indent-mode))

;; Magit

(use-package magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

;; Theme
(use-package solarized-theme
  :config
  (setq preferred-dark-theme 'solarized-zenburn)
  (setq preferred-light-theme 'solarized-light-high-contrast)

  (defun get-appearance-preferences ()
    (if system-is-mac
        (do-applescript "
tell application \"System Events\"
  tell appearance preferences
    if (dark mode) then
      return \"dark\"
    else
      return \"light\"
    end if
  end tell
end tell
")
      "dark"
      ))

  (defun update-theme ()
    (interactive)
    (let ((ap (get-appearance-preferences)))
      (mapcar #'disable-theme custom-enabled-themes)
      (cond
       ((equal ap "dark")  (load-theme preferred-dark-theme))
       ((equal ap "light") (load-theme preferred-light-theme))
       (t nil))))

  (custom-set-faces
   '(dired-subtree-depth-1-face ((t nil)))
   '(dired-subtree-depth-2-face ((t nil)))
   '(dired-subtree-depth-3-face ((t nil)))
   '(dired-subtree-depth-4-face ((t nil)))
   '(dired-subtree-depth-5-face ((t nil)))
   '(dired-subtree-depth-6-face ((t nil)))
   )

  (update-theme)
  nil)

;; Change buffer names for files with the same name
(require 'uniquify)
(setq uniquify-separator "/"               ;; The separator in buffer names.
      uniquify-buffer-name-style 'forward) ;; names/in/this/style

;; ivy
(use-package counsel :ensure t
  :diminish (ivy-mode . "")
  :config
  (ivy-mode 1)
  ;; add ‘recentf-mode’ and bookmarks to ‘ivy-switch-buffer’.
  (setq ivy-use-virtual-buffers t)
  ;; number of result lines to display
  (setq ivy-height 10)
  ;; does not count candidates
  (setq ivy-count-format "")
  ;; no regexp by default
  (setq ivy-initial-inputs-alist nil)
  ;; configure regexp engine.
  (setq ivy-re-builders-alist
	;; allow input not in order
        '((t . ivy--regex-ignore-order))))

;; Projectile
(use-package projectile
  :config
  (global-set-key (kbd "s-F") 'projectile-ripgrep)
  )


;; https://www.emacswiki.org/emacs/TrampMode
(progn
  (require 'tramp)
  (setq tramp-default-method "ssh")
  nil)


;; Ripgrep
(use-package ripgrep)

;; modes

(use-package dockerfile-mode)
(use-package typescript-mode)
(use-package terraform-mode)
(use-package yaml-mode)

(use-package lua-mode)
(use-package go-mode)
(use-package rust-mode)
(use-package swift-mode)


(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (defun web-django-mode ()
    (interactive)
    (web-mode)
    (web-mode-set-engine "django"))
  nil)

(require 'info)
(require 'python)
(use-package pip-requirements)

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(cua-selection-mode 1)

;; This default confuses lots of other software.
(setq create-lockfiles nil)

(progn ;; parens
  (show-paren-mode t)
  (setq show-paren-style 'expression)
  nil)

(setq ;; indentation
 standard-indent 4
 tab-width 4)
(setq-default indent-tabs-mode nil)


;; move where I mean
(use-package mwim
  :config
  (global-set-key (kbd "C-e") 'mwim-end)
  (global-set-key (kbd "C-a") 'mwim-beginning)
  )

;; compile & run what I mean
(defun dwim-run ()
  (interactive)
  (defun dwim-run-rust ()
    (setenv "RUST_BACKTRACE" "full")
    (rust-run))
  (message "DWIM run on major mode: %s" major-mode)
  (cond
   ((equal major-mode 'emacs-lisp-mode) (eval-buffer))
   ((equal major-mode 'rust-mode) (dwim-run-rust))
   ((equal major-mode 'rustic-mode) (dwim-run-rust))
   (t (compile))))

(defun dwim-test ()
  (interactive)
  (defun dwim-test-rust ()
    (setenv "RUST_BACKTRACE" "full")
    (rust-test))
  (message "DWIM test on major mode: %s" major-mode)
  (cond
   ((equal major-mode 'rust-mode) (dwim-test-rust))
   ((equal major-mode 'rustic-mode) (dwim-test-rust))
   (nil)))

;; fix/fmt what I mean
(defun dwim-fix ()
  (interactive)
  (defun dwim-fix-rust ()
    (shell-command "cargo fix --allow-staged && cargo fmt"))
  (message "DWIM fix on major mode: %s" major-mode)
  (cond
   ((equal major-mode 'rust-mode) (dwim-fix-rust))
   ((equal major-mode 'rustic-mode) (dwim-fix-rust))
   (nil)))

(defun open-finder-here ()
  (interactive)
  (shell-command "open ."))

(defun find-file-emacs-init ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(progn ;; global keys
  (global-set-key (kbd "C-h") 'delete-backward-char)
  (global-set-key (kbd "M-h") 'backward-kill-word)

  ;; M-x commands that I run way too often
  (global-set-key (kbd "C-x l") 'sort-lines)
  (global-set-key (kbd "C-x C-a") 'align-regexp)
  (global-set-key (kbd "C-x C-d") 'delete-trailing-whitespace)
  (global-set-key (kbd "C-x C-c") 'kill-buffer)
  (global-set-key (kbd "C-x C-r") 'replace-string)
  (global-set-key (kbd "C-x C-v") 'find-file-emacs-init)

  ;; follow mac conventions
  (global-set-key (kbd "s-<right>") 'mwim-end)
  (global-set-key (kbd "s-<left>") 'mwim-beginning)
  (global-set-key (kbd "s-<up>") 'beginning-of-buffer)
  (global-set-key (kbd "s-<down>") 'end-of-buffer)

  (global-set-key (kbd "M-<right>") 'right-word)
  (global-set-key (kbd "M-<left>") 'left-word)
  (global-set-key (kbd "M-<up>") 'backward-paragraph)
  (global-set-key (kbd "M-<down>") 'forward-paragraph)

  (global-set-key (kbd "C-<right>") 'right-word)
  (global-set-key (kbd "C-<left>") 'left-word)
  (global-set-key (kbd "C-<up>") 'backward-paragraph)
  (global-set-key (kbd "C-<down>") 'forward-paragraph)

  (global-set-key (kbd "s-W") 'delete-frame)
  (global-set-key (kbd "s-o") 'find-file)
  ;; (global-set-key (kbd "s-o") 'helm-find-files)
  (global-set-key (kbd "s-p") nil)
  (global-set-key (kbd "s-t") nil)
  (global-set-key (kbd "s-u") nil)
  (global-set-key (kbd "s-y") nil)
  (global-set-key (kbd "s-w") 'kill-current-buffer)
  (global-set-key (kbd "s-/") 'comment-dwim)
  (global-set-key (kbd "s-S") 'save-some-buffers)
  (global-set-key (kbd "s-s") 'save-buffer)
  (global-set-key (kbd "C-<tab>") 'next-buffer)
  (global-set-key (kbd "C-S-<tab>") 'previous-buffer)

  ;; more custom mac stuff
  (global-set-key (kbd "s-O") 'open-finder-here)
  (global-set-key (kbd "s-b") 'ivy-switch-buffer)
  (global-set-key (kbd "s-r") 'dwim-run)
  (global-set-key (kbd "s-R") 'dwim-test)
  (global-set-key (kbd "C-s-r") 'dwim-fix)
  ;; (global-set-key (kbd "s-b") 'helm-mini)

  ;; disable annoying keys
  (global-unset-key (kbd "C-z"))

  (progn ;; ivy, swiper, counsel
    (global-set-key (kbd "C-s") 'swiper-isearch)
    (global-set-key (kbd "s-f") 'swiper-isearch)
    (global-set-key (kbd "M-x") 'counsel-M-x)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (global-set-key (kbd "s-o") 'counsel-find-file)
    (global-set-key (kbd "M-y") 'counsel-yank-pop)
    (global-set-key (kbd "M-s-v") 'counsel-yank-pop)
    (global-set-key (kbd "<f1> f") 'counsel-describe-function)
    (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
    (global-set-key (kbd "<f1> l") 'counsel-find-library)
    (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
    (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
    (global-set-key (kbd "<f2> j") 'counsel-set-variable)
    (global-set-key (kbd "C-x b") 'ivy-switch-buffer)
    (global-set-key (kbd "s-b") 'ivy-switch-buffer)
    (global-set-key (kbd "C-c v") 'ivy-push-view)
    (global-set-key (kbd "C-c V") 'ivy-pop-view)
    nil)

  nil)

(progn ;; hooks
  ;; chmod +x on files with #!
  (add-hook 'after-save-hook
            'executable-make-buffer-file-executable-if-script-p)

  ;; golang hooks
  (add-hook 'go-mode-hook
            (lambda ()
              ;; run gofmt before saving *.go files
              (add-hook 'before-save-hook 'gofmt-before-save)
              ;; make more code fit on screen, duh
              (setq tab-width 4)
              nil))

  nil)

(use-package dumb-jump
  :config
  (global-set-key (kbd "C-.") 'dumb-jump-go)
  (global-set-key (kbd "C-,") 'dumb-jump-back)
  nil)

(progn ;; dired
  (require 'dired)
  (use-package dired-subtree)

  ;; use GNU coreutils ls on BSD systems
  (when system-is-bsd
    (setq insert-directory-program "gls"))

  (setq dired-listing-switches
        (concat
         "-l"   ; mandatory for dired
         " -hk" ; --kibibytes, 1M, 24K, etc
         " -A"  ; skip ".", ".."
         " -gG" ; skip group, owner
         " --group-directories-first"
         ))

  (add-hook 'dired-mode-hook
            (lambda ()
              (dired-hide-details-mode)
              (define-key dired-mode-map [mouse-2] 'dired-subtree-toggle)
              (define-key dired-mode-map (kbd "i") 'dired-subtree-toggle)
              (define-key dired-mode-map (kbd "r") 'mkdir)
              ))

  nil)

;; Don't make me spell out "yes" <enter>
(fset 'yes-or-no-p 'y-or-n-p)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Start server
(server-start)
