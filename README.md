# Dotfiles

This repository contains my dotfiles, which are configuration files for various applications and tools that I use.

## Prerequisites

Before using these dotfiles, you will need to install Homebrew. You can install Homebrew by running the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installing Homebrew, you will need to install the following dependencies:

```bash
brew install eza git-delta ripgrep starship mise autojump prezto 1password trunk
```

## Usage

To use these dotfiles, you can clone this repository and then run the `setup.sh` script. This script will create symbolic links to the dotfiles in your home directory.

```bash
git clone https://github.com/your-username/dotfiles.git
cd dotfiles
./setup.sh
```

After running the `setup.sh` script, you may need to restart your terminal or other applications for the changes to take effect.

## Contents

This repository contains the following dotfiles:

- `.editorconfig`: Configuration file for EditorConfig.
- `.gitignore`: Configuration file for Git.
- `config/`: Directory containing configuration files for various applications.
     - `git/`: Directory containing Git configuration files.
     - `kanata/`: Directory containing Kanata configuration files.
     - `zsh/`: Directory containing Zsh configuration files.
- `setup.sh`: Script to set up the dotfiles.
- `starship.toml`: Configuration file for Starship.

## License

This repository is licensed under the MIT License.
