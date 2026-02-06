#!/usr/bin/env bash
set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"

echo "📥 Updating external aliases..."
echo "DOTFILES_ROOT: $DOTFILES_ROOT"
echo ""

echo "1️⃣  Updating kubectl-aliases..."
curl -sSL -o /tmp/kubectl_aliases \
  https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

cat << EOF > ~/.kubectl_aliases
# ---
# Tool: kubectl-aliases
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: 800+ kubectl shortcuts
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/kubectl_aliases >> ~/.kubectl_aliases
echo "✅ kubectl-aliases updated"
echo ""

echo "2️⃣  Updating gitalias..."
curl -sSL -o /tmp/gitalias \
  https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt

cat << EOF > "$DOTFILES_ROOT/git/aliases/gitalias"
# ---
# Tool: gitalias
# Source: https://github.com/GitAlias/gitalias
# Purpose: 1780+ git aliases
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/gitalias >> "$DOTFILES_ROOT/git/aliases/gitalias"
echo "✅ gitalias updated"
echo ""

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
echo "  2. Commit changes: git add ~/.kubectl_aliases git/aliases/gitalias"
echo "  3. git commit -m \"Update external aliases to \$(date +%Y-%m-%d)\""
