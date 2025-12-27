# turepo

Open your project's git repository in the browser in a flash.

[![MELPA](https://melpa.org/packages/turepo-badge.svg)](https://melpa.org/#/turepo)

![External Demo GIF](https://imgur.com/a/JK5PMJU)


## Features

- Jump from code to web repository instantly
- Supports GitHub, GitLab, Codeberg and SourceHut (both SSH and HTTPS URLs)
- Works with SSH config aliases
- Compatible with self-hosted instances (https only)

## Installation

### From MELPA (recommended) ~~(awating-merge)~~ (merged)

Check melpa merge status here: https://github.com/melpa/melpa/pull/9726

```elisp
(use-package turepo
  :ensure t
  :bind (("C-c g r" . turepo)))
```


### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/swarnimcodes/turepo ~/.emacs.d/turepo
```

2. Add to your init file:
```elisp
(use-package turepo
  :ensure nil
  :load-path "~/.emacs.d/turepo"
  :bind (("C-c g r" . turepo)))
```

## Usage

Run `M-x turepo` or press `C-c g r` (if you set up the keybinding above) while in any project buffer. 
your default browser will open to the repository's web page.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please open an issue or submit a pull request.

## Author

Swarnim Barapatre ([@swarnimcodes](https://github.com/swarnimcodes))
