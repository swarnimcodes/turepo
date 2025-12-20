;;; turepo.el --- Open git repository in browser -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Swarnim Barapatre

;; Author: Swarnim Barapatre <swarnim14.9@hotmail.com>
;; Maintainer: Swarnim Barapatre <swarnim14.9@hotmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: vc, git, convenience
;; URL: https://github.com/swarnimcodes/turepo

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
(require 'vc)

(defun turepo-read-abs-fp (turepo-abs-fp)
  "Read text as string from an absolute file path.
Argument ABS-FP Absolute file path of the file to be read."
  (when (file-exists-p turepo-abs-fp)
    (with-temp-buffer
      (insert-file-contents turepo-abs-fp)
      (buffer-string))))


;; main :: go to repo
(defun turepo ()
  "Main function to go to the current project's git repo web page."
  (interactive)
  (let* ((turepo-root-dir (vc-root-dir))
         (turepo-git-cfg-fp (file-name-concat (expand-file-name turepo-root-dir) ".git" "config"))
         (turepo-git-cfg (turepo-read-abs-fp turepo-git-cfg-fp)))
    (message "Root Directory: %s" turepo-root-dir)
    (message "%s" turepo-git-cfg)

    ;; search for git url
    (cond
     ;; if it's already HTTPS, use it directly
     ((string-match "url = \\(https://[^ \t\n]+\\)" turepo-git-cfg)
      (let* ((turepo-url-raw (match-string 1 turepo-git-cfg))
             ;; strip .git suffix if present
             (turepo-url (replace-regexp-in-string "\\.git$" "" turepo-url-raw)))
        (message "Opening: %s" turepo-url)
        (browse-url turepo-url)))

     ;; otherwise parse SSH URL
     ((string-match "url = git@\\([^:]+\\):\\(.+\\)\\.git" turepo-git-cfg)
      (let* ((turepo-ssh-host (match-string 1 turepo-git-cfg))
             (turepo-repo-path (match-string 2 turepo-git-cfg))
             ;; check if it's GitLab, otherwise default to GitHub
	     ;; TODO: maybe have a more sophisticated gitlab check
             (turepo-hostname (if (string-match-p "gitlab" turepo-ssh-host)
                                  "gitlab.com"
                                "github.com"))
             (turepo-url (concat "https://" turepo-hostname "/" turepo-repo-path)))
        (message "Opening: %s" turepo-url)
        (browse-url turepo-url)))

     (t (message "Could not find git remote URL")))))


(provide 'turepo)
;;; turepo.el ends here
