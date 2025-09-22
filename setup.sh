#!/bin/sh
# Enable shell script strictness
set -eu

# Function to handle creating symlinks with confirmation and backup
create_symlink() {
    local target_path="$1"
    local source_path="$2"
    local backup_dir="${HOME}/.config/backup_$(date +%Y%m%d_%H%M%S)"
    
    # If target doesn't exist, create symlink directly
    if [ ! -e "${target_path}" ]; then
        echo "✓ Creating symlink: ${target_path}"
        ln -s "${source_path}" "${target_path}"
        return 0
    fi
    
    # If target exists but is a symlink, check where it points
    if [ -L "${target_path}" ]; then
        local current_target=$(readlink "${target_path}")
        if [ "${current_target}" = "${source_path}" ]; then
            echo "✓ ${target_path} already configured correctly"
            return 0
        else
            echo "⚠️  ${target_path} points to wrong location: ${current_target}"
        fi
    else
        echo "⚠️  ${target_path} exists but is not a symlink"
    fi
    
    # Ask for confirmation
    printf "   Fix by backing up and creating symlink? (y/n): "
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        # Create backup directory if needed
        if [ ! -d "${backup_dir}" ]; then
            mkdir -p "${backup_dir}" 2>/dev/null
        fi
        
        # Backup the existing directory/file
        local backup_path="${backup_dir}/$(basename "${target_path}")"
        mv "${target_path}" "${backup_path}" 2>/dev/null
        
        # Create the symlink
        ln -s "${source_path}" "${target_path}"
        echo "✓ Fixed: backed up to ${backup_path}"
    else
        echo "   Skipped"
    fi
}

# Ensure config directory exists
mkdir -p ~/.config

# Handle each config with our improved function
create_symlink "${HOME}/.config/git" "${PWD}/config/git"
create_symlink "${HOME}/.config/zsh" "${PWD}/config/zsh"
create_symlink "${HOME}/.config/kanata" "${PWD}/config/kanata"
create_symlink "${HOME}/.config/nvim" "${PWD}/config/nvim"
create_symlink "${HOME}/.config/helix" "${PWD}/config/helix"
create_symlink "${HOME}/.config/starship.toml" "${PWD}/starship.toml"
create_symlink "${HOME}/.zshrc" "${PWD}/config/zsh/.zshrc"

# Ensure ~/.zshenv contains the correct content
ZSHENV_CONTENT='export ZDOTDIR=~/.config/zsh'
ZSHENV_FILE="${HOME}/.zshenv"

# Check if the file exists and has the correct content
if [ ! -f "${ZSHENV_FILE}" ] || ! grep -Fxq "${ZSHENV_CONTENT}" "${ZSHENV_FILE}"; then
    # For consistency, also backup and prompt for .zshenv
    if [ -f "${ZSHENV_FILE}" ]; then
        echo "${ZSHENV_FILE} exists but doesn't contain the correct content."
        echo "Would you like to fix this the right way? (y/n)"
        read -r answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            backup_dir="${HOME}/.config/backup_$(date +%Y%m%d_%H%M%S)"
            if [ ! -d "${backup_dir}" ]; then
                mkdir -p "${backup_dir}"
                echo "Created backup directory: ${backup_dir}"
            fi
            mv "${ZSHENV_FILE}" "${backup_dir}/$(basename "${ZSHENV_FILE}")"
            echo "${ZSHENV_CONTENT}" >"${ZSHENV_FILE}"
            echo "Updated ${ZSHENV_FILE}"
        else
            echo "Skipping ${ZSHENV_FILE}"
        fi
    else
        echo "${ZSHENV_CONTENT}" >"${ZSHENV_FILE}"
        echo "Created ${ZSHENV_FILE}"
    fi
fi
