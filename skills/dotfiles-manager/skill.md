# Dotfiles Manager Skill

## 概述
管理模組化 dotfiles 配置系統。支援添加工具、更新別名、優化啟動速度等操作。

## 適用條件
此 skill 適用於符合以下結構的 dotfiles repository：
- 使用模組化的 zsh 配置（`zsh/core/`, `zsh/tools/`）
- 使用 Brewfile 管理套件
- 使用 symlink 模式
- 包含 `AGENTS.md` 文件

## 使用時機
- 添加新工具配置
- 更新外部別名檔（kubectl-aliases, gitalias 等）
- 優化 shell 啟動速度
- 清理未使用的工具

## 第一步：定位 Dotfiles 目錄

執行以下步驟找到 dotfiles 位置：

1. **檢查當前目錄**：
   ```bash
   [[ -f AGENTS.md ]] && echo "當前目錄就是 dotfiles"
   ```

2. **常見位置**：
   ```bash
   for dir in ~/dotfiles ~/.dotfiles ~/code/*/dotfiles ~/code/*/*/dotfiles; do
     [[ -f "$dir/AGENTS.md" ]] && echo "找到: $dir" && break
   done
   ```

3. **詢問用戶**: 如果找不到，詢問用戶 dotfiles 位置。

4. **設定變量**：
   ```bash
   DOTFILES_ROOT="<找到的路徑>"
   ```

## 核心操作流程

### 1. 添加新工具
**參考文件**: `references/add-tool.md`

**簡要步驟**：
1. 定位 dotfiles 目錄（見上方）
2. 閱讀 `references/add-tool.md` 了解完整流程
3. 按流程執行：Brewfile → 配置檔 → 載入邏輯 → 測試
4. 更新文檔

### 2. 更新外部別名檔
**參考文件**: `references/update-aliases.md`

**簡要步驟**：
1. 識別別名檔來源（kubectl-aliases, gitalias 等）
2. 閱讀 `references/update-aliases.md` 了解完整流程
3. 下載更新並添加元數據
4. 測試載入

### 3. 優化啟動速度
**參考文件**: `references/optimize-startup.md`

**簡要步驟**：
1. 測量當前啟動速度
2. 閱讀 `references/optimize-startup.md` 了解分析方法
3. 識別瓶頸並優化
4. 驗證改善效果

### 4. 清理未使用工具
**參考文件**: `references/cleanup.md`

**簡要步驟**：
1. 識別候選工具
2. 閱讀 `references/cleanup.md` 了解安全流程
3. 檢查依賴關係
4. 執行清理並更新文檔

## 架構理解

**首次使用前必讀**：
- 閱讀 `$DOTFILES_ROOT/AGENTS.md`（專案特定的架構文件）
- 閱讀 `references/architecture.md`（通用架構原則）

## 安全規則
- ❌ 不要刪除 `zsh/core/` 下的檔案
- ❌ 不要修改 symlink 目標（`~/.zshrc` 等）
- ❌ 不要在 references 中硬編碼路徑
- ✅ 每次修改後必須測試啟動速度
- ✅ 使用 `$DOTFILES_ROOT` 變量引用路徑

## 驗證檢查清單
每次操作後執行：
- [ ] 啟動速度測試（`zsh -i -c exit`）
- [ ] 語法檢查（`zsh -n ~/.zshrc`）
- [ ] 實際功能測試
- [ ] 文檔已更新

## 環境變量約定
在執行任何操作前，設定以下變量：
```bash
DOTFILES_ROOT="<dotfiles 絕對路徑>"
ZSH_DIR="$DOTFILES_ROOT/zsh"
BREW_DIR="$DOTFILES_ROOT/brew"
DOCS_DIR="$DOTFILES_ROOT/docs"
```
