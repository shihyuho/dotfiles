#!/usr/bin/env zsh
# ---
# Navigation aliases
# Updated: 2026-03-02
# ---

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Common directories
alias dl="cd $HOME/Downloads"
alias doc="cd $HOME/Documents"
alias cfg="cd $HOME/.config"
alias tmp="cd $HOME/tmp"

# Jump to the git repository root
cdg() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 "cdg: not in a git repository"
    return 1
  }
  cd "$root"
}
