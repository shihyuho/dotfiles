#!/usr/bin/env bash
# Check if a tool is installed and configured
# Usage: ./scripts/check-tool-status.sh <tool-name>

set -e

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <tool-name>"
  exit 1
fi

TOOL_NAME="$1"
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

echo "🔍 Checking status of '$TOOL_NAME'..."
echo ""

# Check 1: Is it in Brewfile?
echo "1️⃣  Brewfile check..."
if grep -q "\"$TOOL_NAME\"" "$DOTFILES_ROOT/brew/Brewfile" 2>/dev/null; then
  echo "✅ Found in Brewfile"
  IN_BREWFILE=true
else
  echo "❌ Not in Brewfile"
  IN_BREWFILE=false
fi
echo ""

# Check 2: Is it installed?
echo "2️⃣  Installation check..."
if command -v "$TOOL_NAME" >/dev/null 2>&1; then
  TOOL_PATH=$(which "$TOOL_NAME")
  echo "✅ Installed at: $TOOL_PATH"
  
  # Try to get version
  if "$TOOL_NAME" --version >/dev/null 2>&1; then
    VERSION=$("$TOOL_NAME" --version 2>&1 | head -1)
    echo "   Version: $VERSION"
  fi
  IS_INSTALLED=true
else
  echo "❌ Not installed (not in PATH)"
  IS_INSTALLED=false
fi
echo ""

# Check 3: Is there a config file?
echo "3️⃣  Configuration check..."
CONFIG_FILE="$DOTFILES_ROOT/zsh/tools/$TOOL_NAME.zsh"
CONFIG_FILE_DEV="$DOTFILES_ROOT/zsh/tools/dev/$TOOL_NAME.zsh"

if [[ -f "$CONFIG_FILE" ]]; then
  echo "✅ Config found: zsh/tools/$TOOL_NAME.zsh"
  HAS_CONFIG=true
  CONFIG_PATH="$CONFIG_FILE"
elif [[ -f "$CONFIG_FILE_DEV" ]]; then
  echo "✅ Config found: zsh/tools/dev/$TOOL_NAME.zsh"
  HAS_CONFIG=true
  CONFIG_PATH="$CONFIG_FILE_DEV"
else
  echo "❌ No config file found"
  HAS_CONFIG=false
fi
echo ""

# Check 4: Is it loaded in rc.zsh?
echo "4️⃣  Loading logic check..."
if grep -q "$TOOL_NAME" "$DOTFILES_ROOT/zsh/rc.zsh" 2>/dev/null; then
  echo "✅ Loading logic found in rc.zsh"
  grep "$TOOL_NAME" "$DOTFILES_ROOT/zsh/rc.zsh"
  IS_LOADED=true
else
  echo "❌ Not referenced in rc.zsh"
  IS_LOADED=false
fi
echo ""

# Summary
echo "📊 Summary:"
echo "   Brewfile: $([ "$IN_BREWFILE" = true ] && echo "✅" || echo "❌")"
echo "   Installed: $([ "$IS_INSTALLED" = true ] && echo "✅" || echo "❌")"
echo "   Configured: $([ "$HAS_CONFIG" = true ] && echo "✅" || echo "❌")"
echo "   Loaded: $([ "$IS_LOADED" = true ] && echo "✅" || echo "❌")"
echo ""

# Next steps
if [ "$IN_BREWFILE" = true ] && [ "$IS_INSTALLED" = false ]; then
  echo "💡 Next steps:"
  echo "   brew bundle --file=$DOTFILES_ROOT/brew/Brewfile"
elif [ "$IS_INSTALLED" = true ] && [ "$HAS_CONFIG" = false ]; then
  echo "💡 Next steps:"
  echo "   Consider creating: $CONFIG_FILE"
elif [ "$HAS_CONFIG" = true ] && [ "$IS_LOADED" = false ]; then
  echo "💡 Next steps:"
  echo "   Add to rc.zsh: _load_tool_if_exists $TOOL_NAME \"$CONFIG_PATH\""
elif [ "$IN_BREWFILE" = false ] && [ "$IS_INSTALLED" = true ]; then
  echo "⚠️  Warning: Installed but not in Brewfile (manual installation?)"
fi
