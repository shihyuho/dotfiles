# 添加新工具完整流程

## 前置條件
- 已設定 `$DOTFILES_ROOT` 變量
- 已閱讀 `$DOTFILES_ROOT/AGENTS.md` 了解架構

## 步驟 1: 檢查工具狀態

```bash
command -v <TOOL_NAME> >/dev/null 2>&1 && echo "已安裝" || echo "未安裝"

[[ -f "$ZSH_DIR/tools/<TOOL_NAME>.zsh" ]] && echo "已有配置"
```

## 步驟 2: 添加到 Brewfile

```bash
cd "$BREW_DIR"

# 編輯 Brewfile，在適當分類下添加
# 格式：
# brew "<tool>"          # CLI 工具
# cask "<tool>"          # GUI 應用

brew bundle --file="$BREW_DIR/Brewfile"
```

## 步驟 3: 建立配置檔

```bash
cat > "$ZSH_DIR/tools/<TOOL_NAME>.zsh" << 'EOF'
#!/usr/bin/env zsh
# ---
# Tool: <TOOL_NAME>
# Source: <GitHub URL 或官方網站>
# Purpose: <簡述用途>
# Updated: <YYYY-MM-DD>
# ---

# 配置內容
export <TOOL>_CONFIG="value"
alias <alias>='<command>'
EOF
```

**配置檔原則**：
- 檔案頭必須包含元數據（來源、用途、更新日期）
- 保持檔案 < 100 行
- 如果內容過多，考慮 lazy loading

## 步驟 4: 註冊載入邏輯

編輯 `$ZSH_DIR/rc.zsh`，添加條件載入：

```zsh
_load_tool_if_exists <TOOL_NAME> "${DOTFILES_ROOT}/zsh/tools/<TOOL_NAME>.zsh"
```

**載入策略**：
- **常用工具**：條件載入（工具存在即載入）
- **大型配置**：lazy loading（函數包裝）
- **開發工具**：lazy loading（nvm, pyenv 模式）

## 步驟 5: 更新文檔

編輯 `$DOCS_DIR/TOOLS.md`，添加工具說明：

```markdown
## <分類>
- **<TOOL_NAME>**: <簡述>
  - 來源: <URL>
  - 配置: `zsh/tools/<TOOL_NAME>.zsh`
  - 安裝: `brew/Brewfile`
```

## 步驟 6: 測試驗證

```bash
# 1. 語法檢查
zsh -n ~/.zshrc

# 2. 啟動速度測試（5次取平均）
for i in {1..5}; do 
  /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
done

# 3. 功能測試
zsh -i -c "<TOOL_NAME> --version"
```

目標啟動速度: < 0.5s，最多 1s

## 常見場景

### 場景 1: 簡單 CLI 工具（如 bat）
```bash
# Brewfile
brew "bat"

# zsh/tools/bat.zsh
alias cat='bat --paging=never'
export BAT_THEME="Solarized (dark)"

# zsh/rc.zsh
_load_tool_if_exists bat "${DOTFILES_ROOT}/zsh/tools/bat.zsh"
```

### 場景 2: 需要初始化的工具（如 zoxide）
```bash
# zsh/tools/zoxide.zsh
eval "$(zoxide init zsh --cmd z)"
```

### 場景 3: Lazy loading 工具（如 nvm）
```bash
# zsh/tools/dev/nvm.zsh
export NVM_DIR="$HOME/.nvm"

_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
}

nvm() { _nvm_load; nvm "$@"; }
node() { _nvm_load; node "$@"; }
```
