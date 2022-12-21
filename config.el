;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Chris Kim"
      user-mail-address "sunchaesk@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "monospace" :size 20))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-acario-dark)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.




;;Indents the whole page
(defun indent-buffer ()
  (interactive)
  (save-excursion
    (indent-region (point-min) (point-max) nil)))
(global-set-key (kbd "C-,") 'indent-buffer)

;;change C-backspace to something I'm more used to
(defun chris/backward-kill-word ()
  "Customize/Smart backward-kill-word."
  (interactive)
  (let* ((cp (point))
         (backword)
         (end)
         (space-pos)
         (backword-char (if (bobp)
                            ""           ;; cursor in begin of buffer
                          (buffer-substring cp (- cp 1)))))
    (if (equal (length backword-char) (string-width backword-char))
        (progn
          (save-excursion
            (setq backword (buffer-substring (point) (progn (forward-word -1) (point)))))
          (setq ab/debug backword)
          (save-excursion
            (when (and backword          ;; when backword contains space
                       (s-contains? " " backword))
              (setq space-pos (ignore-errors (search-backward " ")))))
          (save-excursion
            (let* ((pos (ignore-errors (search-backward-regexp "\n")))
                   (substr (when pos (buffer-substring pos cp))))
              (when (or (and substr (s-blank? (s-trim substr)))
                        (s-contains? "\n" backword))
                (setq end pos))))
          (if end
              (kill-region cp end)
            (if space-pos
                (kill-region cp space-pos)
              (backward-kill-word 1))))
      (kill-region cp (- cp 1)))         ;; word is non-english word
    ))

(global-set-key  [C-backspace]
                 'chris/backward-kill-word)

;; Projectile
(after! projectile
  (setq projectile-sort-order 'recentf)
  (setq projectile-enable-caching t))


;; Winner
(global-set-key (kbd "C-c j") 'winner-undo)
(global-set-key (kbd "C-c k") 'delete-other-windows)

;; transparency
;(set-frame-parameter (selected-frame) 'alpha '(85 50))
;(add-to-list 'default-frame-alist '(alpha 85 50))

;; Down 10 lines up 10 lines
(evil-define-motion LS-down-10-lines ()
  :type line
  (evil-next-visual-line 10))

(evil-define-motion LS-up-10-lines ()
  :type line
  (evil-previous-visual-line 10))

(map! :map evil-motion-state-map
      "C-j" 'LS-down-10-lines
      "C-k" 'LS-up-10-lines)


;;; CPP Configurations
;; (defun compile-CP ()
;; ;;   (interactive)
;; ;;   (let ((curr (buffer-file-name (window-buffer (minibuffer-selected-window)))))
;; ;;     (with-output-to-temp-buffer "*gcc-compile*"
;; ;;       (shell-command (concat "g++ -Wall -o" )))))


;; (defun compile-CP ()
;; ;;    (interactive)
;; ;;    (let ((filename (file-name-base (buffer-file-name)))
;; ;;          (curr (file-name-nondirectory (buffer-file-name))))
;; ;;      (with-output-to-temp-buffer "*gcc-compile*"
;; ;;        (print "Gcc Compiler Output: \n")
;; ;;        (print (shell-command-to-string (concat
;; ;;                                         "g++ -Wall -g -o" filename curr))))))

;; (require 'd-mode)

(flycheck-define-checker zig
    "A zig syntax checker using the zig-fmt interpreter."
    :command ("zig" "fmt" (eval (buffer-file-name)))
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": error: " (message) line-end))
    :modes zig-mode)
(add-to-list 'flycheck-checkers 'zig)

;; (package! 'smalltalk-mode)
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

;; writing, open file automatically in browser
(defun Writing-curr-file-open-browser ()
  (interactive)
  (save-buffer)
  (org-html-export-to-html buffer-file-name)
  (browse-url (concat
               (file-name-sans-extension buffer-file-name)
               ".html")))
;; end

;;; Python
(add-to-list 'display-buffer-alist
'("^\\*Python\\*$" . (display-buffer-same-window)))

;; neotree
  (setq neo-window-fixed-size nil)

;; latex viewer chnage pdf viewer
(setq +latex-viewers '(okular))
