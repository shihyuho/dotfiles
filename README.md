# Shihyu's dotfiles

![Version](https://img.shields.io/badge/version-2.0-blue)
![Shell](https://img.shields.io/badge/shell-zsh-green)
![License](https://img.shields.io/badge/license-MIT-orange)

Modular macOS dotfiles — < 0.5s shell startup, symlink-based, AI-friendly.

## ✨ Features

- ⚡ **Lightning Fast**: < 0.5s shell startup time
- 📁 **Modular Design**: Clear structure organized by functionality
- 🔗 **Symlink Mode**: Changes take effect immediately, no sync needed
- 🤖 **AI-Friendly**: Includes `AGENTS.md` and dedicated skill for easy AI-assisted maintenance
- 🎯 **Lazy Loading**: Dev tools (nvm, pyenv, sdkman) loaded on demand
- 📝 **Comprehensive Documentation**: All tools documented with sources and purposes

## Quick Start

### AI-assisted

Tell your agent:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/shihyuho/dotfiles/refs/heads/main/docs/INSTALL.md
```

### Manual

```bash
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"
git clone https://github.com/shihyuho/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

make setup                                    # Symlinks + Homebrew packages
cp secrets.example ~/.secrets && chmod 600 ~/.secrets
exec zsh
```

Existing files at managed paths are backed up to `~/.dotfiles_backup/`. After installation, edit files in this repo — symlinks make changes immediate. See all commands: `make help`

## Claude Code Plugins

This repo is a [Claude Code plugin marketplace](https://docs.anthropic.com/en/docs/claude-code/plugins):

```bash
/plugin marketplace add shihyuho/dotfiles
```

| Plugin | Description | Install |
|--------|-------------|---------|
| `jdtls-lombok-lsp` | JDTLS with Lombok annotation support | `/plugin install jdtls-lombok-lsp@shihyuho-dotfiles` |
| `output-styles` | Output styles for Claude Code | `/plugin install output-styles@shihyuho-dotfiles` |
| `git` | Git workflow: commit, branch, PR, cleanup | `/plugin install git@shihyuho-dotfiles` |
| `plan` | Planning with a confidence gate — `/grill-lite` | `/plugin install plan@shihyuho-dotfiles` |
| `context` | Session handoff — save/restore context across `/clear` | `/plugin install context@shihyuho-dotfiles` |

## Tools

- **Kubernetes**: kubectl (+ 800 aliases), k9s, helm, kustomize
- **Git**: git, lazygit, gh, ghq
- **Shell**: fzf, zoxide, exa, ripgrep
- **Languages**: Go, Node.js (nvm), Python (pyenv), Java (sdkman)

Full list: [`docs/TOOLS.md`](docs/TOOLS.md)

## Documentation

- [AGENTS.md](AGENTS.md) — AI agent guide
- [docs/INSTALL.md](docs/INSTALL.md) — AI installation playbook
- [docs/SETUP.md](docs/SETUP.md) — Human installation guide
- [docs/TOOLS.md](docs/TOOLS.md) — Tool list and sources

## Performance

- Startup: **0.16-0.22s** (M2 MacBook Air), target < 0.5s
- Lazy loading saves ~200ms (nvm + pyenv + sdkman)

## License

MIT
