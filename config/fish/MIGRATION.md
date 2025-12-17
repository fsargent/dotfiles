# Fish Shell Migration Guide

This guide will help you migrate from Zsh to Fish shell.

## Installation

1. Install Fish:
```bash
brew install fish
```

2. Add Fish to `/etc/shells`:
```bash
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
```

3. Set Fish as your default shell:
```bash
chsh -s /opt/homebrew/bin/fish
```

4. Run the setup script to link Fish configuration:
```bash
cd ~/src/dotfiles
./setup.sh
```

5. Start a new terminal session or run:
```bash
fish
```

## What's Been Migrated

### Configuration Files
- ✅ PATH setup (Homebrew, local bin, tool paths)
- ✅ Environment variables (XDG_CONFIG_HOME, BAT_THEME, etc.)
- ✅ History configuration
- ✅ .env file loading from registry project

### Aliases
All aliases from `.zshrc` have been migrated:
- Git aliases (amend, pull, ga, gd, gcm, etc.)
- File operations (cat→bat, ls→eza)
- Editor aliases (vim→hx, helix→hx)
- Navigation aliases

### Custom Functions
- ✅ `killport` - Kill processes on specific ports or port ranges
- ✅ `gci` - Git checkout interactive with mise
- ✅ `git_main_branch` - Determine default git branch

### Tool Integrations
- ✅ Mise (version manager)
- ✅ Starship prompt
- ✅ Zoxide (smart directory navigation)
- ✅ FZF (fuzzy finder) with key bindings
- ✅ Autojump
- ✅ TheFuck
- ✅ OP CLI
- ✅ Bun completions
- ✅ Trunk shell hooks

## Key Differences from Zsh

1. **No deferred initialization needed** - Fish is fast enough that all tools initialize immediately
2. **Syntax differences**:
   - Use `set -gx VAR value` instead of `export VAR=value`
   - Use `fish_add_path` for PATH additions
   - Functions use `function name; ...; end` syntax
   - Use `test` instead of `[` for conditionals
3. **History**: Fish stores history in `~/.local/share/fish/fish_history`
4. **Completions**: Fish has built-in tab completion - no need for separate completion systems

## Troubleshooting

### Starship Timeout Issues
If you still see git command timeouts with Starship, you can increase the timeout in `starship.toml`:
```toml
command_timeout = 2000  # Increase from 1000ms
```

### Poetry Virtual Environment Activation
Fish uses a different syntax for activating virtual environments:
```fish
source /Users/fsargent/Library/Caches/pypoetry/virtualenvs/approval-frame-gV_t6VH4-py3.13/bin/activate.fish
```

Note: Fish uses `.fish` extension for activation scripts, not `.sh` or `.zsh`.

### Switching Back to Zsh
If you need to temporarily use Zsh:
```bash
zsh
```

To switch back permanently:
```bash
chsh -s /bin/zsh
```

