#!/usr/bin/env bash
# Measure detailed startup speed with zprof
# Usage: ./scripts/measure-startup.sh

set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

echo "📊 Detailed startup speed analysis..."
echo ""

# Check if zprof is already enabled
if grep -q "zmodload zsh/zprof" ~/.zshrc 2>/dev/null; then
  echo "⚠️  zprof already enabled in ~/.zshrc"
  echo "   Running analysis..."
  echo ""
  
  # Run zsh with zprof output
  zsh -i -c "zprof" 2>&1 | head -30
else
  echo "1️⃣  Enabling zprof temporarily..."
  
  # Create temporary zshrc with zprof
  TMP_ZSHRC=$(mktemp)
  cat > "$TMP_ZSHRC" << 'EOF'
# Temporary zprof instrumentation
zmodload zsh/zprof

EOF
  
  # Append actual zshrc content
  cat ~/.zshrc >> "$TMP_ZSHRC"
  
  # Add zprof at the end
  echo "" >> "$TMP_ZSHRC"
  echo "zprof" >> "$TMP_ZSHRC"
  
  echo "2️⃣  Running analysis..."
  echo ""
  
  # Run with temporary config
  ZDOTDIR=$(dirname "$TMP_ZSHRC") zsh -c "source $TMP_ZSHRC" 2>&1 | head -30
  
  # Cleanup
  rm -f "$TMP_ZSHRC"
  
  echo ""
  echo "✨ Analysis complete!"
fi

echo ""
echo "📈 Performance guidelines:"
echo ""
echo "| Item                  | Target  | Optimization                |"
echo "|-----------------------|---------|-----------------------------|"
echo "| PATH setup            | < 5ms   | Hardcode paths              |"
echo "| Completion init       | < 50ms  | Smart caching               |"
echo "| History setup         | < 5ms   | -                           |"
echo "| Prompt setup          | < 10ms  | Cache git info              |"
echo "| Syntax highlighting   | < 20ms  | Load last                   |"
echo "| Conditional tools     | < 10ms  | Use command -v              |"
echo "| Lazy loading setup    | < 5ms   | Function wrappers           |"
echo ""
echo "🎯 Total target: < 200ms (core < 150ms + tools < 50ms)"
echo ""
echo "💡 Next steps:"
echo "   - Identify functions taking > 50ms"
echo "   - Consider lazy loading for expensive tools"
echo "   - Check for subprocess calls: \$(command)"
echo "   - Ensure completion cache is working"
