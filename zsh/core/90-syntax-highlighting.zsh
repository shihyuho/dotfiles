#!/usr/bin/env zsh
# ---
# Zsh syntax highlighting
# Must be loaded after all other configurations
# ---

# Only load if available
if [[ -f "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
