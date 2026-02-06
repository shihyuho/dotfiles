#!/usr/bin/env bash
# Check dependencies for a tool before removal
# Usage: ./scripts/check-dependencies.sh <tool-name>

set -e

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <tool-name>"
  exit 1
fi

TOOL_NAME="$1"
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"

echo "🔍 Checking dependencies for '$TOOL_NAME'..."
echo ""

# Check 1: Homebrew dependencies
echo "1️⃣  Homebrew dependencies..."
BREW_DEPS=$(brew uses --installed "$TOOL_NAME" 2>/dev/null || true)
if [[ -n "$BREW_DEPS" ]]; then
  echo "⚠️  Other packages depend on '$TOOL_NAME':"
  echo "$BREW_DEPS" | sed 's/^/   /'
  echo ""
  echo "   ❌ UNSAFE TO REMOVE"
  SAFE_TO_REMOVE=false
else
  echo "✅ No Homebrew dependencies"
  SAFE_TO_REMOVE=true
fi
echo ""

# Check 2: References in dotfiles
echo "2️⃣  Dotfiles references..."
DOTFILE_REFS=$(grep -r "$TOOL_NAME" "$DOTFILES_ROOT/zsh/" 2>/dev/null || true)
if [[ -n "$DOTFILE_REFS" ]]; then
  echo "⚠️  Found references in dotfiles:"
  echo "$DOTFILE_REFS" | sed 's/^/   /'
  echo ""
  echo "   Files to clean up:"
  echo "$DOTFILE_REFS" | cut -d: -f1 | sort -u | sed 's/^/   - /'
  HAS_REFERENCES=true
else
  echo "✅ No references in dotfiles"
  HAS_REFERENCES=false
fi
echo ""

# Check 3: In Brewfile?
echo "3️⃣  Brewfile check..."
if grep -q "\"$TOOL_NAME\"" "$DOTFILES_ROOT/brew/Brewfile" 2>/dev/null; then
  echo "⚠️  Found in Brewfile:"
  grep "$TOOL_NAME" "$DOTFILES_ROOT/brew/Brewfile" | sed 's/^/   /'
  IN_BREWFILE=true
else
  echo "✅ Not in Brewfile"
  IN_BREWFILE=false
fi
echo ""

# Check 4: Is it a dependency itself?
echo "4️⃣  Dependency type check..."
BREW_INFO=$(brew info "$TOOL_NAME" 2>/dev/null || echo "Not a Homebrew package")
if echo "$BREW_INFO" | grep -q "Required by:"; then
  echo "⚠️  This is a dependency for other packages"
  echo "   ❌ UNSAFE TO REMOVE"
  SAFE_TO_REMOVE=false
else
  echo "✅ Not a required dependency"
fi
echo ""

# Summary
echo "📊 Summary:"
echo "   Brew dependencies: $([ "$SAFE_TO_REMOVE" = true ] && echo "✅ None" || echo "❌ Has dependencies")"
echo "   Dotfile references: $([ "$HAS_REFERENCES" = false ] && echo "✅ None" || echo "⚠️  Found")"
echo "   In Brewfile: $([ "$IN_BREWFILE" = true ] && echo "⚠️  Yes" || echo "✅ No")"
echo ""

# Decision
if [ "$SAFE_TO_REMOVE" = true ]; then
  echo "✅ SAFE TO REMOVE"
  echo ""
  echo "💡 Next steps:"
  echo "   1. Remove from Brewfile: vim $DOTFILES_ROOT/brew/Brewfile"
  
  if [ "$HAS_REFERENCES" = true ]; then
    echo "   2. Clean up dotfile references:"
    echo "$DOTFILE_REFS" | cut -d: -f1 | sort -u | sed 's/^/      - vim /'
  fi
  
  echo "   3. Update TOOLS.md: vim $DOTFILES_ROOT/docs/TOOLS.md"
  echo "   4. Test: zsh -n ~/.zshrc"
  echo "   5. (Optional) If requested, commit changes"
  echo "   6. (Optional) Uninstall: brew uninstall $TOOL_NAME"
else
  echo "❌ UNSAFE TO REMOVE"
  echo ""
  echo "⚠️  Reason: Other packages depend on this tool"
  echo "   Do NOT remove unless you understand the impact"
fi
