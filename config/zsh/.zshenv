# ~/.config/zsh/.zshenv
# This file is sourced by ALL zsh shells (interactive, non-interactive, login, non-login)
# It contains essential tool initializations needed for non-interactive environments

# ------------------------------------------------------------------------------
# ZDOTDIR Configuration (MUST be first)
# ------------------------------------------------------------------------------

export ZDOTDIR=~/.config/zsh

# ------------------------------------------------------------------------------
# Essential PATH Setup (non-interactive shells need this)
# ------------------------------------------------------------------------------

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/Users/fsargent/.local/bin:$PATH"
export PNPM_HOME="/Users/fsargent/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# ------------------------------------------------------------------------------
# Essential Environment Variables (needed for non-interactive shells)
# ------------------------------------------------------------------------------

export XDG_CONFIG_HOME="$HOME/.config/"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export BAT_THEME=tokyonight_night
export TRUNK_TELEMETRY=OFF
export _ZO_DOCTOR=0

# ------------------------------------------------------------------------------
# Mise - Initialize for all shells (needed for PATH in non-interactive shells)
# ------------------------------------------------------------------------------

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)" 2>/dev/null || true
fi


# Mise - Initialize for all shells (needed for version management)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# ------------------------------------------------------------------------------
# Load .env files for test environment variables
# This loads .env from the registry project directory
# ------------------------------------------------------------------------------

load_env_file() {
    local env_file="$1"
    if [[ -f "$env_file" ]]; then
        # Read .env file and export variables (handles quoted values)
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue

            # Export the variable (handles KEY="value" and KEY=value formats)
            if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
                local key="${match[1]// /}"
                local value="${match[2]}"
                # Remove quotes if present
                value="${value#\"}"
                value="${value%\"}"
                value="${value#\'}"
                value="${value%\'}"
                export "$key=$value"
            fi
        done < "$env_file"
    fi
}

# Load .env from the registry project directory if it exists
if [[ -f "$HOME/src/snyk/registry/.env" ]]; then
    load_env_file "$HOME/src/snyk/registry/.env"
fi
