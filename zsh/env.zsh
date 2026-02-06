#!/usr/bin/env zsh
# ---
# Environment variables configuration
# This file will be symlinked to ~/.zshenv
# Loaded before .zshrc, suitable for PATH and essential environment setup
# ---

# Add ~/bin to PATH
export PATH="$HOME/bin:$PATH"

# Homebrew (hardcoded for performance - avoid $(brew --prefix))
if [[ -d "/opt/homebrew" ]]; then
  # Apple Silicon
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
elif [[ -d "/usr/local/Homebrew" ]]; then
  # Intel Mac
  export HOMEBREW_PREFIX="/usr/local"
  export HOMEBREW_CELLAR="/usr/local/Cellar"
  export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
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
