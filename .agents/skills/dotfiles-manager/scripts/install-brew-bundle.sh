#!/usr/bin/env bash
# Install Homebrew packages from repository Brewfile
# Usage: ./scripts/install-brew-bundle.sh

set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"

echo "🍺 Installing packages from Brewfile..."
echo "Brewfile: $DOTFILES_ROOT/brew/Brewfile"

brew bundle --file="$DOTFILES_ROOT/brew/Brewfile"

echo "✅ Brew bundle completed"
