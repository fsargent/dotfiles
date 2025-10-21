# ~/.zshrc

# Only load interactive features for interactive shells
# This ensures non-interactive shells (like Cursor agents) work correctly
[[ -o interactive ]] || return

# ------------------------------------------------------------------------------
# Core Zsh Setup
# ------------------------------------------------------------------------------

# History configuration
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history        # Share history between sessions
setopt hist_expire_dups_first # Expire duplicate entries first
setopt hist_ignore_dups     # Don't record dupes in history
setopt hist_verify          # Show command with history expansion before running

# Keybindings for history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Source custom aliases if it exists
[[ -f ~/.config/zsh/.aliases ]] && source ~/.config/zsh/.aliases

# ------------------------------------------------------------------------------
# PATH Setup (deduplicate from .zshenv)
# ------------------------------------------------------------------------------

# Only add to PATH if not already present (avoid duplicates)
[[ ":$PATH:" == *":/opt/homebrew/bin:"* ]] || export PATH="/opt/homebrew/bin:$PATH"
[[ ":$PATH:" == *":/opt/homebrew/sbin:"* ]] || export PATH="/opt/homebrew/sbin:$PATH"
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"

# Add managed tool paths
export PATH="/Users/fsargent/.rd/bin:$PATH"
export PATH="/opt/homebrew/Cellar/arm-none-eabi-gcc@8/8.5.0_2/bin:/opt/homebrew/Cellar/avr-gcc@8/8.5.0_2/bin:$PATH"
export PATH="/opt/homebrew/opt/arm-none-eabi-binutils/bin:$PATH"

# Environment variables
export LESS="\
--chop-long-lines \
--HILITE-UNREAD \
--ignore-case \
--incsearch \
--jump-target=4 \
--LONG-PROMPT \
--no-init \
--quit-if-one-screen \
--RAW-CONTROL-CHARS \
--status-column \
--use-color \
--window=-4"

# ------------------------------------------------------------------------------
# Antidote Plugin Manager
# ------------------------------------------------------------------------------

# Initialize completion system first (required by plugins for compdef)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
    compinit
else
    compinit -C
fi

# Add Homebrew completions to fpath
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Source antidote and initialize dynamic plugin loading (silently)
{
    source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
    antidote init
    # Load plugins specified in .zsh_plugins.txt
    [[ -f ~/.config/zsh/.zsh_plugins.txt ]] && antidote load ~/.config/zsh/.zsh_plugins.txt
} &> /dev/null

# ------------------------------------------------------------------------------
# Tool Initializations (Starship, FZF, etc.) - Deferred for speed
# ------------------------------------------------------------------------------

# Use a simple prompt initially, then load Starship after first prompt
# This dramatically improves first_prompt_lag_ms
if [[ -z "$STARSHIP_INIT" ]]; then
    export STARSHIP_INIT=1
    # Use basic prompt initially
    PS1='%~$ '
fi

# Defer Starship initialization
starship_init() {
    eval "$(starship init zsh)" 2>/dev/null
    unfunction starship_init
}

# Initialize Starship on first command if not already done
precmd_functions+=(starship_init)

# FZF (Fuzzy Finder) - deferred initialization
fzf_init() {
    eval "$(fzf --zsh)" 2>/dev/null || return

    # FZF Theme
    fg="#CBE0F0"
    bg="#011628"
    bg_highlight="#143652"
    purple="#B388FF"
    blue="#06BCE4"
    cyan="#2CF9ED"
    export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

    # FZF Use fd for faster searching
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    # FZF fd integration for completion
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }
    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }

    # FZF Preview settings using eza and bat
    show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

    # FZF Advanced customization for specific commands
    _fzf_comprun() {
      local command=$1
      shift
      case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
        ssh)          fzf --preview 'dig {}'                   "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
      esac
    }

    # Remove this function after first call
    unfunction fzf_init
}

# Load FZF on first command
precmd_functions+=(fzf_init)

# Pre-set FZF environment variables (these are cheap and don't require fzf)
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# OP CLI Plugin - deferred initialization
op_init() {
    [[ -f "/Users/fsargent/.config/op/plugins.sh" ]] && source "/Users/fsargent/.config/op/plugins.sh"
    unfunction op_init
}
precmd_functions+=(op_init)

# TheFuck (Command line corrector) - deferred initialization
# Only initialize when first used to save startup time
thefuck_init() {
    eval $(thefuck --alias) 2>/dev/null
    eval $(thefuck --alias fk) 2>/dev/null
    unfunction thefuck_init
}
alias fk='thefuck_init; fk'

# Autojump (Directory jumper based on frequency/recency)
if [ -f /opt/homebrew/etc/profile.d/autojump.sh ]; then
    # Defer autojump loading
    autojump_init() {
        . /opt/homebrew/etc/profile.d/autojump.sh
        unfunction autojump_init
    }
    alias j='autojump_init; j'
fi

# ------------------------------------------------------------------------------
# Custom Functions
# ------------------------------------------------------------------------------

# Function to determine the default git branch name
git_main_branch() {
  if [[ -n "$(git branch --list main)" ]]; then
    echo main
  else
    echo master
  fi
}