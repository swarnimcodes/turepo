;;; turepo.el --- Open git repository in browser -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Swarnim Barapatre

;; Author: Swarnim Barapatre <swarnim.barapatre@accurateic.in>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: vc, git, convenience
;; URL: https://github.com/swarnimcodes/turepo

;;; Commentary:

;; turepo provides a simple command to open the current project's
;; git repository in your web browser.  It supports:
;; - GitHub (SSH and HTTPS)
;; - GitLab (SSH and HTTPS)
;; - SSH aliases (github-work, gitlab-personal, etc.)

;; Usage:
;;   M-x turepo
;; Or bind it to a key:
;;   (global-set-key (kbd "C-c g r") 'turepo)

;;; Code:

(defun read-abs-fp (abs-fp)
  "Read text as string from an absolute file path.
Argument ABS-FP Absolute file path of the file to be read."
  (when (file-exists-p abs-fp)
    (with-temp-buffer
      (insert-file-contents abs-fp)
      (buffer-string))))


;; main :: go to repo
(defun turepo ()
  "Main function to go to the current project's git repo web page."
  (interactive)
  (setq-local root-dir (project-root (project-current)))
  (message "Root Directory: %s" root-dir)
  ;; git config file
  (setq-local git-cfg-fp (file-name-concat (expand-file-name root-dir) ".git" "config"))
  (setq-local git-cfg (read-abs-fp git-cfg-fp))
  (message "%s" git-cfg)

  ;; search for git url
  (cond
   ;; If it's already HTTPS, use it directly
   ((string-match "url = \\(https://[^ \t\n]+\\)" git-cfg)
    (setq-local url (match-string 1 git-cfg))
    ;; Strip .git suffix if present
    (setq-local url (replace-regexp-in-string "\\.git$" "" url))
    (message "Opening: %s" url)
    (browse-url url))

   ;; Otherwise parse SSH URL
   ((string-match "url = git@\\([^:]+\\):\\(.+\\)\\.git" git-cfg)
    (setq-local ssh-host (match-string 1 git-cfg))
    (setq-local repo-path (match-string 2 git-cfg))
    ;; Check if it's GitLab, otherwise default to GitHub
    (setq-local hostname
                (if (string-match-p "gitlab" ssh-host)
                    "gitlab.com"
                  "github.com"))
    (setq-local url (concat "https://" hostname "/" repo-path))
    (message "Opening: %s" url)
    (browse-url url))

   (t (message "Could not find git remote URL")))
  )


(provide 'turepo)
;;; turepo.el ends here
