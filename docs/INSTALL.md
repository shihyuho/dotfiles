# AI Install Guide

This guide is for AI agents helping a user install and bootstrap this dotfiles repository.

## 1) Ask Install Location

Ask the user where to clone the repository.

- Preferred question: `Where should I clone the dotfiles repository?`
- Default path: `~/.config/dotfiles`

If the user has no preference, use the default.

## 2) Clone (or Update) Repository

```bash
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"

if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone https://github.com/shihyuho/dotfiles.git "$DOTFILES_DIR"
fi
```

## 3) Install and Verify

```bash
cd "$DOTFILES_DIR"
make setup
cp "$DOTFILES_DIR/secrets.example" "$HOME/.secrets"
chmod 600 "$HOME/.secrets"
exec zsh
make test
```

## 4) Ask User to Fill Secrets

Tell the user to edit `~/.secrets` and set required values.

## 5) Use Linked Docs Instead of Duplicating Details

- Detailed setup flow: [`SETUP.md`](SETUP.md)
- Tool list and source links: [`TOOLS.md`](TOOLS.md)

## Agent Notes

- Follow project rules in `AGENTS.md`.
- Do not edit symlink targets in `$HOME` when source files exist in repo.
- Do not commit unless the user explicitly asks.
