# Fish aliases

# ------------------------------------------------------------------------------
# Git aliases
# ------------------------------------------------------------------------------

# Basic git aliases
alias g='git'
alias amend='git commit --amend'
alias pull='git pull'
alias gl='git pull'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gd='git diff'
alias gcm='git checkout main'
alias grhh='git reset --hard HEAD'
alias gs='git status'
alias gst='git status'
alias gss='git status -s'
alias gsb='git status -sb'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias gopen='gh pr view --web'

# Git branch aliases
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
# gbda needs to be a function due to complex regex with $ that fish interprets as variable
function gbda
    git branch --no-color --merged | command grep -vE '^(\*|\s*(master|develop|dev)\s*\$)' | command xargs -n 1 git branch -d
end
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

# Git bisect aliases
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

# Git commit aliases
alias gc='git commit -v'
alias 'gc!'='git commit -v --amend'
alias gca='git commit -v -a'
alias 'gca!'='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias 'gcan!'='git commit -v -a --no-edit --amend'
alias 'gcans!'='git commit -v -a -s --no-edit --amend'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gcl='git clone --recursive'
alias gclean='git clean -fd'
alias gcmsg='git commit -m'
alias 'gcn!'='git commit -v --no-edit --amend'
alias gco='git checkout'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit -S'
alias gcsm='git commit -s -m'

# Git diff aliases
alias gdca='git diff --cached'
alias gdct='git describe --tags (git rev-list --tags --max-count=1)'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdw='git diff --word-diff'

# Git fetch aliases
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# Git GUI aliases
alias gg='git gui citool'
alias gga='git gui citool --amend'

# Git pull/push aliases (using git_current_branch function)
alias ggpull='git pull origin (git_current_branch)'
alias ggpush='git push origin (git_current_branch)'
alias ggsup='git branch --set-upstream-to=origin/(git_current_branch)'

# Git help and ignore aliases
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
alias gk='\gitk --all --branches'
alias gke='\gitk --all (git log -g --pretty=%h)'

# Git log aliases
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --all'
alias glum='git pull upstream master'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'

# Git merge aliases
alias gm='git merge'
alias gmom='git merge origin/master'
alias gmt='git mergetool --no-prompt'
alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/master'

# Git push aliases
alias gp='git push'
alias gpd='git push --dry-run'
alias gpoat='git push origin --all && git push origin --tags'
alias gpristine='git reset --hard && git clean -dfx'
alias gpsup='git push --set-upstream origin (git_current_branch)'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gpfwl='git push --force-with-lease'

# Git remote aliases
alias gr='git remote'
alias gra='git remote add'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grt='cd (git rev-parse --show-toplevel 2>/dev/null; or echo ".")'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'

# Git rebase aliases
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbs='git rebase --skip'

# Git reset aliases
alias grh='git reset HEAD'

# Git stash aliases
alias gsta='git stash save'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'

# Git submodule aliases
alias gsi='git submodule init'
alias gsu='git submodule update'

# Git show and svn aliases
alias gsps='git show --pretty=short --show-signature'
alias gsd='git svn dcommit'
alias gsr='git svn rebase'

# Git tag aliases
alias gts='git tag -s'
alias gtv='git tag | sort -V'

# Git utility aliases
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm (git ls-files --deleted) 2>/dev/null; git commit --no-verify -m "--wip-- [skip ci]"'

# ------------------------------------------------------------------------------
# File operations
# ------------------------------------------------------------------------------

alias cat='bat'
alias ls='eza --icons=always'
alias la='ls -a'
alias ll='ls -al'
alias size='du -hs ./* | sort -hr'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

# ------------------------------------------------------------------------------
# Editor aliases
# ------------------------------------------------------------------------------

alias vim='hx'
alias helix='hx'
alias zshedit='hx ~/.config/fish/config.fish'
alias fisheedit='hx ~/.config/fish/config.fish'
alias reload='source ~/.config/fish/config.fish'

# ------------------------------------------------------------------------------
# Navigation
# ------------------------------------------------------------------------------

alias rb='cd ~/src/rb'
alias ...='cd ../..'
alias ....='cd ../../..'

# ------------------------------------------------------------------------------
# Tools
# ------------------------------------------------------------------------------

alias '??'='gh copilot suggest'
alias ka='sudo kanata -c ~/src/dotfiles/config/kanata/kanata.kbd'
