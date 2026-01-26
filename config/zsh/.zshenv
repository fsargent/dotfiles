# ~/.config/zsh/.zshenv
# Sourced by ALL zsh shells - keep MINIMAL

export ZDOTDIR=~/.config/zsh

# Essential PATH - mise shims FIRST to override homebrew versions
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"
export PNPM_HOME="/Users/fsargent/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# Essential env vars
export XDG_CONFIG_HOME="$HOME/.config/"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export BAT_THEME="Catppuccin Latte"
export TRUNK_TELEMETRY=OFF
export _ZO_DOCTOR=0

# Lazy GitHub token
github_token() {
    [[ -z "$GITHUB_PRIVATE_TOKEN" ]] && export GITHUB_PRIVATE_TOKEN="$(security find-generic-password -a "$USER" -s "GitHub Token" -w 2>/dev/null)"
    echo "$GITHUB_PRIVATE_TOKEN"
}
