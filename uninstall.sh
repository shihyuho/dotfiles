#!/usr/bin/env bash
# Dotfiles uninstallation script
# Removes symlinks created by install.sh and restores backups when available
# Updated: 2026-02-06

set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.dotfiles_backup"

echo "🧹 Uninstalling dotfiles from: $DOTFILES_ROOT"
echo ""

restore_backup_if_exists() {
  local dst="$1"
  local name
  name="$(basename "$dst")"

  [[ -d "$BACKUP_ROOT" ]] || return 0

  local backup_dir
  while IFS= read -r backup_dir; do
    [[ -e "$backup_dir/$name" ]] || continue
    mv "$backup_dir/$name" "$dst"
    echo "↩️  Restored backup: $dst"
    return 0
  done < <(ls -1dt "$BACKUP_ROOT"/* 2>/dev/null || true)
}

unlink_file() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      rm "$dst"
      echo "✓  Removed link: $dst"
      restore_backup_if_exists "$dst"
      return
    fi

    echo "⚠️  Skip (managed by something else): $dst -> $(readlink "$dst")"
    return
  fi

  if [[ -e "$dst" ]]; then
    echo "⚠️  Skip (not a symlink): $dst"
    return
  fi

  echo "✓  Already absent: $dst"
}

echo "📂 Removing Zsh configuration links..."
unlink_file "$DOTFILES_ROOT/zsh/rc.zsh" "$HOME/.zshrc"
unlink_file "$DOTFILES_ROOT/zsh/env.zsh" "$HOME/.zshenv"

echo ""
echo "📂 Removing Git configuration links..."
unlink_file "$DOTFILES_ROOT/git/config" "$HOME/.gitconfig"
unlink_file "$DOTFILES_ROOT/git/ignore" "$HOME/.gitignore"
unlink_file "$DOTFILES_ROOT/git/attributes" "$HOME/.gitattributes"
unlink_file "$DOTFILES_ROOT/git/aliases/gitalias" "$HOME/.gitalias"

echo ""
echo "📂 Removing shell integration links..."
unlink_file "$DOTFILES_ROOT/external/kubectl_aliases" "$HOME/.kubectl_aliases"
unlink_file "$DOTFILES_ROOT/external/kube-ps1.sh" "$HOME/.kube-ps1.sh"

echo ""
echo "📂 Removing misc configuration links..."
unlink_file "$DOTFILES_ROOT/config/zellij" "$HOME/.config/zellij"
unlink_file "$DOTFILES_ROOT/config/yazi" "$HOME/.config/yazi"
unlink_file "$DOTFILES_ROOT/config/ghostty" "$HOME/.config/ghostty"
unlink_file "$DOTFILES_ROOT/misc/tmux.conf" "$HOME/.tmux.conf"
unlink_file "$DOTFILES_ROOT/misc/vimrc" "$HOME/.vimrc"
unlink_file "$DOTFILES_ROOT/misc/editorconfig" "$HOME/.editorconfig"
unlink_file "$DOTFILES_ROOT/misc/wgetrc" "$HOME/.wgetrc"
unlink_file "$DOTFILES_ROOT/misc/curlrc" "$HOME/.curlrc"

echo ""
echo "📂 Removing Vim runtime links..."
unlink_file "$DOTFILES_ROOT/misc/vim/autoload/plug.vim" "$HOME/.vim/autoload/plug.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/autoload/onedark.vim" "$HOME/.vim/autoload/onedark.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/autoload/airline/themes/onedark.vim" "$HOME/.vim/autoload/airline/themes/onedark.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/autoload/lightline/colorscheme/onedark.vim" "$HOME/.vim/autoload/lightline/colorscheme/onedark.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/colors/onedark.vim" "$HOME/.vim/colors/onedark.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/colors/vim-material.vim" "$HOME/.vim/colors/vim-material.vim"
unlink_file "$DOTFILES_ROOT/misc/vim/syntax/json.vim" "$HOME/.vim/syntax/json.vim"

echo ""
echo "✨ Dotfiles uninstallation complete!"
echo ""
echo "📝 Notes:"
echo "  - Only links that point to this repository were removed."
echo "  - If backup files existed, the latest backup was restored."
