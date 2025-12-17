# ~/.config/fish/config.fish
# Main Fish shell configuration file

# ------------------------------------------------------------------------------
# PATH Setup
# ------------------------------------------------------------------------------

# Add Homebrew paths
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path ~/.local/bin

# PNPM
set -gx PNPM_HOME ~/Library/pnpm
fish_add_path $PNPM_HOME

# ------------------------------------------------------------------------------
# NPM Configuration
# ------------------------------------------------------------------------------

# Ensure npm uses the correct registry
set -gx npm_config_registry https://registry.npmjs.org/

# Set NPM_TOKEN from user's .npmrc if not already set (for project .npmrc files that use ${NPM_TOKEN})
if test -z "$NPM_TOKEN" && test -f ~/.npmrc
    set -l token (grep "^//registry.npmjs.org/:_authToken=" ~/.npmrc 2>/dev/null | cut -d= -f2)
    if test -n "$token"
        set -gx NPM_TOKEN "$token"
    end
end

# Function to verify npm authentication is working
function npm_auth_check
    if command -v npm >/dev/null 2>&1
        # Ensure registry is set correctly
        npm config set registry https://registry.npmjs.org/ >/dev/null 2>&1

        # Verify authentication works
        if not npm whoami >/dev/null 2>&1
            printf "\n⚠ npm authentication issue detected\n"
            printf "Run 'npm login' to authenticate\n"
        end
    end
end

# Check npm auth on shell startup (only if .npmrc exists with a token)
if test -f ~/.npmrc && grep -q "_authToken" ~/.npmrc
    npm_auth_check >/dev/null 2>&1
end

# Managed tool paths
fish_add_path ~/.rd/bin
fish_add_path /opt/homebrew/Cellar/arm-none-eabi-gcc@8/8.5.0_2/bin
fish_add_path /opt/homebrew/Cellar/avr-gcc@8/8.5.0_2/bin
fish_add_path /opt/homebrew/opt/arm-none-eabi-binutils/bin

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------

set -gx XDG_CONFIG_HOME ~/.config
set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgreprc
set -gx BAT_THEME tokyonight_night
set -gx TRUNK_TELEMETRY OFF
set -gx _ZO_DOCTOR 0

# LESS configuration
set -gx LESS "--chop-long-lines --HILITE-UNREAD --ignore-case --incsearch --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS --status-column --use-color --window=-4"

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------

set -gx fish_history_limit 1000

# ------------------------------------------------------------------------------
# Disable Fish Welcome Message (MOTD)
# ------------------------------------------------------------------------------

set -gx fish_greeting ""

# ------------------------------------------------------------------------------
# Fish Color Theme Configuration
# ------------------------------------------------------------------------------

# Fish uses Starship for the prompt (configured in starship.toml with catppuccin_mocha)
# But we can configure fish's built-in syntax highlighting colors to match

# Syntax highlighting colors (matches catppuccin_mocha theme)
set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_param cdd6f4
set -g fish_color_keyword f38ba8
set -g fish_color_quote a6e3a1
set -g fish_color_redirection f9e2af
set -g fish_color_end f38ba8
set -g fish_color_error f38ba8
set -g fish_color_gray 6c7086
set -g fish_color_selection --background=313244
set -g fish_color_search_match --background=313244
set -g fish_color_operator f9e2af
set -g fish_color_escape cba6f7
set -g fish_color_autosuggestion 6c7086
set -g fish_color_cwd a6e3a1
set -g fish_color_user 89b4fa
set -g fish_color_host 89b4fa
set -g fish_color_host_remote f9e2af
set -g fish_color_status f38ba8
set -g fish_color_comment 6c7086
set -g fish_color_match cba6f7
set -g fish_color_valid_path --underline

# Pager colors (for man pages, etc.)
set -g fish_pager_color_progress 6c7086
set -g fish_pager_color_background
set -g fish_pager_color_prefix cba6f7
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_selected_background --background=313244
set -g fish_pager_color_selected_prefix cba6f7
set -g fish_pager_color_selected_completion cdd6f4
set -g fish_pager_color_selected_description 6c7086
set -g fish_pager_color_secondary_background
set -g fish_pager_color_secondary_prefix cba6f7
set -g fish_pager_color_secondary_completion
set -g fish_pager_color_secondary_description

# ------------------------------------------------------------------------------
# Load .env files for test environment variables
# ------------------------------------------------------------------------------

# Load .env from the registry project directory if it exists
if test -f ~/src/snyk/registry/.env
    begin
        while read -r line || test -n "$line"
            # Skip comments and empty lines
            if string match -qr '^\s*#' "$line"; or test -z "$line"
                continue
            end

            # Parse KEY=value format using string split
            set -l parts (string split -m 1 = "$line")
            if test (count $parts) -eq 2
                set -l key (string trim $parts[1])
                set -l value (string trim $parts[2])
                # Remove quotes if present
                set value (string replace -r '^["\047](.*)["\047]$' '$1' "$value")
                # Set environment variable silently
                set -gx $key $value
            end
        end < ~/src/snyk/registry/.env
    end >/dev/null 2>&1
end

# ------------------------------------------------------------------------------
# Source additional configuration files
# ------------------------------------------------------------------------------

# Source aliases
if test -f $__fish_config_dir/conf.d/aliases.fish
    source $__fish_config_dir/conf.d/aliases.fish
end

# Source tools configuration
if test -f $__fish_config_dir/conf.d/tools.fish
    source $__fish_config_dir/conf.d/tools.fish
end


# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
