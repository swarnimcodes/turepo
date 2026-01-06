;;; turepo.el --- Open git repository in browser -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Swarnim Barapatre

;; Author: Swarnim Barapatre <swarnim14.9@hotmail.com>
;; Maintainer: Swarnim Barapatre <swarnim14.9@hotmail.com>
;; Version: 0.2.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: vc, git, convenience, github
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
;; - GitHub
;; - GitLab
;; - Codeberg
;; - SourceHut
;; - Gitea
;; Both ssh based and http based git projects are supported

;; Usage:

;; Via use-package:
;; (use-package turepo
;;   :ensure t
;;   :bind (("C-c g r" . turepo)))

;; Or directly via the `turepo` function provided by the package.

;; Configuration:

;; turepo-debug-mode (default: nil)
;;   When enabled, displays debug messages showing the execution flow,
;;   including git repository location, config file path, matched URL
;;   pattern, and the URL being opened.  When disabled (default), turepo
;;   operates silently on success and only displays error messages.
;;
;;   Enable debug mode:
;;   (setq turepo-debug-mode t)
;;
;;   Or via use-package:
;;   (use-package turepo
;;     :custom
;;     (turepo-debug-mode t))

;; Developed by Swarnim B (https://smarniw.com)

;;; Code:
(require 'vc)

;; add a debug mode option
(defcustom turepo-debug-mode nil
  "Enable debug messages in turepo.
When enabled, the program will try to log helpful debug messsages \
regarding the execution in the message buffer.
When turned off, the program will execute silently."
  :type 'boolean
  :group 'vc)


;; helper function to print to message buffer
(defun turepo--message (format-string &rest args)
  "Print the message to the message buffer if `turepo-debug-mode` is enabled.
FORMAT-STRING and ARGS are passed to `message'."
  (when turepo-debug-mode
    (apply #'message format-string args)))

;; 
(defun turepo-read-abs-fp (turepo-abs-fp)
  "Read text as string from an absolute file path.
Argument TUREPO-ABS-FP Absolute file path of the file to be read."
  (when (file-exists-p turepo-abs-fp)
    (with-temp-buffer
      (insert-file-contents turepo-abs-fp)
      (buffer-string))))


;; main :: go to repo
;;;###autoload
(defun turepo ()
  "Main function to go to the current project's git repo web page."
  (interactive)
  (catch 'not-in-git-repo
    (let* ((turepo-root-dir (vc-root-dir)))
      (turepo--message "[turepo-debug] Found git repository at: %s" turepo-root-dir)

      (unless turepo-root-dir
	;; when we are not inside a git repo, print a helpful message and exit
	(message "[turepo-error] Turepo command invoked but could not determine git repository. Are you inside a git repository?")
	(throw 'not-in-git-repo nil))

      (let* ((turepo-git-cfg-fp (file-name-concat (expand-file-name turepo-root-dir) ".git" "config"))
	     (turepo-git-cfg (turepo-read-abs-fp turepo-git-cfg-fp)))

	(turepo--message "[turepo-debug] Reading git config from: %s" turepo-git-cfg-fp)

	;; search for git url
	(cond
	 ;; if it's already HTTP/HTTPS, use it directly
	 ((string-match "url = \\(https?://[^ \t\n]+\\)" turepo-git-cfg)
	  (let* ((turepo-url-raw (match-string 1 turepo-git-cfg))
		 ;; strip .git suffix if present
		 (turepo-url (replace-regexp-in-string "\\.git$" "" turepo-url-raw)))
	    (turepo--message "[turepo-debug] Matched HTTP(S) URL pattern")
            (turepo--message "[turepo-info] Opening: %s" turepo-url)
            (browse-url turepo-url)))

	 ;; ssh:// format (codeberg, sourcehut, etc.)
	 ;; examples: ssh://git@codeberg.org/smarniw/testing-turepo.git
	 ;;           ssh://git@git.sr.ht/~smarniw/testing-repo
	 ;;           ssh://git@git.sr.ht/~reykjalin/fn
	 ((string-match "url = ssh://git@\\(.+\\)" turepo-git-cfg)
	  (let* ((turepo-path (match-string 1 turepo-git-cfg))  ;; e.g., "codeberg.org/smarniw/repo.git"
		 (turepo-url (concat "https://" (replace-regexp-in-string "\\.git$" "" turepo-path))))
	    (turepo--message "[turepo-debug] Matched SSH URL pattern")
	    (turepo--message "[turepo-info] Opening %s" turepo-url)
	    (browse-url turepo-url)))

	 ;; github/gitlab format :: git@HOST:REPO.git
	 ;; examples: git@github.com:swarnimcodes/turepo.git
	 ;;           git@gitlab.com:user/repo.git
	 ;;           git@gitlab.evilcorp.in:user/repo.git (self-hosted instances)
	 ((string-match "url = git@\\([^:]+\\):\\(.+\\)\\.git" turepo-git-cfg)
	  (let* ((turepo-ssh-host (match-string 1 turepo-git-cfg))
		 (turepo-repo-path (match-string 2 turepo-git-cfg))
		 (turepo-url (concat "https://" turepo-ssh-host "/" turepo-repo-path)))
	    (turepo--message "[turepo-debug] Matched git@host:repo pattern")
	    (turepo--message "[turepo-info] Opening %s" turepo-url)
	    (browse-url turepo-url)))

	 (t (message "[turepo-error] Could not find an appropriate git remote URL")))))))

(provide 'turepo)
;;; turepo.el ends here
