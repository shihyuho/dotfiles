#!/usr/bin/env zsh
# ---
# Main zsh configuration entry point
# This file will be symlinked to ~/.zshrc
# ---

# Source environment variables first
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/env.zsh"

# Load core modules (in numeric order)
for config in "${HOME}/code/github.com/shihyuho/dotfiles/zsh/core/"*.zsh(N); do
  source "$config"
done

# Helper function for conditional loading
_load_tool_if_exists() {
  local tool=$1 config=$2
  command -v $tool >/dev/null 2>&1 && source $config
}

# Load tool configurations (only if tool exists)
_load_tool_if_exists kubectl "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/kubectl.zsh"
_load_tool_if_exists docker "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/docker.zsh"
_load_tool_if_exists fzf "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/fzf.zsh"
_load_tool_if_exists zoxide "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/zoxide.zsh"
_load_tool_if_exists lazygit "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/lazygit.zsh"
_load_tool_if_exists ghq "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/ghq.zsh"

# Load development tools (lazy loading)
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/dev/nvm.zsh"
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/dev/pyenv.zsh"
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/dev/sdkman.zsh"
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/tools/dev/go.zsh"

# Load aliases
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/aliases/common.zsh"
source "${HOME}/code/github.com/shihyuho/dotfiles/zsh/aliases/navigation.zsh"

# Load secrets (not tracked in git)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# Antigravity
export ANTIGRAVITY_PATH=${HOME}/.antigravity/antigravity/bin
export PATH=${ANTIGRAVITY_PATH}:$PATH
