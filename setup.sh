#!/bin/sh
# Enable shell script strictness
set -eu
# Enable command tracing
set -x
# Ensure config directory exists
mkdir -p ~/.config
# Link Git config if it doesn’t exist
[ ! -e ~/.config/git ] && ln -s "${PWD}/config/git" ~/.config/git

# Link zsh config if it doesn’t exist
[ ! -e ~/.config/zsh ] && ln -s "${PWD}/config/zsh" ~/.config/zsh

# Link kanata config if it doesn't exist
[ ! -e ~/.config/kanata ] && ln -s "${PWD}/config/kanata" ~/.config/kanata

# Link nvim config if it doesn't exist
[ ! -e ~/.config/nvim ] && ln -s "${PWD}/config/nvim" ~/.config/nvim

# Link .zshrc if it doesn't exist
[ ! -e ~/.zshrc ] && ln -s "${PWD}/config/zsh/.zshrc" ~/.zshrc

# Ensure ~/.zshenv contains the correct content
ZSHENV_CONTENT='export ZDOTDIR=~/.config/zsh'
ZSHENV_FILE="${HOME}/.zshenv"

# Check if the file exists and has the correct content
if [ ! -f "${ZSHENV_FILE}" ] || ! grep -Fxq "${ZSHENV_CONTENT}" "${ZSHENV_FILE}"; then
	echo "${ZSHENV_CONTENT}" >"${ZSHENV_FILE}"
fi
