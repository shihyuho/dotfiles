# Dotfiles 工具清單

**Last Updated**: 2026-02-06

## Kubernetes & Container

- **kubectl**: Kubernetes CLI
  - 來源: https://kubernetes.io
  - 配置: `zsh/tools/kubectl.zsh`
  - 別名: `~/.kubectl_aliases` (803 aliases)

- **k9s**: Kubernetes TUI
  - 來源: https://github.com/derailed/k9s
  - Brewfile: `derailed/k9s/k9s`

- **helm**: Kubernetes package manager
  - 來源: https://helm.sh
  - Brewfile: `helm`

- **kustomize**: Kubernetes native configuration management
  - Brewfile: `kustomize`

## Git & Version Control

- **git**: Version control system
  - 配置: `git/config`, `git/ignore`, `git/attributes`

- **lazygit**: Terminal UI for git
  - 來源: https://github.com/jesseduffield/lazygit
  - 配置: `zsh/tools/lazygit.zsh`

- **gh**: GitHub CLI
  - 來源: https://cli.github.com
  - Brewfile: `gh`

- **ghq**: Repository manager
  - 來源: https://github.com/x-motemen/ghq
  - 配置: `zsh/tools/ghq.zsh`

- **gitalias**: 1780+ git aliases (選用)
  - 來源: https://github.com/GitAlias/gitalias
  - 檔案: `git/aliases/gitalias`

## Shell Enhancement

- **fzf**: Fuzzy finder
  - 來源: https://github.com/junegunn/fzf
  - 配置: `zsh/tools/fzf.zsh`

- **zoxide**: Smarter cd command
  - 來源: https://github.com/ajeetdsouza/zoxide
  - 配置: `zsh/tools/zoxide.zsh`

- **exa**: Modern ls replacement
  - 來源: https://github.com/ogham/exa
  - 別名: `l`, `ll`, `la`

- **ripgrep**: Fast grep alternative
  - Brewfile: `ripgrep`

- **zsh-syntax-highlighting**: Syntax highlighting for zsh
  - 配置: `zsh/core/90-syntax-highlighting.zsh`

## Development Languages

- **Go**: Go programming language
  - Brewfile: `go`
  - 配置: `zsh/tools/dev/go.zsh`

- **nvm**: Node.js version manager
  - 來源: https://github.com/nvm-sh/nvm
  - 配置: `zsh/tools/dev/nvm.zsh` (lazy loading)

- **pyenv**: Python version manager (備用)
  - 來源: https://github.com/pyenv/pyenv
  - 配置: `zsh/tools/dev/pyenv.zsh` (lazy loading)

- **sdkman**: Java/JVM tool version manager
  - 來源: https://sdkman.io
  - 配置: `zsh/tools/dev/sdkman.zsh` (lazy loading)

## Removed Tools

以下工具已從配置中移除：

- **OrbStack, Colima**: 容器工具（改用 Docker Desktop）
- **sfnt2woff, woff2**: 字型轉換工具（不再需要）

## 添加新工具

參考 `AGENTS.md` 中的「新增工具配置」章節，或使用 dotfiles-manager skill。
