#!/usr/bin/env zsh
# ---
# Tool: kubectl
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: Kubernetes CLI shortcuts
# Updated: 2026-02-06
# ---

# Load kubectl aliases
[ -f "$HOME/.kubectl_aliases" ] && source "$HOME/.kubectl_aliases"

# Use GNU watch instead of kubectl [...] --watch
[ -f "$HOME/.kubectl_aliases" ] && source \
   <(cat ~/.kubectl_aliases | sed -r 's/(kubectl.*) --watch/watch \1/g')

# kubectl-jqlogs
alias klo='kubectl jqlogs -f'
