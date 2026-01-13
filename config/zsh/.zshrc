# ~/.zshrc - Optimized for speed (<100ms target)

[[ -o interactive ]] || return

# ------------------------------------------------------------------------------
# Core Setup
# ------------------------------------------------------------------------------

export HISTFILE=$HOME/.zhistory
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY share_history hist_expire_dups_first hist_ignore_dups hist_verify autocd

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
set -o vi
bindkey -v '^?' backward-delete-char
WORDCHARS=${WORDCHARS//[-_.\/]/}

# Aliases
[[ -f ~/.config/zsh/.aliases ]] && source ~/.config/zsh/.aliases

# PATH (interactive-only)
export PATH="/Users/fsargent/.rd/bin:/opt/homebrew/Cellar/arm-none-eabi-gcc@8/8.5.0_2/bin:/opt/homebrew/Cellar/avr-gcc@8/8.5.0_2/bin:/opt/homebrew/opt/arm-none-eabi-binutils/bin:$PATH"

export LESS="--chop-long-lines --HILITE-UNREAD --ignore-case --incsearch --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS --status-column --use-color --window=-4"

# ------------------------------------------------------------------------------
# Completions (cached)
# ------------------------------------------------------------------------------

FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
autoload -Uz compinit
# Only regenerate once per day
[[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C

# ------------------------------------------------------------------------------
# Cached tool initializations (regenerate with: zsh-regen-cache)
# ------------------------------------------------------------------------------

_zsh_cache="$HOME/.cache/zsh"
[[ -d "$_zsh_cache" ]] || mkdir -p "$_zsh_cache"

# Function to regenerate cache
zsh-regen-cache() {
    echo "Regenerating zsh cache..."
    starship init zsh > "$_zsh_cache/starship.zsh"
    fzf --zsh > "$_zsh_cache/fzf.zsh"
    direnv hook zsh > "$_zsh_cache/direnv.zsh"
    zoxide init zsh > "$_zsh_cache/zoxide.zsh"
    mise activate zsh > "$_zsh_cache/mise.zsh"
    echo "Done. Restart shell to use cached init."
}

# Source cached files (fast) or generate on first run
_source_cached() {
    local name=$1 cmd=$2
    local cache="$_zsh_cache/$name.zsh"
    if [[ ! -f "$cache" ]]; then
        eval "$cmd" > "$cache"
    fi
    source "$cache"
}

_source_cached starship "starship init zsh"
_source_cached fzf "fzf --zsh"
_source_cached direnv "direnv hook zsh"
_source_cached zoxide "zoxide init zsh"
_source_cached mise "mise activate zsh"

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

git_main_branch() {
    [[ -n "$(git branch --list main 2>/dev/null)" ]] && echo main || echo master
}

# ------------------------------------------------------------------------------
# Plugins - deferred until first prompt for faster startup
# ------------------------------------------------------------------------------

autoload -Uz add-zsh-hook
_load_plugins() {
    [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
        source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
        source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    add-zsh-hook -d precmd _load_plugins
}
add-zsh-hook precmd _load_plugins

# ------------------------------------------------------------------------------
# FZF Config
# ------------------------------------------------------------------------------

export FZF_DEFAULT_OPTS="--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }

_show_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$_show_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
    local command=$1; shift
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \${}'" "$@" ;;
        ssh)          fzf --preview 'dig {}' "$@" ;;
        *)            fzf --preview "$_show_preview" "$@" ;;
    esac
}

# ------------------------------------------------------------------------------
# Lazy-loaded tools
# ------------------------------------------------------------------------------

fk() { unfunction fk; eval $(thefuck --alias fk); fk "$@"; }
j() { unfunction j; [[ -f /opt/homebrew/etc/profile.d/autojump.sh ]] && . /opt/homebrew/etc/profile.d/autojump.sh; j "$@"; }
op() { unfunction op; [[ -f "$HOME/.config/op/plugins.sh" ]] && source "$HOME/.config/op/plugins.sh"; op "$@"; }

# ------------------------------------------------------------------------------
# Final setup
# ------------------------------------------------------------------------------

alias cd='z'

# Optional completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -f "$HOME/.cache/trunk/shell-hooks/zsh.rc" ]] && source "$HOME/.cache/trunk/shell-hooks/zsh.rc"
