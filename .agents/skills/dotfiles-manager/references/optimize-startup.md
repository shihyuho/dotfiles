# 優化啟動速度

## 測量當前速度

### 基本測試

```bash
# 測試 5 次取平均
for i in {1..5}; do 
  /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
done
```

目標：< 0.5s，最多 1s

### 詳細分析

使用 `zprof` 分析瓶頸：

```zsh
# 在 ~/.zshrc 頂部添加
zmodload zsh/zprof

# 在底部添加
zprof
```

執行 `zsh` 會顯示各函數耗時。

## 常見瓶頸與解決方案

### 1. 子程序執行

**問題**：每次啟動都執行 `$(brew --prefix)` 等命令

❌ **錯誤範例**：
```zsh
PATH="$(brew --prefix)/bin:$PATH"
```

✅ **正確做法**：
```zsh
# 硬編碼常見路徑
PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon
```

### 2. 大型檔案無條件載入

**問題**：800 行 kubectl aliases 每次都載入

❌ **錯誤範例**：
```zsh
source ~/.kubectl_aliases
```

✅ **正確做法**：
```zsh
# 條件載入
if command -v kubectl >/dev/null 2>&1; then
  source ~/.kubectl_aliases
fi

# 或 lazy loading
kalias() {
  source ~/.kubectl_aliases
  unset -f kalias
}
```

### 3. 開發工具初始化

**問題**：nvm, pyenv, sdkman 初始化耗時 50-200ms

❌ **錯誤範例**：
```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

✅ **正確做法**（lazy loading）：
```zsh
export NVM_DIR="$HOME/.nvm"

_nvm_load() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

nvm() { _nvm_load; nvm "$@"; }
node() { _nvm_load; node "$@"; }
npm() { _nvm_load; npm "$@"; }
```

### 4. 重複的 completion 初始化

**問題**：每次都重建 completion cache

❌ **錯誤範例**：
```zsh
compinit
```

✅ **正確做法**（智能快取）：
```zsh
# 只在必要時重建
if [[ ! -s "$ZSH_COMPDUMP" || "$HOME/.zshrc" -nt "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi
```

### 5. 外部命令在 prompt 中執行

**問題**：每次顯示 prompt 都執行 git status

❌ **錯誤範例**：
```zsh
PROMPT='$(git branch 2>/dev/null | grep "^\*" | cut -d " " -f2)'
```

✅ **正確做法**（快取 + TTL）：
```zsh
typeset -g __GIT_SEG=""
typeset -g __GIT_LAST_TS=0

_git_segment_update() {
  local now=$EPOCHSECONDS
  # 2 秒內不更新
  [[ $(( now - __GIT_LAST_TS )) -lt 2 ]] && return
  __GIT_LAST_TS=$now
  
  # 更新 git info
  __GIT_SEG="$(git branch 2>/dev/null | grep '^\*' | cut -d ' ' -f2)"
}

add-zsh-hook precmd _git_segment_update
PROMPT='${__GIT_SEG}'
```

## 優化檢查清單

每次修改後檢查：

- [ ] 無 `$(command)` 在啟動時執行
- [ ] 大型檔案使用條件載入或 lazy loading
- [ ] 開發工具使用 lazy loading
- [ ] Completion cache 正確設定
- [ ] Prompt 使用快取機制
- [ ] 啟動時間 < 0.5s

## 效能基準

| 項目 | 耗時 | 優化建議 |
|------|------|----------|
| PATH 設定 | < 5ms | 硬編碼路徑 |
| Completion init | < 50ms | 智能快取 |
| History 設定 | < 5ms | - |
| Prompt 設定 | < 10ms | 快取 git info |
| Syntax highlighting | < 20ms | 最後載入 |
| 條件載入工具 | < 10ms/tool | 使用 `command -v` |
| Lazy loading setup | < 5ms/tool | 函數包裝 |

**總計目標**：< 150ms（核心）+ < 50ms（工具）= < 200ms
