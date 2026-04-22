# ~/.config/zsh/.zshenv
# Sourced by ALL zsh shells - keep MINIMAL

export ZDOTDIR=~/.config/zsh

# Essential PATH - mise shims FIRST to override homebrew versions
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$PATH"
export PNPM_HOME="/Users/fsargent/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# Essential env vars
export XDG_CONFIG_HOME="$HOME/.config"
# Ripgrep errors if RIPGREP_CONFIG_PATH points at a missing file; only set when present.
[[ -f "$XDG_CONFIG_HOME/ripgreprc" ]] && export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export BAT_THEME="Catppuccin Latte"
export TRUNK_TELEMETRY=OFF
export _ZO_DOCTOR=0

# Lazy GitHub token
github_token() {
    [[ -z "$GITHUB_PRIVATE_TOKEN" ]] && export GITHUB_PRIVATE_TOKEN="$(security find-generic-password -a "$USER" -s "GitHub Token" -w 2>/dev/null)"
    echo "$GITHUB_PRIVATE_TOKEN"
}
export SNYK_INTERNAL_PROXY_CREDENTIALS='snyk-internal:xxxxxxxxxx'
export SNYK_INTERNAL_BROKER_CREDENTIALS='snyk-services-user:xxxxxxxxxx'
export SNYK_INTERNAL_PROXY_HOST='proxy.pre-prod-1.eu-west-1.polaris-pre-prod.snyk-internal.net'

# Anthropic / Claude setup
# Set the internal proxy URL
export ANTHROPIC_BASE_URL=https://llm-proxy.c-a.eu-west-1.polaris-prod-bo-dr3d3-1.aws.snyk-internal.net

# Disable experimental betas - required for our setup
CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
