# Shihyu's dotfiles

![Version](https://img.shields.io/badge/version-2.0-blue)
![Shell](https://img.shields.io/badge/shell-zsh-green)
![License](https://img.shields.io/badge/license-MIT-orange)

模組化的 macOS dotfiles 配置，專注於效能和可維護性。

## ✨ 特色

- ⚡ **極速啟動**: < 0.5s shell 啟動時間
- 📁 **模組化設計**: 按功能分類的清晰結構
- 🔗 **Symlink 模式**: 修改即生效，無需同步
- 🤖 **AI 友好**: 包含 `AGENTS.md` 和專用 skill，方便 AI 協助維護
- 🎯 **Lazy Loading**: 開發工具（nvm, pyenv, sdkman）按需載入
- 📝 **完整文檔**: 記錄所有工具來源和用途

## 📂 結構

```
dotfiles/
├── zsh/                # Zsh 配置（模組化）
│   ├── core/           # 核心功能（PATH, completion, history, prompt）
│   ├── tools/          # 工具配置（kubectl, git, fzf 等）
│   └── aliases/        # 別名分類
├── git/                # Git 配置
├── brew/               # Homebrew Brewfile
├── misc/               # 其他配置（tmux, vim, etc.）
├── docs/               # 文檔
├── AGENTS.md           # AI 代理指南
└── install.sh          # 安裝腳本
```

## 🚀 快速開始

```bash
# Clone repository
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 建立 symlinks
./install.sh

# 安裝 Homebrew 套件
brew bundle --file=~/dotfiles/brew/Brewfile

# 重啟 shell
exec zsh
```

詳細安裝指南見 [`docs/SETUP.md`](docs/SETUP.md)。

## 🛠️ 主要工具

### Kubernetes & Container
- kubectl (+ 800 aliases), k9s, helm, kustomize

### Git & 版本控制
- git, lazygit, gh, ghq

### Shell 增強
- fzf, zoxide, exa, ripgrep

### 開發語言
- Go, Node.js (nvm), Python (pyenv), Java (sdkman)

完整工具清單見 [`docs/TOOLS.md`](docs/TOOLS.md)。

## 📖 文檔

- **[AGENTS.md](AGENTS.md)**: AI 代理指南（架構原則、修改規則）
- **[docs/TOOLS.md](docs/TOOLS.md)**: 工具清單與來源
- **[docs/SETUP.md](docs/SETUP.md)**: 安裝指南

## 🎯 設計原則

1. **效能第一**: 啟動速度 < 0.5s
   - 硬編碼常見路徑（避免 `$(brew --prefix)`）
   - 智能快取（completion, git info）
   - Lazy loading 開發工具

2. **模組化**: 按功能分類，易於維護
   - 核心配置（`zsh/core/`）：按數字順序載入
   - 工具配置（`zsh/tools/`）：條件載入
   - 開發工具（`zsh/tools/dev/`）：lazy loading

3. **AI 友好**: 
   - 包含詳細的 `AGENTS.md`
   - 配置檔包含元數據（來源、用途、更新日期）
   - 專用 skill：`~/.config/opencode/skills/dotfiles-manager/`

## 🔧 維護

### 添加新工具

```bash
# 1. 編輯 Brewfile
echo 'brew "tool-name"' >> brew/Brewfile

# 2. 安裝
brew bundle --file=brew/Brewfile

# 3. 建立配置（如需）
# 參考 AGENTS.md 中的「新增工具配置」章節
```

### 測試啟動速度

```bash
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done
```

### 更新配置

由於使用 symlink，直接編輯 dotfiles repo 中的檔案即可：

```bash
vim ~/dotfiles/zsh/core/30-prompt.zsh
exec zsh  # 重新載入
```

## 🤖 AI 協作

此 dotfiles 專為 AI 協作設計：

1. **閱讀 AGENTS.md**: 了解架構原則和修改規則
2. **使用 dotfiles-manager skill**: 提供標準化操作流程
3. **遵循測試規範**: 每次修改後測試啟動速度和功能

AI 代理可以安全地協助：
- 添加新工具配置
- 更新外部別名檔
- 優化啟動速度
- 清理未使用工具

## 📊 效能

- 啟動時間: **0.16-0.22s** (測試於 M2 MacBook Air)
- 目標: < 0.5s (最多 1s)
- Lazy loading 節省: ~200ms (nvm + pyenv + sdkman)

## 📜 License

MIT

## 🙏 致謝

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles): 原始靈感來源
- [ahmetb/kubectl-aliases](https://github.com/ahmetb/kubectl-aliases): kubectl 別名
- [GitAlias/gitalias](https://github.com/GitAlias/gitalias): git 別名集合

---

**Version**: 2.0  
**Last Updated**: 2026-02-06  
**Maintained by**: AI-assisted workflow
