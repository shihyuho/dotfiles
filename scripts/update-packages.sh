#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TARGET="${1:-all}"
BREWFILE_PATH="${DOTFILES_ROOT}/brew/Brewfile"
SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if [[ "$TARGET" != "brew" && "$TARGET" != "aliases" && "$TARGET" != "sdkman" && "$TARGET" != "all" ]]; then
  echo "Usage: $0 [brew|aliases|sdkman|all]"
  exit 1
fi

warn() {
  printf '⚠️  %s\n' "$1"
}

require_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew not found. Install Homebrew first."
    exit 1
  fi
}

brew_formula_installed() {
  brew list --formula "$1" >/dev/null 2>&1
}

update_brew() {
  require_brew
  echo "→ Updating Homebrew metadata..."
  brew update
  echo ""

  echo "→ Upgrading installed Homebrew packages..."
  brew upgrade
  echo ""

  echo "→ Syncing Brewfile packages..."
  brew bundle --file="$BREWFILE_PATH"
  echo "✅ Homebrew update complete"
  echo ""
}

update_aliases() {
  echo "→ Updating external aliases..."
  "${DOTFILES_ROOT}/scripts/update-aliases.sh" all
}

update_sdkman() {
  if [[ ! -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    if [[ "$TARGET" == "all" ]]; then
      warn "SDKMAN is not installed; skipping"
      return 0
    fi

    echo "❌ SDKMAN not found at ${SDKMAN_DIR}/bin/sdkman-init.sh"
    echo "Run: curl -s \"https://get.sdkman.io\" | bash"
    exit 1
  fi

  echo "→ Refreshing SDKMAN candidates index..."
  set +u
  # shellcheck disable=SC1090
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  sdk update >/dev/null
  set -u
  echo "✅ SDKMAN candidates index refreshed"
  echo ""
}

echo "📦 Updating managed packages..."
echo "DOTFILES_ROOT: $DOTFILES_ROOT"
echo "TARGET: $TARGET"
echo ""

case "$TARGET" in
  brew)
    update_brew
    ;;
  aliases)
    update_aliases
    ;;
  sdkman)
    update_sdkman
    ;;
  all)
    update_brew
    update_aliases
    update_sdkman
    ;;
esac

echo "✨ Package update complete!"
