# Fig pre block. Keep at the top of this file.
source ~/.config/zsh/.aliases
# Fig pre block. Keep at the top of this file.
#zmodload zsh/zprof # top of your .zshrc file
#set -x

# export ZSH="$HOME/.oh-my-zsh"
# source $ZSH/oh-my-zsh.sh
export PATH="/opt/homebrew/bin/:$PATH"
export TRUNK_TELEMETRY=OFF

zstyle ':prezto:load' pmodule 'environment' 'terminal'  'history' 'homebrew' 'Node'

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
eval "$(starship init zsh)"

function add-alias() {
  alias $1="$2"
  echo "alias $1='$2'" >> ~/.zshrc
}


git_main_branch() {
  if [[ -n "$(git branch --list main)" ]]; then
    echo main
  else
    echo master
  fi
}

eval "$(mise activate zsh)"
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi
