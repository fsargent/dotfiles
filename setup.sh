#!/bin/sh
# Enable shell script strictness
set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create symlink with feedback
link_config() {
    local src=$1
    local dest=$2
    local name=$3

    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
            # It's already a symlink
            current_target=$(readlink "$dest")
            if [ "$current_target" = "$src" ]; then
                printf "${GREEN}✓${NC} $name already linked correctly\n"
                return 0
            else
                printf "${YELLOW}⚠${NC} $name symlink points to wrong target\n"
                printf "  Current: $current_target\n"
                printf "  Expected: $src\n"
                return 1
            fi
        else
            # File/dir exists but is NOT a symlink
            printf "${RED}✗${NC} $name exists but is NOT a symlink\n"
            printf "  Location: $dest\n"
            printf "  This file/directory needs to be removed or moved to proceed\n"
            return 1
        fi
    else
        # Doesn't exist, create the symlink
        if ln -s "$src" "$dest"; then
            printf "${GREEN}✓${NC} $name linked successfully\n"
            return 0
        else
            printf "${RED}✗${NC} Failed to create symlink for $name\n"
            return 1
        fi
    fi
}

# Ensure config directory exists
mkdir -p ~/.config

printf "\n${YELLOW}Setting up dotfiles symlinks...${NC}\n\n"

# Track failures
failed=0

# Link configurations
link_config "${PWD}/config/git" ~/.config/git "Git config" || failed=$((failed + 1))
link_config "${PWD}/config/zsh" ~/.config/zsh "Zsh config" || failed=$((failed + 1))
link_config "${PWD}/config/kanata" ~/.config/kanata "Kanata config" || failed=$((failed + 1))
link_config "${PWD}/config/nvim" ~/.config/nvim "Neovim config" || failed=$((failed + 1))
link_config "${PWD}/config/helix" ~/.config/helix "Helix config" || failed=$((failed + 1))
link_config "${PWD}/starship.toml" ~/.config/starship.toml "Starship config" || failed=$((failed + 1))
link_config "${PWD}/config/zsh/.zshrc" ~/.zshrc ".zshrc" || failed=$((failed + 1))
link_config "${PWD}/config/zsh/.zshenv" ~/.zshenv ".zshenv" || failed=$((failed + 1))

# Report results
printf "\n"
if [ $failed -eq 0 ]; then
    printf "${GREEN}✓ All symlinks set up successfully!${NC}\n"
    exit 0
else
    printf "${RED}✗ Setup completed with $failed failure(s)${NC}\n"
    printf "\nTo fix existing files that aren't symlinks:\n"
    printf "  1. Backup the file: mv ~/.config/file ~/.config/file.backup\n"
    printf "  2. Re-run this script: ./setup.sh\n"
    exit 1
fi