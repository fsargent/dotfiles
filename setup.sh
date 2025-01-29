#!/bin/sh
# Enable shell script strictness
set -eu
# Enable command tracing
set -x
# Ensure config directory exists
mkdir -p ~/.config
# Link Git config if it doesn’t exist
[ ! -e ~/.config/git ] && ln -s "$PWD/config/git" ~/.config/git

# Link zsh config if it doesn’t exist
[ ! -e ~/.config/zsh ] && ln -s "$PWD/config/zsh" ~/.config/zsh

# Ensure ~/.zshenv contains the correct content
ZSHENV_CONTENT='export ZDOTDIR=~/.config/zsh; [ -f $ZDOTDIR/.zshenv ] && . $ZDOTDIR/.zshenv'
ZSHENV_FILE="$HOME/.zshenv"

# Check if the file exists and has the correct content
if [ ! -f "$ZSHENV_FILE" ] || ! grep -Fxq "$ZSHENV_CONTENT" "$ZSHENV_FILE"; then
    echo "$ZSHENV_CONTENT" > "$ZSHENV_FILE"
fi