#!/usr/bin/env bash
# Create a new tool config skeleton with required metadata header
# Usage: ./scripts/create-tool-config.sh <tool-name> <source-url> <purpose> [tools|dev]

set -e

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <tool-name> <source-url> <purpose> [tools|dev]"
  exit 1
fi

TOOL_NAME="$1"
SOURCE_URL="$2"
PURPOSE="$3"
TOOL_GROUP="${4:-tools}"

if [[ ! "$TOOL_NAME" =~ ^[a-z0-9._+-]+$ ]]; then
  echo "Invalid tool name: $TOOL_NAME"
  echo "Use lowercase letters, numbers, dot, underscore, plus, or dash"
  exit 1
fi

if [[ "$TOOL_GROUP" != "tools" && "$TOOL_GROUP" != "dev" ]]; then
  echo "Invalid group: $TOOL_GROUP"
  echo "Expected: tools or dev"
  exit 1
fi

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)}"

if [[ "$TOOL_GROUP" == "dev" ]]; then
  TARGET_DIR="$DOTFILES_ROOT/zsh/tools/dev"
  TARGET_REL="zsh/tools/dev"
else
  TARGET_DIR="$DOTFILES_ROOT/zsh/tools"
  TARGET_REL="zsh/tools"
fi

TARGET_FILE="$TARGET_DIR/$TOOL_NAME.zsh"

if [[ -f "$TARGET_FILE" ]]; then
  echo "Config already exists: $TARGET_FILE"
  exit 1
fi

mkdir -p "$TARGET_DIR"

cat > "$TARGET_FILE" <<EOF
#!/usr/bin/env zsh
# ---
# Tool: $TOOL_NAME
# Source: $SOURCE_URL
# Purpose: $PURPOSE
# Updated: $(date +%Y-%m-%d)
# ---

# Add configuration here
EOF

echo "✅ Created: $TARGET_FILE"
echo ""
echo "Next steps:"
if [[ "$TOOL_GROUP" == "dev" ]]; then
  echo "  1. Add source line in zsh/rc.zsh:"
  echo "     source \"\${DOTFILES_ROOT}/$TARGET_REL/$TOOL_NAME.zsh\""
else
  echo "  1. Add load line in zsh/rc.zsh:"
  echo "     _load_tool_if_exists $TOOL_NAME \"\${DOTFILES_ROOT}/$TARGET_REL/$TOOL_NAME.zsh\""
fi
echo "  2. Run verification: bash .agents/skills/dotfiles-manager/scripts/test.sh"
