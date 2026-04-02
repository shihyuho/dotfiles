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
  unset -f _sdkman_load sdk java javac mvn gradle ant tomcat
  if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  else
    echo "Warning: '${SDKMAN_DIR}/bin/sdkman-init.sh' not found."
    echo "Run: curl -s \"https://get.sdkman.io\" | bash"
    echo "Visit: https://sdkman.io"
  fi
}

sdk()    { unset -f sdk;    _sdkman_load 2>/dev/null; sdk "$@"; }
java()   { unset -f java;   _sdkman_load 2>/dev/null; java "$@"; }
javac()  { unset -f javac;  _sdkman_load 2>/dev/null; javac "$@"; }
mvn()    { unset -f mvn;    _sdkman_load 2>/dev/null; mvn "$@"; }
gradle() { unset -f gradle; _sdkman_load 2>/dev/null; gradle "$@"; }
ant()    { unset -f ant;    _sdkman_load 2>/dev/null; ant "$@"; }
tomcat() { unset -f tomcat; _sdkman_load 2>/dev/null; tomcat "$@"; }
