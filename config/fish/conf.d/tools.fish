# Tool initializations for Fish shell

# ------------------------------------------------------------------------------
# Mise (version manager)
# ------------------------------------------------------------------------------

if command -v mise >/dev/null 2>&1
    mise activate fish | source
end

# ------------------------------------------------------------------------------
# Starship Prompt
# ------------------------------------------------------------------------------

if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# ------------------------------------------------------------------------------
# Zoxide (smart directory jumper)
# ------------------------------------------------------------------------------

if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
    # Use zoxide's z as the cd command
    alias cd='z'
end

# ------------------------------------------------------------------------------
# FZF (Fuzzy Finder)
# ------------------------------------------------------------------------------

if command -v fzf >/dev/null 2>&1
    # FZF Theme
    set -gx FZF_DEFAULT_OPTS "--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"

    # FZF Use fd for faster searching
    set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    # FZF fd integration for completion
    function _fzf_compgen_path
        fd --hidden --exclude .git . "$argv[1]"
    end

    function _fzf_compgen_dir
        fd --type=d --hidden --exclude .git . "$argv[1]"
    end

    # FZF Preview settings using eza and bat
    set -gx show_file_or_dir_preview "if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
    set -gx FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

    # FZF key bindings for fish
    fzf --fish | source
end

# ------------------------------------------------------------------------------
# Autojump (Directory jumper based on frequency/recency)
# ------------------------------------------------------------------------------

if test -f /opt/homebrew/etc/profile.d/autojump.fish
    source /opt/homebrew/etc/profile.d/autojump.fish
end

# ------------------------------------------------------------------------------
# TheFuck (Command line corrector)
# ------------------------------------------------------------------------------

if command -v thefuck >/dev/null 2>&1
    thefuck --alias | source
    thefuck --alias fk | source
end

# ------------------------------------------------------------------------------
# OP CLI Plugin
# ------------------------------------------------------------------------------
# Note: OP plugins.sh is bash/zsh specific, but we can extract aliases from it
if test -f ~/.config/op/plugins.sh
    begin
        # Set the environment variable that OP uses
        set -gx OP_PLUGIN_ALIASES_SOURCED 1
        # Extract and set aliases from the bash script
        # The plugins.sh file contains: alias circleci="op plugin run -- circleci"
        # We'll parse it and create fish aliases silently
        grep "^alias " ~/.config/op/plugins.sh 2>/dev/null | while read -r line
            set -l alias_match (string match -r 'alias ([^=]+)="(.+)"' "$line")
            if test (count $alias_match) -eq 3
                alias $alias_match[2]="$alias_match[3]"
            end
        end
    end >/dev/null 2>&1
end

# ------------------------------------------------------------------------------
# Bun completions
# ------------------------------------------------------------------------------
# Note: Bun's _bun file is bash/zsh specific and not compatible with fish
# Bun works fine in fish without shell-specific completions
# Fish has its own completion system that works with bun commands

# ------------------------------------------------------------------------------
# Trunk shell hooks
# ------------------------------------------------------------------------------

if test -f ~/.cache/trunk/shell-hooks/fish.rc
    source ~/.cache/trunk/shell-hooks/fish.rc
end

