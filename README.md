# Shihyu's dotfiles

![Version](https://img.shields.io/badge/version-2.0-blue)
![Shell](https://img.shields.io/badge/shell-zsh-green)
![License](https://img.shields.io/badge/license-MIT-orange)

Modular macOS dotfiles configuration focused on performance and maintainability.

## ✨ Features

- ⚡ **Lightning Fast**: < 0.5s shell startup time
- 📁 **Modular Design**: Clear structure organized by functionality
- 🔗 **Symlink Mode**: Changes take effect immediately, no sync needed
- 🤖 **AI-Friendly**: Includes `AGENTS.md` and dedicated skill for easy AI-assisted maintenance
- 🎯 **Lazy Loading**: Dev tools (nvm, pyenv, sdkman) loaded on demand
- 📝 **Comprehensive Documentation**: All tools documented with sources and purposes

## 📂 Structure

```
dotfiles/
├── zsh/                # Zsh configuration (modular)
│   ├── core/           # Core functionality (PATH, completion, history, prompt)
│   ├── tools/          # Tool configurations (kubectl, git, fzf, etc.)
│   └── aliases/        # Categorized aliases
├── git/                # Git configuration
├── brew/               # Homebrew Brewfile
├── misc/               # Other configs (tmux, vimrc, vim runtime, etc.)
├── external/           # External source assets (aliases, prompt helpers)
├── docs/               # Documentation
├── AGENTS.md           # AI agent guide
├── install.sh          # Installation script
└── uninstall.sh        # Uninstallation script
```

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Complete setup (symlinks + Homebrew packages)
make setup

# Or step by step:
make install  # Create symlinks only
make brew     # Install Homebrew packages only

# First-time setup: create local secrets file
cp secrets.example ~/.secrets
chmod 600 ~/.secrets
# Then edit ~/.secrets and set required values

# Uninstall managed symlinks (optional)
make uninstall

# Restart shell
exec zsh
```

**See available commands**: `make help`

See [`docs/SETUP.md`](docs/SETUP.md) for detailed installation guide.

## 🛠️ Main Tools

### Kubernetes & Container
- kubectl (+ 800 aliases), k9s, helm, kustomize

### Git & Version Control
- git, lazygit, gh, ghq

### Shell Enhancement
- fzf, zoxide, exa, ripgrep

### Development Languages
- Go, Node.js (nvm), Python (pyenv), Java (sdkman)

See [`docs/TOOLS.md`](docs/TOOLS.md) for complete tool list.

## 📖 Documentation

- **[AGENTS.md](AGENTS.md)**: AI agent guide (architecture principles, modification rules)
- **[docs/TOOLS.md](docs/TOOLS.md)**: Tool list and sources
- **[docs/SETUP.md](docs/SETUP.md)**: Installation guide

## 🎯 Design Principles

1. **Performance First**: Startup speed < 0.5s
   - Use fast-path defaults for common Homebrew prefixes with fallback detection for non-standard installs
   - Smart caching (completion, git info)
   - Lazy loading for dev tools

2. **Modular**: Organized by functionality, easy to maintain
   - Core configs (`zsh/core/`): Loaded in numeric order
   - Tool configs (`zsh/tools/`): Conditional loading
   - Dev tools (`zsh/tools/dev/`): Lazy loading

3. **AI-Friendly**: 
   - Detailed `AGENTS.md` included
   - Config files include metadata (source, purpose, update date)
   - Dedicated skill: `.agents/skills/dotfiles-manager/` (project-level)

## 🔧 Maintenance

### Adding New Tools

```bash
# 1. Edit Brewfile
echo 'brew "tool-name"' >> brew/Brewfile

# 2. Install
make brew

# 3. Check status
make check-tool TOOL=tool-name

# 4. Test
make test
```

### Testing & Verification

```bash
# Run all tests
make test

# Run CI-friendly tests
make test-ci

# Detailed startup analysis
make measure-startup

# Check specific tool
make check-tool TOOL=kubectl
```

### Updating Configuration

Since using symlink mode, directly edit files in dotfiles repo:

```bash
vim ~/dotfiles/zsh/core/30-prompt.zsh
exec zsh  # Reload
make test  # Verify changes
```

### Uninstalling Dotfiles

```bash
# Remove only symlinks managed by this repository
make uninstall
```

### Updating External Aliases

```bash
# Update all
make update-aliases

# Update specific
make update-aliases TARGET=kubectl
```

## 🤖 AI Collaboration

This dotfiles is designed for AI collaboration:

1. **Read AGENTS.md**: Understand architecture principles and modification rules
2. **Use dotfiles-manager skill**: Provides standardized operation workflows
3. **Follow testing standards**: Test startup speed and functionality after each modification

AI agents can safely help with:
- Adding new tool configurations
- Updating external alias files
- Optimizing startup speed
- Cleaning up unused tools

## 📊 Performance

- Startup time: **0.16-0.22s** (tested on M2 MacBook Air)
- Target: < 0.5s (max 1s)
- Lazy loading saves: ~200ms (nvm + pyenv + sdkman)

## 📜 License

MIT

---

**Version**: 2.0  
**Last Updated**: 2026-02-06  
**Maintained by**: AI-assisted workflow
