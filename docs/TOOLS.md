# Dotfiles Tool List

**Last Updated**: 2026-03-19

## Kubernetes & Container

- **kubectl**: Kubernetes CLI
  - Source: https://kubernetes.io
  - Config: `zsh/tools/kubectl.zsh`
  - Aliases: `~/.kubectl_aliases` (803 aliases)
  - Managed symlink: `~/.kubectl_aliases` -> `dotfiles/external/kubectl_aliases`

- **k9s**: Kubernetes TUI
  - Source: https://github.com/derailed/k9s
  - Brewfile: `derailed/k9s/k9s`

- **helm**: Kubernetes package manager
  - Source: https://helm.sh
  - Brewfile: `helm`

- **kustomize**: Kubernetes native configuration management
  - Brewfile: `kustomize`

## Git & Version Control

- **git**: Version control system
  - Config: `git/config`, `git/ignore`, `git/attributes`

- **lazygit**: Terminal UI for git
  - Source: https://github.com/jesseduffield/lazygit
  - Config: `zsh/tools/lazygit.zsh`

- **gh**: GitHub CLI
  - Source: https://cli.github.com
  - Brewfile: `gh`

- **ghq**: Repository manager
  - Source: https://github.com/x-motemen/ghq
  - Config: `zsh/tools/ghq.zsh`

- **gitalias**: 1780+ git aliases (optional)
  - Source: https://github.com/GitAlias/gitalias
  - File: `git/aliases/gitalias`

## Shell Enhancement

- **kube-ps1**: Kubernetes context prompt segment
  - File: `external/kube-ps1.sh`
  - Managed symlink: `~/.kube-ps1.sh` -> `dotfiles/external/kube-ps1.sh`

- **fzf**: Fuzzy finder
  - Source: https://github.com/junegunn/fzf
  - Config: `zsh/tools/fzf.zsh`

- **zsh keybindings**: Word navigation and deletion key normalization
  - Source: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
  - Config: `zsh/tools/keybindings.zsh`
  - Terminal Reference: https://iterm2.com/documentation-preferences-profiles-keys.html
  - Notes: Normalizes Option/Meta word movement and backward word deletion across terminals

- **zoxide**: Smarter cd command
  - Source: https://github.com/ajeetdsouza/zoxide
  - Config: `zsh/tools/zoxide.zsh`

- **exa**: Modern ls replacement
  - Source: https://github.com/ogham/exa
  - Aliases: `l`, `ll`, `la`

- **ripgrep**: Fast grep alternative
  - Brewfile: `ripgrep`

- **zsh-syntax-highlighting**: Syntax highlighting for zsh
  - Config: `zsh/core/90-syntax-highlighting.zsh`

- **yazi**: Terminal file manager (ranger alternative)
  - Source: https://yazi-rs.github.io
  - Config: `zsh/tools/yazi.zsh`
  - Wrapper: `yy` (change directory on exit)
  - Managed symlink: `~/.config/yazi` -> `dotfiles/config/yazi`

- **om**: OpenCode monitor shortcut
  - Command: `ocmonitor live --pick`
  - Notes: Opens the ocmonitor live picker directly; `oc` remains `opencode --continue`

- **OpenCode Java LSP (JDTLS)**: Language Server Protocol for Java
  - Uses shared `jdtls-lombok` wrapper (see `config/claude/plugins/jdtls-lombok/`)
  - Requires: `brew install jdtls` and Lombok jar in Maven local cache

- **OpenCode preset config**: Local `oh-my-opencode-slim` preset definition
  - Config: `config/opencode/oh-my-opencode-slim.json`
  - Managed symlink: `~/.config/opencode/oh-my-opencode-slim.json` -> `dotfiles/config/opencode/oh-my-opencode-slim.json`
  - Notes: Keeps local preset/model overrides repo-backed alongside the OpenCode plugin directory

- **Claude 設定**: Claude Desktop/CLI 設定檔
  - Config: `config/claude/settings.json`
  - Managed symlink: `~/.claude/settings.json` -> `dotfiles/config/claude/settings.json`
  - Notes: Edit the repo copy, not `~/.claude/settings.json`; future candidates live under `config/claude/`
- **Codex 設定**: Codex CLI/Desktop 設定檔
  - Config: `config/codex/config.toml`, `config/codex/hooks.json`
  - Managed symlink: `~/.codex/config.toml` -> `dotfiles/config/codex/config.toml`
  - Notes: Edit repo copies under `config/codex/`; runtime state such as auth, logs, sessions, and caches stays local under `~/.codex/`

## Development Languages

- **Go**: Go programming language
  - Brewfile: `go`
  - Config: `zsh/tools/dev/go.zsh`

- **nvm**: Node.js version manager
  - Source: https://github.com/nvm-sh/nvm
  - Config: `zsh/tools/dev/nvm.zsh` (lazy loading)

- **pyenv**: Python version manager (backup)
  - Source: https://github.com/pyenv/pyenv
  - Config: `zsh/tools/dev/pyenv.zsh` (lazy loading)

- **sdkman**: Java/JVM tool version manager
  - Source: https://sdkman.io
  - Config: `zsh/tools/dev/sdkman.zsh` (lazy loading)

## Removed Tools

The following tools have been removed from the configuration:

- **OrbStack, Colima**: Container tools (replaced by Docker Desktop)
- **sfnt2woff, woff2**: Font conversion tools (no longer needed)

## Adding New Tools

Refer to the "Routing" section in `AGENTS.md` and follow the existing patterns in `zsh/tools/`.
