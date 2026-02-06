#!/usr/bin/env bash
set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
TARGET="${1:-all}"

if [[ "$TARGET" != "kubectl" && "$TARGET" != "gitalias" && "$TARGET" != "all" ]]; then
  echo "Usage: $0 [kubectl|gitalias|all]"
  exit 1
fi

TMP_KUBECTL="$(mktemp)"
TMP_GITALIAS="$(mktemp)"
trap 'rm -f "$TMP_KUBECTL" "$TMP_GITALIAS"' EXIT

update_kubectl_aliases() {
  echo "1️⃣  Updating kubectl-aliases..."
  curl -sSL -o "$TMP_KUBECTL" \
    https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

  cat << EOF > "$HOME/.kubectl_aliases"
# ---
# Tool: kubectl-aliases
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: 800+ kubectl shortcuts
# Updated: $(date +%Y-%m-%d)
# ---

EOF
  cat "$TMP_KUBECTL" >> "$HOME/.kubectl_aliases"
  echo "✅ kubectl-aliases updated"
  echo ""
}

update_gitalias() {
  echo "2️⃣  Updating gitalias..."
  curl -sSL -o "$TMP_GITALIAS" \
    https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt

  cat << EOF > "$DOTFILES_ROOT/git/aliases/gitalias"
# ---
# Tool: gitalias
# Source: https://github.com/GitAlias/gitalias
# Purpose: 1780+ git aliases
# Updated: $(date +%Y-%m-%d)
# ---

EOF
  cat "$TMP_GITALIAS" >> "$DOTFILES_ROOT/git/aliases/gitalias"
  echo "✅ gitalias updated"
  echo ""
}

echo "📥 Updating external aliases..."
echo "DOTFILES_ROOT: $DOTFILES_ROOT"
echo "TARGET: $TARGET"
echo ""

if [[ "$TARGET" == "kubectl" || "$TARGET" == "all" ]]; then
  update_kubectl_aliases
fi

if [[ "$TARGET" == "gitalias" || "$TARGET" == "all" ]]; then
  update_gitalias
fi

echo "3️⃣  Testing syntax..."
if zsh -n ~/.zshrc 2>/dev/null; then
  echo "✅ Syntax check passed"
else
  echo "❌ Syntax errors found"
  exit 1
fi
echo ""

echo "✨ Alias update complete!"
echo ""
echo "Next steps:"
echo "  1. Test aliases: zsh -i -c \"alias | grep kubectl | head -5\""
echo "  2. If needed, run full validation: make test"
