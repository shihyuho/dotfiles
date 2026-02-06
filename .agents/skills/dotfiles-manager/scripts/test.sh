#!/usr/bin/env bash
# Test dotfiles configuration
# Usage: ./scripts/test.sh

set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

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
elif (( $(echo "$avg < 1.0" | bc -l) )); then
  echo "⚠️  Acceptable (< 1.0s)"
else
  echo "❌ Too slow (> 1.0s) - optimization needed"
fi
echo ""

# Test 3: Symlink verification
echo "3️⃣  Symlink verification..."
symlinks=(
  "$HOME/.zshrc:$DOTFILES_ROOT/zsh/rc.zsh"
  "$HOME/.zshenv:$DOTFILES_ROOT/zsh/env.zsh"
  "$HOME/.gitconfig:$DOTFILES_ROOT/git/config"
)

for entry in "${symlinks[@]}"; do
  link="${entry%%:*}"
  target="${entry##*:}"
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    echo "✅ $link → $target"
  else
    echo "❌ $link not properly linked"
  fi
done
echo ""

echo "✨ Testing complete!"
