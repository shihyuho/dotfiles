#!/usr/bin/env bash
# Test dotfiles configuration
# Usage: ./scripts/test.sh

set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"
MAX_STARTUP_SECONDS="${MAX_STARTUP_SECONDS:-1.0}"

echo "🧪 Testing dotfiles configuration..."
echo "DOTFILES_ROOT: $DOTFILES_ROOT"
echo ""

# Test 1: Syntax check
echo "1️⃣  Syntax check..."
if zsh -n ~/.zshrc 2>/dev/null; then
  echo "✅ Syntax check passed"
else
  echo "❌ Syntax errors found"
  exit 1
fi
echo ""

# Test 2: Startup speed test
echo "2️⃣  Startup speed test (5 iterations)..."
total=0
for i in {1..5}; do
  time_output=$(/usr/bin/time -p zsh -i -c exit 2>&1 | grep real | awk '{print $2}')
  echo "   Iteration $i: ${time_output}s"
  total=$(echo "$total + $time_output" | bc)
done
avg=$(echo "scale=3; $total / 5" | bc)
echo "   Average: ${avg}s"

if (( $(echo "$avg < 0.5" | bc -l) )); then
  echo "✅ Excellent! (< 0.5s)"
elif (( $(echo "$avg < $MAX_STARTUP_SECONDS" | bc -l) )); then
  echo "⚠️  Acceptable (< ${MAX_STARTUP_SECONDS}s)"
else
  echo "❌ Too slow (> ${MAX_STARTUP_SECONDS}s) - optimization needed"
  exit 1
fi
echo ""

# Test 3: Symlink verification
echo "3️⃣  Symlink verification..."
symlinks=(
  "$HOME/.zshrc:$DOTFILES_ROOT/zsh/rc.zsh"
  "$HOME/.zshenv:$DOTFILES_ROOT/zsh/env.zsh"
  "$HOME/.gitconfig:$DOTFILES_ROOT/git/config"
  "$HOME/.gitalias:$DOTFILES_ROOT/git/aliases/gitalias"
  "$HOME/.kubectl_aliases:$DOTFILES_ROOT/external/kubectl_aliases"
  "$HOME/.kube-ps1.sh:$DOTFILES_ROOT/external/kube-ps1.sh"
  "$HOME/.vim/autoload/plug.vim:$DOTFILES_ROOT/misc/vim/autoload/plug.vim"
  "$HOME/.vim/colors/onedark.vim:$DOTFILES_ROOT/misc/vim/colors/onedark.vim"
  "$HOME/.vim/syntax/json.vim:$DOTFILES_ROOT/misc/vim/syntax/json.vim"
)

symlink_failed=false
for entry in "${symlinks[@]}"; do
  link="${entry%%:*}"
  target="${entry##*:}"
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    echo "✅ $link → $target"
  else
    echo "❌ $link not properly linked"
    symlink_failed=true
  fi
done
echo ""

if [[ "$symlink_failed" == true ]]; then
  echo "❌ Symlink verification failed"
  exit 1
fi

echo "✨ Testing complete!"
