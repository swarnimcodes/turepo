# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-06

### Added
- Debug mode configuration option `turepo-debug-mode` to control message verbosity.
- Private helper function (`turepo--message`) that intercepts all messages and prints them to message buffer conditionally.

### Changed
- Removed almost all messages being sent to the end user in non-debug mode.
- Migrated all message buffer print lines to use `turepo--message` helper function.

## [0.1.0] - 2025-12-27

### Added
- Initial release
- Open git repository in browser from Emacs
- Support for GitHub repositories
- Support for GitLab repositories (including self-hosted instances)
- Support for Codeberg repositories
- Support for SourceHut repositories
- Support for Gitea repositories
- Support for both SSH and HTTP(S) remote URLs
- Error handling for non-git directories

## Changed
- Reduced debug message vomit to end user
- Namespaced all the variables used throughout the codebase


