# Dotfiles

This repository contains my dotfiles, which are configuration files for various applications and tools that I use.

## Prerequisites

Before using these dotfiles, you will need to install Homebrew. You can install Homebrew by running the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installing Homebrew, you will need to install the following dependencies:

```bash
brew install eza git-delta ripgrep starship mise autojump 1password trunk fish
```

### Shell Configuration

This repository supports both Zsh and Fish shells. Fish is recommended for better performance and reliability.

**To use Fish shell:**
1. Install fish: `brew install fish`
2. Add fish to `/etc/shells`: `echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells`
3. Set fish as your default shell: `chsh -s /opt/homebrew/bin/fish`
4. Run the setup script: `./setup.sh`

## Usage

To use these dotfiles, you can clone this repository and then run the `setup.sh` script. This script will create symbolic links to the dotfiles in your home directory.

```bash
git clone https://github.com/your-username/dotfiles.git
cd dotfiles
./setup.sh
```

After running the `setup.sh` script, you may need to restart your terminal or other applications for the changes to take effect.

## Favuorite Apps (non terminal)

- Raycast
- Superwhisper
- Homerow
- Setapp
  - In Your Face
  - Bartender
  - Cleanshot X
  - Soulver Calculator

## Homebrew Casks

- 1password-cli
- adguard-vpn
- cursor
- discord
- font-fira-code-nerd-font
- font-geist-mono
- font-geist-mono-nerd-font
- font-jetbrains-mono-nerd-font
- font-meslo-lg-nerd-font
- font-monaspace
- gcloud-cli
- ghostty
- keycastr
- raycast
- setapp
- spotify
- steam
- tailscale
- visual-studio-code
- warp

### Chrome

## Contents

This repository contains the following dotfiles:

- `.editorconfig`: Configuration file for EditorConfig.
- `.gitignore`: Configuration file for Git.
- `config/`: Directory containing configuration files for various applications.
     - `git/`: Directory containing Git configuration files.
     - `kanata/`: Directory containing Kanata configuration files.
     - `zsh/`: Directory containing Zsh configuration files.
     - `fish/`: Directory containing Fish shell configuration files.
- `setup.sh`: Script to set up the dotfiles.
- `starship.toml`: Configuration file for Starship.

## License

This repository is licensed under the MIT License.
