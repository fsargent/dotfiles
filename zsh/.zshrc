# Fig pre block. Keep at the top of this file.
source ~/.config/zsh/.aliases
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Fig pre block. Keep at the top of this file.
#zmodload zsh/zprof # top of your .zshrc file
#set -x

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh  
export PATH="/opt/homebrew/bin/:$PATH"
export TRUNK_TELEMETRY=OFF

zstyle ':prezto:load' pmodule 'environment' 'terminal'  'history' 'homebrew' 'Node'

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
eval "$(starship init zsh)"
eval "$(github-copilot-cli alias -- "$0")"

function add-alias() {
  alias $1="$2"
  echo "alias $1='$2'" >> ~/.zshrc
}


# export OPENAI_API_KEY=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


export SDKMAN_DIR="$HOME/.sdkman"
#export PATH="$PATH:~/.fig/bin"


# # do this instead:
sdk () {
    # "metaprogramming" lol - source init if sdk currently looks like this sdk function
    if [[ "$(which sdk | wc -l)" -le 10 ]]; then
        unset -f sdk
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    fi
    sdk "$@"
}

git_main_branch() {
  if [[ -n "$(git branch --list main)" ]]; then
    echo main
  else
    echo master
  fi
}


#zprof

# bun completions
[ -s "/Users/felixsargent/.bun/_bun" ] && source "/Users/felixsargent/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
