#!/usr/bin/env zsh
# ---
# PATH configuration
# Loaded first (00-) to ensure PATH is set before other modules
# ---

# Use cached BREW_PREFIX from env.zsh
: "${BREW_PREFIX:=$HOMEBREW_PREFIX}"

# Set GNU tools as default
# Exclude libtool as it affects node-sass compilation
for d in ${BREW_PREFIX}/opt/*/libexec/gnubin(N); do
  if [[ ! $d =~ "libtool" ]]; then
    export PATH=$d:$PATH
  fi
done

# Krew (kubectl plugin manager)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
