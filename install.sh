#!/usr/bin/env bash
# Dotfiles installation script
# Creates symlinks from home directory to dotfiles repo
# Updated: 2026-02-06

set -e

# Detect dotfiles directory
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Installing dotfiles from: $DOTFILES_ROOT"
echo ""

# Function to create symlink with backup
link_file() {
  local src="$1"
  local dst="$2"
  local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
  
  # Skip if source doesn't exist
  if [[ ! -e "$src" ]]; then
    echo "⚠️  Source not found, skipping: $src"
    return
  fi
  
  # Backup existing file/link
  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      echo "✓  Already linked: $dst"
      return
    fi
    
    mkdir -p "$backup_dir"
    echo "📦 Backing up: $dst → $backup_dir"
    mv "$dst" "$backup_dir/"
  fi
  
  # Create parent directory if needed
  mkdir -p "$(dirname "$dst")"
  
  # Create symlink
  ln -sf "$src" "$dst"
  echo "✓  Linked: $dst → $src"
}

echo "📂 Linking Zsh configurations..."
link_file "$DOTFILES_ROOT/zsh/rc.zsh" "$HOME/.zshrc"
link_file "$DOTFILES_ROOT/zsh/env.zsh" "$HOME/.zshenv"

echo ""
echo "📂 Linking Git configurations..."
link_file "$DOTFILES_ROOT/git/config" "$HOME/.gitconfig"
link_file "$DOTFILES_ROOT/git/ignore" "$HOME/.gitignore"
link_file "$DOTFILES_ROOT/git/attributes" "$HOME/.gitattributes"

echo ""
echo "📂 Linking misc configurations..."
link_file "$DOTFILES_ROOT/misc/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_ROOT/misc/vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_ROOT/misc/editorconfig" "$HOME/.editorconfig"
link_file "$DOTFILES_ROOT/misc/wgetrc" "$HOME/.wgetrc"
link_file "$DOTFILES_ROOT/misc/curlrc" "$HOME/.curlrc"

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "Next steps:"
echo "  1. Install Homebrew packages: brew bundle --file=$DOTFILES_ROOT/brew/Brewfile"
echo "  2. Restart your shell: exec zsh"
echo "  3. (Optional) Install nvm, pyenv, sdkman - see docs/SETUP.md"
echo ""
echo "📖 Documentation:"
echo "  - AI agents: $DOTFILES_ROOT/AGENTS.md"
echo "  - Tools list: $DOTFILES_ROOT/docs/TOOLS.md"
echo "  - Setup guide: $DOTFILES_ROOT/docs/SETUP.md"
