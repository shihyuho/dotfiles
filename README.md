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

First, complete [Prerequisites](docs/PREREQUISITES.md) (Xcode CLT + Homebrew).

```text
Prerequisites done
        │
        ▼
Have an AI coding agent CLI?
   │
   ├─ Yes ──► Path A (AI-assisted, recommended)
   └─ No  ──► Path B (Manual)
```

### Path A — AI-assisted (recommended)

Give your agent (Claude Code, OpenCode, Codex, etc.) this prompt:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/shihyuho/dotfiles/refs/heads/main/docs/INSTALL.md
```

The agent walks through clone, symlinks, secrets, and verification — pausing at decision points (install location, secrets editing).

### Path B — Manual

See [docs/SETUP.md](docs/SETUP.md) for the full manual install guide.

---

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
| `define` | Tools that clarify what to build | `/plugin install define@shihyuho-dotfiles` |

## Tools

- **Kubernetes**: kubectl (+ 800 aliases), k9s, helm, kustomize
- **Git**: git, lazygit, gh, ghq
- **Shell**: fzf, zoxide, exa, ripgrep
- **Languages**: Go, Node.js (nvm), Python (pyenv), Java (sdkman)

Full list: [`docs/TOOLS.md`](docs/TOOLS.md)

## Documentation

- [AGENTS.md](AGENTS.md) — AI agent guide
- [docs/PREREQUISITES.md](docs/PREREQUISITES.md) — Required tools before install
- [docs/INSTALL.md](docs/INSTALL.md) — AI installation playbook
- [docs/SETUP.md](docs/SETUP.md) — Manual installation guide
- [docs/TOOLS.md](docs/TOOLS.md) — Tool list and sources

## Performance

- Startup: **0.16-0.22s** (M2 MacBook Air), target < 0.5s
- Lazy loading saves ~200ms (nvm + pyenv + sdkman)

## License

MIT
