#!/usr/bin/env zsh
# ---
# Environment variables configuration
# This file will be symlinked to ~/.zshenv
# Loaded before .zshrc, suitable for PATH and essential environment setup
# ---

# Add ~/bin to PATH
export PATH="$HOME/bin:$PATH"

# Homebrew prefix detection
# Fast path: common install locations
# Fallback: query `brew --prefix` for non-standard installs
if [[ -d "/opt/homebrew" ]]; then
  # Apple Silicon
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  # Intel Mac
  export HOMEBREW_PREFIX="/usr/local"
  export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
elif command -v brew >/dev/null 2>&1; then
  _brew_prefix="$(brew --prefix 2>/dev/null)"
  if [[ -n "$_brew_prefix" && -d "$_brew_prefix" ]]; then
    export HOMEBREW_PREFIX="$_brew_prefix"
    if [[ -d "${HOMEBREW_PREFIX}/Homebrew" ]]; then
      export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
    else
      export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
    fi
  fi
  unset _brew_prefix
fi

if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
  export PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:$PATH"
  export MANPATH="${HOMEBREW_PREFIX}/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}"
fi

# iTerm2 shell integration
[ -f "$HOME/.iterm2_shell_integration.zsh" ] && source "$HOME/.iterm2_shell_integration.zsh"

# Golang
if command -v go >/dev/null 2>&1; then
  : "${GOPATH:=$(go env GOPATH)}"
  export PATH="$PATH:$GOPATH/bin"
fi

# JetBrains Toolbox
export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"

# ghq
export GHQ_ROOT="$HOME/code"

# Docker (for Apple Silicon)
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Projects root
export PJ_ROOT="$HOME/Documents/Projects"

# Editor
export EDITOR='vim'

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Less/Man pager
export LESS_TERMCAP_md="${yellow:-}"
export MANPAGER='less -X'

# GPG
export GPG_TTY=$(tty)
