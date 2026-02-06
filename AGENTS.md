# Dotfiles Agent Guide

**Owner**: Matt Shih  
**Repository**: https://github.com/shihyuho/dotfiles  
**Last Updated**: 2026-02-06

## 專案概述

這是一個模組化的 dotfiles 管理系統，設計目標：
- ⚡ 啟動速度 < 0.5s（最多 1s）
- 📁 清晰的模組化結構
- 🔗 Symlink 模式（修改即生效）
- 🤖 AI 友好（方便未來由 AI 協助維護）

## 架構原則

### 目錄結構

```
dotfiles/
├── AGENTS.md                   # 本文件：AI 代理指南
├── README.md                   # 使用者文檔
├── install.sh                  # Symlink 安裝腳本
│
├── .agents/                    # AI 協作工具（project-level）
│   └── skills/
│       └── dotfiles-manager/   # 專用 skill
│
├── zsh/                        # Zsh 配置模組
│   ├── rc.zsh                  # 主入口 (→ ~/.zshrc)
│   ├── env.zsh                 # 環境變數 (→ ~/.zshenv)
│   ├── core/                   # 核心配置（必載，按數字順序）
│   │   ├── 00-path.zsh
│   │   ├── 10-completion.zsh
│   │   ├── 20-history.zsh
│   │   ├── 30-prompt.zsh
│   │   └── 90-syntax-highlighting.zsh
│   ├── tools/                  # 工具配置（條件載入）
│   │   ├── kubectl.zsh
│   │   ├── docker.zsh
│   │   ├── fzf.zsh
│   │   ├── zoxide.zsh
│   │   ├── lazygit.zsh
│   │   ├── ghq.zsh
│   │   └── dev/                # 開發工具（lazy loading）
│   │       ├── nvm.zsh
│   │       ├── pyenv.zsh
│   │       ├── sdkman.zsh
│   │       └── go.zsh
│   └── aliases/                # 別名分類
│       ├── common.zsh
│       └── navigation.zsh
│
├── git/                        # Git 配置
│   ├── config                  # symlink → ~/.gitconfig
│   ├── ignore                  # symlink → ~/.gitignore
│   ├── attributes              # symlink → ~/.gitattributes
│   └── aliases/
│       └── gitalias            # 可選：1780+ git 別名
│
├── brew/                       # Homebrew 配置
│   └── Brewfile                # 套件清單
│
├── misc/                       # 其他配置
│   ├── tmux.conf               # symlink → ~/.tmux.conf
│   ├── vimrc                   # symlink → ~/.vimrc
│   ├── editorconfig            # symlink → ~/.editorconfig
│   ├── wgetrc                  # symlink → ~/.wgetrc
│   └── curlrc                  # symlink → ~/.curlrc
│
└── docs/                       # 文檔
    ├── TOOLS.md                # 工具清單與來源
    └── SETUP.md                # 安裝指南
```

### 載入規則

#### 1. 核心配置 (zsh/core/*.zsh)
- **載入方式**: 按檔名數字順序（00, 10, 20...）
- **時機**: Shell 啟動時必定載入
- **效能要求**: 總耗時 < 100ms
- **內容**: PATH、completion、history、prompt 等基礎功能

**命名規範**:
- `00-path.zsh`: 最先載入（PATH 設定）
- `10-completion.zsh`: 補全系統
- `20-history.zsh`: 歷史記錄
- `30-prompt.zsh`: 提示符
- `90-syntax-highlighting.zsh`: 最後載入（語法高亮）

#### 2. 工具配置 (zsh/tools/*.zsh)
- **載入方式**: 條件載入（只在工具存在時）
- **檢查方式**: `command -v <tool> >/dev/null 2>&1`
- **適用**: kubectl, docker, fzf, zoxide 等外部工具

**範例**:
```zsh
# zsh/rc.zsh
_load_tool_if_exists kubectl "${DOTFILES_ROOT}/zsh/tools/kubectl.zsh"
```

#### 3. 開發工具 (zsh/tools/dev/*.zsh)
- **載入方式**: Lazy loading（函數包裝延遲載入）
- **原因**: nvm, pyenv, sdkman 初始化耗時 50-200ms
- **適用**: 不常用但需要時必須可用的工具

**實作模式**:
```zsh
# Lazy loading pattern
export TOOL_DIR="$HOME/.tool"

_tool_load() {
  unset -f tool
  # 實際初始化（耗時操作）
  eval "$(tool init)"
}

tool() { _tool_load; tool "$@"; }
```

### 效能優化原則

#### ❌ 禁止
- 在啟動時執行子程序：`$(brew --prefix)`, `$(git --version)`
- 大型檔案無條件載入（> 100 行且非必要）
- 重複設定環境變數或 PATH
- 在每次 shell 啟動時重建快取（應檢查檔案時間戳）

#### ✅ 推薦
- 硬編碼常見路徑（如 `/opt/homebrew` for Apple Silicon）
- 使用快取機制（completion cache, git info cache）
- 條件載入 + lazy loading
- 使用 zsh 內建函數而非外部指令

#### 快取策略
```zsh
# 範例：只在需要時重建快取
if [[ ! -s "$CACHE_FILE" || "$SOURCE_FILE" -nt "$CACHE_FILE" ]]; then
  # 重建快取
else
  # 使用快取
fi
```

## 修改規則

### 新增工具配置

**完整流程**:

1. **添加到 Brewfile**
   ```bash
   # 編輯 brew/Brewfile
   brew "<tool-name>"  # CLI 工具
   # 或
   cask "<app-name>"   # GUI 應用
   
   # 安裝
   brew bundle --file=~/dotfiles/brew/Brewfile
   ```

2. **建立配置檔**
   ```bash
   # 在 zsh/tools/<tool>.zsh 建立檔案
   # 必須包含檔案頭元數據：
   # ---
   # Tool: <工具名稱>
   # Source: <GitHub URL 或官方網站>
   # Purpose: <用途說明>
   # Updated: <YYYY-MM-DD>
   # ---
   ```

3. **註冊載入邏輯**
   ```zsh
   # 在 zsh/rc.zsh 添加
   _load_tool_if_exists <tool> "${DOTFILES_ROOT}/zsh/tools/<tool>.zsh"
   ```

4. **更新文檔**
   - 在 `docs/TOOLS.md` 添加工具說明
   - 記錄來源、用途、配置檔位置

5. **測試驗證**
   ```bash
   # 語法檢查
   zsh -n ~/.zshrc
   
   # 啟動速度測試
   for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done
   
   # 功能測試
   zsh -i -c "<tool> --version"
   ```

### 新增別名

- 常用別名 → `zsh/aliases/common.zsh`
- 導航別名 → `zsh/aliases/navigation.zsh`
- 工具專屬 → `zsh/tools/<tool>.zsh`

### 修改 PATH

- **只在以下位置修改 PATH**:
  - `zsh/env.zsh`: 早期必須的 PATH（Homebrew, ~/bin）
  - `zsh/core/00-path.zsh`: 次要 PATH（GNU tools, Krew）
- **避免在多個檔案重複設定**

### 更新外部來源檔案

範例：更新 kubectl aliases

```bash
cd ~/dotfiles/zsh/tools

# 下載最新版
curl -o kubectl-aliases-full.zsh \
  https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

# 添加檔案頭元數據
cat << 'EOF' > temp.zsh
# ---
# Tool: kubectl-aliases
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: 800+ kubectl shortcuts
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat kubectl-aliases-full.zsh >> temp.zsh
mv temp.zsh kubectl-aliases-full.zsh

# 提交變更
git add kubectl-aliases-full.zsh
git commit -m "Update kubectl-aliases to $(date +%Y-%m-%d)"
```

### 清理未使用工具

1. **確認不使用**: 詢問使用者或檢查最後使用時間
2. **檢查依賴**: `brew uses --installed <tool>`
3. **從 Brewfile 移除**: 編輯 `brew/Brewfile`
4. **移除配置**: 刪除 `zsh/tools/<tool>.zsh` 和 `zsh/rc.zsh` 中的載入邏輯
5. **更新文檔**: 從 `docs/TOOLS.md` 移除或標記為已移除
6. **提交變更**: 記錄清理原因

## 測試與驗證

### 必須執行的測試

每次修改後必須執行：

1. **語法檢查**
   ```bash
   zsh -n ~/.zshrc
   ```

2. **啟動速度測試**
   ```bash
   # 測試 5 次取平均
   for i in {1..5}; do 
     /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
   done
   # 目標: < 0.5s，最多 1s
   ```

3. **功能測試**
   ```bash
   # 測試實際載入
   zsh -i -c exit
   
   # 測試工具可用性
   zsh -i -c "<tool> --version"
   ```

4. **Symlink 驗證**
   ```bash
   ls -la ~ | grep "dotfiles"
   ```

### 效能分析

如需深入分析效能瓶頸：

```zsh
# 在 ~/.zshrc 頂部添加
zmodload zsh/zprof

# 在底部添加
zprof
```

執行 `zsh -i -c exit` 會顯示各函數耗時。

## 常見任務

### 添加新的 Homebrew 工具

```bash
# 1. 編輯 Brewfile
echo 'brew "<tool>"' >> ~/dotfiles/brew/Brewfile

# 2. 安裝
brew bundle --file=~/dotfiles/brew/Brewfile

# 3. 如需配置，建立 zsh/tools/<tool>.zsh
# 4. 更新 docs/TOOLS.md
```

### 在新機器上安裝

```bash
# 1. Clone repository
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles

# 2. 執行安裝腳本
cd ~/dotfiles
./install.sh

# 3. 安裝 Homebrew 套件
brew bundle --file=~/dotfiles/brew/Brewfile

# 4. 安裝 nvm, pyenv, sdkman 等（如需要）
# 詳見 docs/SETUP.md
```

### 更新配置

由於使用 symlink 模式，直接編輯 dotfiles repo 中的檔案即可，無需額外同步步驟。

```bash
# 編輯配置
vim ~/dotfiles/zsh/core/30-prompt.zsh

# 重新載入（或開新 shell）
exec zsh

# 提交變更
cd ~/dotfiles
git add zsh/core/30-prompt.zsh
git commit -m "Update prompt configuration"
git push
```

## 安全規則

### ❌ 絕不可以

- 刪除 `zsh/core/` 下的任何檔案（除非完全理解其用途）
- 直接修改 symlink 目標（如 `~/.zshrc`）而非原始檔案
- 在版本控制中提交 `.secrets` 檔案
- 在沒有測試的情況下提交變更
- 在不了解載入順序的情況下隨意調整檔名

### ✅ 必須遵守

- 每次修改後測試啟動速度
- 外部來源必須註明 URL 和更新日期
- 新配置檔必須包含檔案頭元數據
- 保持每個模組檔案 < 100 行（如果超過，考慮拆分）
- 敏感資訊（API keys, tokens）放在 `~/.secrets`（不納入版控）

## 工具清單

### 必要工具（經常使用）

- **Kubernetes**: kubectl, k9s, helm, kustomize
- **容器**: Docker
- **Git**: git, lazygit, gh, ghq
- **Shell 增強**: fzf, zoxide, exa, ripgrep
- **開發語言**: Go, Node.js (nvm), Java (sdkman)

### 備用工具（保留但不常用）

- **Python**: pyenv（備用，未來可能需要）
- **Git 別名**: .gitalias（1780 行，選用載入）

### 已移除工具

- OrbStack, Colima（改用 Docker Desktop）
- 字型工具（sfnt2woff 等，不再從事相關工作）

詳細清單見 `docs/TOOLS.md`。

## 配置檔格式標準

每個配置檔必須包含：

```zsh
#!/usr/bin/env zsh
# ---
# Tool: <工具名稱>
# Source: <來源 URL>
# Purpose: <用途說明>
# Updated: <YYYY-MM-DD>
# [Optional] Lazy Loading: Yes/No
# [Optional] Notes: <額外說明>
# ---

# 實際配置內容
```

## 疑難排解

### 啟動速度變慢

1. 使用 `zprof` 分析瓶頸
2. 檢查是否有 `$(command)` 在每次啟動執行
3. 考慮將耗時工具改為 lazy loading
4. 檢查快取機制是否正常運作

### 配置未生效

1. 檢查 symlink: `ls -la ~/.zshrc`
2. 檢查條件載入邏輯（工具是否在 PATH）
3. 手動測試：`source ~/dotfiles/zsh/tools/<tool>.zsh`
4. 檢查語法錯誤：`zsh -n ~/.zshrc`

### 衝突或重複定義

1. 使用 `type <command>` 查看定義來源
2. 檢查是否在多個檔案定義同一 alias/function
3. 確認載入順序是否正確

## 版本歷史

| 日期 | 版本 | 變更內容 |
|------|------|----------|
| 2026-02-06 | 2.0 | 重構為模組化架構，symlink 模式，AI 友好設計 |
| 2023-02-14 | 1.0 | 初始版本（單一 .zshrc 配置） |

## 相關資源

- **dotfiles-manager skill**: .agents/skills/dotfiles-manager/ (project-level)
- **工具清單**: docs/TOOLS.md
- **安裝指南**: docs/SETUP.md

---

**Note for AI Agents**: 
- 修改前請先閱讀本文件全部內容
- 每次修改後必須執行測試章節的所有測試
- 不確定時請詢問使用者而非猜測
- 記錄所有重要變更
