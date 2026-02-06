#!/usr/bin/env zsh
# ---
# Tool: SDKMAN
# Source: https://sdkman.io
# Purpose: Manage Java/JVM tool versions
# Updated: 2026-02-06
# Lazy Loading: Yes
# Note: Not installed via Homebrew to preserve SDKMAN_DIR control
# ---

export SDKMAN_DIR="$HOME/.sdkman"

_sdkman_load() {
  unset -f sdk
  if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  else
    echo "Warning: '${SDKMAN_DIR}/bin/sdkman-init.sh' not found."
    echo "Run: curl -s \"https://get.sdkman.io\" | bash"
    echo "Visit: https://sdkman.io"
  fi
}

sdk() { _sdkman_load; sdk "$@"; }
