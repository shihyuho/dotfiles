#!/usr/bin/env zsh
# ---
# Main zsh configuration entry point
# This file will be symlinked to ~/.zshrc
# ---

# Resolve repository root from this file location (portable across macOS/Linux)
export DOTFILES_ROOT="${${(%):-%N}:A:h:h}"

# Source environment variables first
source "${DOTFILES_ROOT}/zsh/env.zsh"

# Load core modules (in numeric order)
for config in "${DOTFILES_ROOT}/zsh/core/"*.zsh(N); do
  source "$config"
done

# Helper function for conditional loading
_load_tool_if_exists() {
  local tool="$1" config="$2"
  command -v "$tool" >/dev/null 2>&1 && source "$config"
}

# Load tool configurations (only if tool exists)
_load_tool_if_exists kubectl "${DOTFILES_ROOT}/zsh/tools/kubectl.zsh"
_load_tool_if_exists docker "${DOTFILES_ROOT}/zsh/tools/docker.zsh"
_load_tool_if_exists fzf "${DOTFILES_ROOT}/zsh/tools/fzf.zsh"
_load_tool_if_exists zoxide "${DOTFILES_ROOT}/zsh/tools/zoxide.zsh"
_load_tool_if_exists lazygit "${DOTFILES_ROOT}/zsh/tools/lazygit.zsh"
_load_tool_if_exists ghq "${DOTFILES_ROOT}/zsh/tools/ghq.zsh"

# Load development tools (lazy loading)
source "${DOTFILES_ROOT}/zsh/tools/dev/nvm.zsh"
source "${DOTFILES_ROOT}/zsh/tools/dev/pyenv.zsh"
source "${DOTFILES_ROOT}/zsh/tools/dev/sdkman.zsh"
source "${DOTFILES_ROOT}/zsh/tools/dev/go.zsh"

# Load aliases
source "${DOTFILES_ROOT}/zsh/aliases/common.zsh"
source "${DOTFILES_ROOT}/zsh/aliases/navigation.zsh"

# Load secrets (not tracked in git)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# Antigravity
export ANTIGRAVITY_PATH=${HOME}/.antigravity/antigravity/bin
export PATH=${ANTIGRAVITY_PATH}:$PATH
