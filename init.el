(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; Store custom-file separately, don't freak out when it's not found
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;;
;; Sane defaults

;; handle emacs utf-8 input
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setenv "LANG" "en_us.UTF-8")

;; Smoother and nicer scrolling
(setq scroll-margin 10
   scroll-step 1
   next-line-add-newlines nil
   scroll-conservatively 10000
   scroll-preserve-screen-position 1)

(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; Use ESC as universal get me out of here command
(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; Use Alt-up/Alt-down for scrolling up and down
(define-key key-translation-map (kbd "<A-up>") (kbd "M-v"))
(define-key key-translation-map (kbd "<A-down>") (kbd "C-v"))

;; Don't bother with auto save and backups.
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Revert (update) buffers automatically when underlying files are changed externally.
(global-auto-revert-mode t)

(setq
 inhibit-startup-message t         ; Don't show the startup message...
 inhibit-startup-screen t          ; ... or screen
 cursor-in-non-selected-windows t  ; Hide the cursor in inactive windows

 echo-keystrokes 0.1               ; Show keystrokes right away, don't show the message in the scratch buffer
 initial-scratch-message nil       ; Empty scratch buffer
 sentence-end-double-space nil     ; Sentences should end in one space, come on!
 confirm-kill-emacs 'y-or-n-p      ; y and n instead of yes and no when quitting
 help-window-select t              ; Select help window so it's easy to quit it with 'q'
 )

(fset 'yes-or-no-p 'y-or-n-p)      ; y and n instead of yes and no everywhere else
(delete-selection-mode 1)          ; Delete selected text when typing


(global-set-key (kbd "M-s") 'save-buffer) ;; save
(global-set-key (kbd "M-S") 'write-file)              ;; save as
(global-set-key (kbd "M-q") 'save-buffers-kill-emacs) ;; quit
(global-set-key (kbd "M-a") 'mark-whole-buffer)       ;; select all
(global-set-key (kbd "<A-right>") 'projectile-next-project-buffer)       ;; next buffer
(global-set-key (kbd "<A-left>") 'projectile-previous-project-buffer)   ;; previous buffer

;; Delete trailing spaces and add new line in the end of a file on save.
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq require-final-newline t)

;; Linear undo and redo.
(use-package undo-fu)
(global-set-key (kbd "M-z")   'undo-fu-only-undo)
(global-set-key (kbd "M-Z") 'undo-fu-only-redo)

;;
;; VISUALS

(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Enable transparent title bar on macOS
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . light)) ;; {light, dark}
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; Font
(when (member "JetBrains Mono" (font-family-list))
  (set-face-attribute 'default nil :font "JetBrains Mono 15"))
(setq-default line-spacing 2)

;; Nice and simple default light theme.
(load-theme 'tsdh-light)

;; Always wrap lines
(global-visual-line-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Show parens and other pairs.
(use-package smartparens
  :diminish
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;; Set colors to distinguish between active and inactive windows
(set-face-attribute 'mode-line nil :background "SlateGray1")
(set-face-attribute 'mode-line-inactive nil :background "grey93")

;; File tree
(use-package neotree
  :config
  (setq neo-window-width 32
        neo-create-file-auto-open t
        neo-banner-message nil
        neo-show-updir-line t
        neo-window-fixed-size nil
        neo-vc-integration nil
        neo-mode-line-type 'neotree
        neo-smart-open t
        neo-show-hidden-files t
        neo-mode-line-type 'none
        neo-auto-indent-point t)
  (setq neo-theme (if (display-graphic-p) 'nerd 'arrow))
  (setq neo-hidden-regexp-list '("venv" "\\.pyc$" "~$" "\\.git" "__pycache__" ".DS_Store"))
  (global-set-key (kbd "M-b") 'neotree-toggle))           ;; Cmd+Shift+b toggle tree

;; Show full path in the title bar.
(setq-default frame-title-format "%b (%f)")

;; Never use tabs, use spaces instead.
(setq tab-width 2)
(setq js-indent-level 2)
(setq css-indent-offset 2)
(setq c-basic-offset 2)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 2)
(setq-default tab-width 2)
(setq-default c-basic-indent 2)

;; TEXT EDITING

;; Move-text lines around with meta-up/down.
(use-package move-text
  :config
  (move-text-default-bindings))

;; Comment line or region.
(global-set-key (kbd "M-/") 'comment-line)

;; Symbol highlighting
(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :hook (prog-mode . highlight-symbol-mode)
  :config (setq highlight-symbol-idle-delay 0.3))

;; CODE COMPLETION
(use-package company
  :config
  (setq company-idle-delay 0.1)
  (setq company-global-modes '(not org-mode))
  (setq company-minimum-prefix-length 1)
  (add-hook 'after-init-hook 'global-company-mode))


;; Set the company completion vocabulary to css and html when in web-mode.
(defun my-web-mode-hook ()
  (set (make-local-variable 'company-backends) '(company-css company-web-html company-yasnippet company-files)))


;; WINDOW MANAGEMENT

;; This is rather radical, but saves from a lot of pain in the ass.
;; When split is automatic, always split windows vertically
(setq split-height-threshold 0)
(setq split-width-threshold nil)

;; Move between windows with Control-Command-Arrow and with =Cmd= just like in iTerm.
(use-package windmove
  :config
  (global-set-key (kbd "<A-M-left>")  'windmove-left)  ;; Ctrl+Cmd+left go to left window
  (global-set-key (kbd "<A-M-right>") 'windmove-right) ;; Ctrl+Cmd+right go to right window
  (global-set-key (kbd "<A-M-up>")    'windmove-up)    ;; Ctrl+Cmd+up go to upper window
  (global-set-key (kbd "<A-M-down>")  'windmove-down))  ;; Ctrl+Cmd+down go to down window

;; Go to other windows easily with one keystroke Cmd-something.
(global-set-key (kbd "M-1") (kbd "C-x 1"))  ;; Cmd-1 kill other windows (keep 1)
(global-set-key (kbd "M-2") (kbd "C-x 2"))  ;; Cmd-2 split horizontally
(global-set-key (kbd "M-3") (kbd "C-x 3"))  ;; Cmd-3 split vertically
(global-set-key (kbd "M-0") (kbd "C-x 0"))  ;; Cmd-0...

;; PROJECT MANAGEMENT
(use-package projectile
  :diminish projectile-mode
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "M-p") 'projectile-find-file)
  (setq projectile-git-submodule-command nil)
  (setq projectile-sort-order 'recentf
        projectile-indexing-method 'hybrid)
  (projectile-mode +1))

;; MENUS AND COMPLETIONS

;; Use minimalist Ivy for most things.
(use-package ivy
  :diminish                             ;; don't show Ivy in minor mode list
  :config
  (ivy-mode 1)                          ;; enable Ivy everywhere
  (setq ivy-use-virtual-buffers t)      ;; show bookmarks and recent files in buffer list
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)

  (setq ivy-re-builders-alist
      '((swiper . ivy--regex-plus)
        (t      . ivy--regex-fuzzy)))   ;; enable fuzzy searching everywhere except for Swiper

  (global-set-key (kbd "C-b") 'ivy-switch-buffer)  ;; Cmd+b show buffers and recent files
  ;; (global-set-key (kbd "C-s-b") 'ivy-resume)
)      ;; Alt+Cmd+b resume whatever Ivy was doing


;; Swiper is a better local finder.
(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper)       ;; Default Emacs Isearch forward...
  (global-set-key "\C-r" 'swiper)       ;; ... and Isearch backward replaced with Swiper
  (global-set-key (kbd "M-f") 'swiper)) ;; Cmd+f find text

;; VERSION CONTROL
;; Magit
(use-package magit
  :config
  (global-set-key (kbd "M-g") 'magit-status))   ;; Cmd+g for git status

;; Show changes in the gutter
(use-package git-gutter
  :diminish
  :config
  (global-git-gutter-mode 't)
  (set-face-background 'git-gutter:modified 'nil)   ;; background color
  (set-face-foreground 'git-gutter:added "green4")
  (set-face-foreground 'git-gutter:deleted "red"))
