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
link_file "$DOTFILES_ROOT/git/aliases/gitalias" "$HOME/.gitalias"

echo ""
echo "📂 Linking shell integration assets..."
link_file "$DOTFILES_ROOT/external/kubectl_aliases" "$HOME/.kubectl_aliases"
link_file "$DOTFILES_ROOT/external/kube-ps1.sh" "$HOME/.kube-ps1.sh"

echo ""
echo "📂 Linking misc configurations..."
link_file "$DOTFILES_ROOT/misc/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES_ROOT/misc/vimrc" "$HOME/.vimrc"
link_file "$DOTFILES_ROOT/misc/editorconfig" "$HOME/.editorconfig"
link_file "$DOTFILES_ROOT/misc/wgetrc" "$HOME/.wgetrc"
link_file "$DOTFILES_ROOT/misc/curlrc" "$HOME/.curlrc"

echo ""
echo "📂 Linking Vim runtime assets..."
link_file "$DOTFILES_ROOT/misc/vim/autoload/plug.vim" "$HOME/.vim/autoload/plug.vim"
link_file "$DOTFILES_ROOT/misc/vim/autoload/onedark.vim" "$HOME/.vim/autoload/onedark.vim"
link_file "$DOTFILES_ROOT/misc/vim/autoload/airline/themes/onedark.vim" "$HOME/.vim/autoload/airline/themes/onedark.vim"
link_file "$DOTFILES_ROOT/misc/vim/autoload/lightline/colorscheme/onedark.vim" "$HOME/.vim/autoload/lightline/colorscheme/onedark.vim"
link_file "$DOTFILES_ROOT/misc/vim/colors/onedark.vim" "$HOME/.vim/colors/onedark.vim"
link_file "$DOTFILES_ROOT/misc/vim/colors/vim-material.vim" "$HOME/.vim/colors/vim-material.vim"
link_file "$DOTFILES_ROOT/misc/vim/syntax/json.vim" "$HOME/.vim/syntax/json.vim"

# Ensure writable local runtime directories exist
mkdir -p "$HOME/.vim/backups" "$HOME/.vim/swaps" "$HOME/.vim/undo" "$HOME/.vim/plugged"

echo ""
echo "✨ Dotfiles installation complete!"
echo ""
echo "📝 Note: Project-level skills are available in:"
echo "    $DOTFILES_ROOT/.agents/skills/"
echo "    OpenCode will automatically detect them when working in this directory."
echo ""
echo "Next steps:"
echo "  1. Install Homebrew packages: brew bundle --file=$DOTFILES_ROOT/brew/Brewfile"
echo "  2. Create local secrets file: cp $DOTFILES_ROOT/secrets.example ~/.secrets && chmod 600 ~/.secrets"
echo "  3. Edit ~/.secrets and set required variables"
echo "  4. Restart your shell: exec zsh"
echo "  5. (Optional) Install nvm, pyenv, sdkman - see docs/SETUP.md"
echo ""
echo "📖 Documentation:"
echo "  - AI agents: $DOTFILES_ROOT/AGENTS.md"
echo "  - Tools list: $DOTFILES_ROOT/docs/TOOLS.md"
echo "  - Setup guide: $DOTFILES_ROOT/docs/SETUP.md"
