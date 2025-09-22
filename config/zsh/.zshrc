# ~/.zshrc - Reorganized

# ------------------------------------------------------------------------------
# Initial Sourcing & Core Zsh Setup
# ------------------------------------------------------------------------------

# Source custom aliases
source ~/.config/zsh/.aliases

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

# ------------------------------------------------------------------------------
# Environment Variables & PATH Setup
# ------------------------------------------------------------------------------

# Consolidated PATH exports
# Order: Homebrew bin -> User local bin -> Homebrew sbin -> PNPM -> Original PATH
export PATH="/opt/homebrew/bin:/Users/fsargent/.local/bin:/opt/homebrew/sbin:$PATH"

# pnpm PATH setup
export PNPM_HOME="/Users/fsargent/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Other environment variables
export TRUNK_TELEMETRY=OFF
export XDG_CONFIG_HOME="$HOME/.config/"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc" # Use XDG_CONFIG_HOME
export BAT_THEME=tokyonight_night

# Less configuration
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
# Oh My Zsh Framework & Plugins
# ------------------------------------------------------------------------------

export ZSH="$HOME/.config/oh-my-zsh" # Assuming OMZ is installed here
export ZSH_CUSTOM="$ZSH/custom"

plugins=(
  git            # Git aliases and functions
  you-should-use # Suggests aliases for commands you type often
  dotenv
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Plugin configurations
export YSU_MESSAGE_FORMAT="$(tput setaf 1)Hey! I found this %alias_type for %command: %alias$(tput sgr0)"

# Load Zsh completions provided by Homebrew
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    # Initialize completions (Oh My Zsh might handle this, but explicitly is safe)
    # autoload -Uz compinit && compinit
fi
# Note: Oh My Zsh usually runs compinit. If completions break, uncomment the line above.

# Source Zsh Autosuggestions (loaded after OMZ to ensure compatibility)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Source Zsh Syntax Highlighting (loaded after OMZ)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------------------------------------------------------
# Tool Initializations & Configuration
# ------------------------------------------------------------------------------

# Starship Prompt
eval "$(starship init zsh)"

# Mise (formerly rtx)
eval "$(mise activate zsh)"

# Autojump (Directory jumper based on frequency/recency)
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# Zoxide (Smarter directory changer)
eval "$(zoxide init zsh)"
# Note: The `alias cd="z"` will be moved to .aliases

# OP CLI Plugin - source if file exists
[ -f "/Users/fsargent/.config/op/plugins.sh" ] && source "/Users/fsargent/.config/op/plugins.sh"

# TheFuck (Command line corrector)
eval $(thefuck --alias)
eval $(thefuck --alias fk) # Optional shorter alias

# FZF (Fuzzy Finder)
# ------------------
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

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

# FZF Git integration
source ~/.config/fzf-git.sh # Assuming this file exists

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

# ------------------------------------------------------------------------------
# End of ~/.zshrc
# ------------------------------------------------------------------------------

# Added by Windsurf
export PATH="/Users/fsargent/.codeium/windsurf/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/fsargent/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
export PATH="/opt/homebrew/Cellar/arm-none-eabi-gcc@8/8.5.0_2/bin:/opt/homebrew/Cellar/avr-gcc@8/8.5.0_2/bin:$PATH"
export PATH="/opt/homebrew/opt/arm-none-eabi-binutils/bin:$PATH"
