source ~/.config/zsh/.aliases

export PATH="/opt/homebrew/bin/:$PATH"
export TRUNK_TELEMETRY=OFF

zstyle ':prezto:load' pmodule 'environment' 'terminal'  'history' 'homebrew' 'Node'

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
eval "$(starship init zsh)"
eval "$(mise activate zsh)"

git_main_branch() {
  if [[ -n "$(git branch --list main)" ]]; then
    echo main
  else
    echo master
  fi
}

if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    # compinit # Oh My Zsh handles this
fi

# Less
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

export RIPGREP_CONFIG_PATH=~/.config/ripgreprc

# zsh
export ZSH="$HOME/.config/oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"
plugins=(
  git # https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/README.md
  you-should-use # https://github.com/MichaelAquilina/zsh-you-should-use
)
source $ZSH/oh-my-zsh.sh

export YSU_MESSAGE_FORMAT="$(tput setaf 1)Hey! I found this %alias_type for %command: %alias$(tput sgr0)"
source /Users/fsargent/.config/op/plugins.sh
export XDG_CONFIG_HOME="$HOME/.config/"

eval "$(jump shell)"

export PATH="/opt/homebrew/sbin:$PATH"

# pnpm
export PNPM_HOME="/Users/fsargent/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
