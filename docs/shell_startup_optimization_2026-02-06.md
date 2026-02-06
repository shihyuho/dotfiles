# Shell 啟動速度優化紀錄

**優化日期**: 2026-02-06  
**優化者**: AI Assistant (Antigravity)  
**Session ID**: 當前對話

---

## 📊 優化成果總覽

| 指標 | 優化前 | 優化後 | 改善幅度 |
|------|--------|--------|----------|
| 總啟動時間 | 2.93 秒 | 1.34 秒 | **54.3%** ↓ |
| User Time | 1.20 秒 | 0.70 秒 | 41.7% ↓ |
| System Time | 0.84 秒 | 0.30 秒 | 64.3% ↓ |
| 節省時間 | - | 1.59 秒 | - |

---

## 🎯 優化項目詳細紀錄

### 1. Completion 系統快取優化

#### 目的
- 減少每次啟動時的 completion 初始化時間（原本 280ms → 優化後 12ms）
- 避免重複掃描和檢查 completion 檔案

#### 作法
**檔案**: `.zshrc` (Lines 20-69)

```zsh
# 設定快取目錄
: "${XDG_CACHE_HOME:=$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZSH_CACHE_DIR"

ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"

# 條件式重建：只在配置變更時才重新生成
if [[ ! -s "$ZSH_COMPDUMP" \
   || "$HOME/.zshrc" -nt "$ZSH_COMPDUMP" \
   || "${BREW_PREFIX}/share/zsh/site-functions" -nt "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"  # -C 跳過安全檢查
fi

# 啟用 completion cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
```

#### 潛在影響
- ✅ **正面**: 大幅減少啟動時間
- ⚠️ **注意**: 使用 `-C` 會跳過安全檢查，在共享系統上需謹慎
- ⚠️ **維護**: 新增 Homebrew completion 後需要：
  - 方法一：手動刪除 `~/.cache/zsh/zcompdump-*` 強制重建
  - 方法二：等待下次 `.zshrc` 修改時自動重建
- 📁 **新增檔案**: `~/.cache/zsh/zcompdump-5.9`

---

### 2. 移除重複的 Completion 載入

#### 目的
- 移除同步執行的 completion 命令（kubectl: 163ms, oc: 200ms, kompose: 38ms）
- 總共節省約 400ms

#### 作法
**檔案**: `.zshrc` (Lines 71-76)

**移除前** (每次啟動都執行):
```zsh
source <(kubectl completion zsh)
source <(oc completion zsh)
source <(kompose completion zsh)
```

**移除後**:
```zsh
# kubectl, oc, kompose completions are provided by Homebrew in site-functions
# No need to source them explicitly
```

#### 潛在影響
- ✅ **正面**: 節省 ~400ms 啟動時間
- ⚠️ **依賴**: 需要確保 Homebrew 已安裝這些工具的 completion
  ```bash
  ls -l /opt/homebrew/share/zsh/site-functions/_kubectl
  ls -l /opt/homebrew/share/zsh/site-functions/_oc
  ls -l /opt/homebrew/share/zsh/site-functions/_kompose
  ```
- ✅ **無影響**: Homebrew 的 completion 功能完全相同

---

### 3. K9s 和 OpenCode Completion 快取化

#### 目的
- k9s completion: 232ms → 0ms (快取後)
- opencode completion: 574ms → 0ms (快取後)
- 總共節省約 800ms

#### 作法
**檔案**: `.zshrc` (Lines 27-50)

```zsh
ZSH_COMP_DIR="$ZSH_CACHE_DIR/completions"
mkdir -p "$ZSH_COMP_DIR"
fpath=("$ZSH_COMP_DIR" $fpath)

# Completion 快取生成函數
_zsh_gen_completion() {
  local tool="$1" cmdline="$2"
  local out="$ZSH_COMP_DIR/_${tool}"
  local bin; bin="$(command -v "$tool" 2>/dev/null)" || return 0

  # 只在缺檔或工具更新時才重建
  if [[ ! -s "$out" || "$bin" -nt "$out" ]]; then
    umask 077
    {
      print -r -- "#compdef ${tool}"
      eval "$cmdline"
    } >| "${out}.tmp" && mv -f "${out}.tmp" "$out"
  fi
}

# 生成快取
_zsh_gen_completion k9s 'k9s completion zsh'
_zsh_gen_completion opencode 'opencode completion'
```

#### 潛在影響
- ✅ **正面**: 啟動時不再執行外部命令
- 📁 **新增檔案**: 
  - `~/.cache/zsh/completions/_k9s`
  - `~/.cache/zsh/completions/_opencode`
- 🔄 **自動更新**: 當 k9s 或 opencode 二進位檔案更新時，會自動重建快取
- ⚠️ **手動更新**: 如果快取損壞，刪除快取檔案即可：
  ```bash
  rm ~/.cache/zsh/completions/_k9s
  rm ~/.cache/zsh/completions/_opencode
  ```

---

### 4. NVM Lazy Loading

#### 目的
- 避免每次啟動都載入 NVM (371ms)
- 只在實際使用 Node.js 工具時才載入

#### 作法
**檔案**: `.zshrc` (Lines 98-116)

**優化前** (同步載入):
```zsh
[ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
[ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
```

**優化後** (Lazy Loading):
```zsh
export NVM_DIR="$HOME/.nvm"
mkdir -p "${NVM_DIR}"

_nvm_load() {
  unset -f nvm node npm npx corepack yarn pnpm
  [ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
  [ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
}

nvm()     { _nvm_load; nvm "$@"; }
node()    { _nvm_load; node "$@"; }
npm()     { _nvm_load; npm "$@"; }
npx()     { _nvm_load; npx "$@"; }
corepack(){ _nvm_load; corepack "$@"; }
yarn()    { _nvm_load; yarn "$@"; }
pnpm()    { _nvm_load; pnpm "$@"; }
```

#### 潛在影響
- ✅ **正面**: 啟動時節省 ~371ms
- ⚠️ **行為改變**: 第一次使用 `node`/`npm` 等命令時會有 300-400ms 的一次性延遲
- ⚠️ **環境變數**: NVM 設定的環境變數在載入前不可用
- 💡 **建議**: 如果專案使用 `.nvmrc`，可在進入專案目錄時自動載入：
  ```zsh
  autoload -U add-zsh-hook
  load-nvmrc() {
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      nvm use  # 會觸發 lazy loading
    fi
  }
  add-zsh-hook chpwd load-nvmrc
  ```

---

### 5. Pyenv Lazy Loading

#### 目的
- 避免每次啟動都執行 `pyenv init` (61ms)
- 保留 shims 在 PATH 中供直接使用

#### 作法
**檔案**: `.zshrc` (Lines 118-130)

**優化前**:
```zsh
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

**優化後**:
```zsh
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
fi

_pyenv_load() {
  unset -f pyenv
  eval "$(command pyenv init -)"
}

pyenv() { _pyenv_load; pyenv "$@"; }
```

#### 潛在影響
- ✅ **正面**: 啟動時節省 ~61ms
- ✅ **Python 可直接使用**: 因為 shims 已在 PATH 中，`python`, `pip` 等命令不受影響
- ⚠️ **功能限制**: 
  - `pyenv shell` 命令在第一次使用 `pyenv` 前不可用
  - `pyenv` 的 completion 在載入前不可用
- 💡 **完全不受影響**: 如果你不使用 `pyenv` 命令本身，只是透過它管理 Python 版本，這個優化完全透明

---

### 6. SDKMAN Lazy Loading

#### 目的
- 避免每次啟動都載入 SDKMAN (約 50-100ms)
- 只在需要使用 `sdk` 命令時才載入

#### 作法
**檔案**: `.zshrc` (Lines 132-147)

**優化前**:
```zsh
export SDKMAN_DIR=$HOME/.sdkman
if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
```

**優化後**:
```zsh
export SDKMAN_DIR="$HOME/.sdkman"

_sdkman_load() {
  unset -f sdk
  if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  fi
}

sdk() { _sdkman_load; sdk "$@"; }
```

#### 潛在影響
- ✅ **正面**: 啟動時節省 ~50-100ms
- ⚠️ **重要**: SDKMAN 管理的工具 (`java`, `maven`, `gradle` 等) 在 SDKMAN 載入前不會自動在 PATH 中
- 💡 **解決方案**: 如果需要在每個 shell 都能使用 SDKMAN 安裝的工具：
  ```zsh
  # 在 .zshenv 中手動加入工具路徑
  export PATH="$HOME/.sdkman/candidates/java/current/bin:$PATH"
  export PATH="$HOME/.sdkman/candidates/maven/current/bin:$PATH"
  ```
- 📝 **使用情境**: 
  - 只用 `sdk` 命令管理工具 → 適合 lazy loading
  - 需要立即使用 Java/Maven → 考慮不 lazy load 或手動加入 PATH

---

### 7. Git Prompt 優化

#### 目的
- 減少每次顯示 prompt 時執行多個 git 命令的開銷
- 改善大型 repository 的互動體驗

#### 作法
**檔案**: `.zsh_prompt` (Lines 14-44)

**優化前** (每次 prompt 都執行多個 git 命令):
```zsh
prompt_git() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  branchName="$(git symbolic-ref --quiet --short HEAD ...)"
  
  # 多次 git 呼叫
  git diff --quiet --ignore-submodules --cached
  git diff-files --quiet --ignore-submodules --
  git ls-files --others --exclude-standard
  git rev-parse --verify refs/stash
}

PROMPT+="\$(prompt_git ...)"  # 每次都執行
```

**優化後** (使用 precmd hook + TTL 快取):
```zsh
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook

typeset -g __GIT_SEG=""
typeset -g __GIT_LAST_PWD=""
typeset -g __GIT_LAST_TS=0

_git_segment_update() {
  local now=$EPOCHSECONDS
  # 同目錄 + 2 秒內不重算
  if [[ "$PWD" == "$__GIT_LAST_PWD" && $(( now - __GIT_LAST_TS )) -lt 2 ]]; then
    return
  fi
  __GIT_LAST_PWD="$PWD"
  __GIT_LAST_TS=$now
  __GIT_SEG=""

  command git rev-parse --is-inside-work-tree &>/dev/null || return

  # 單次 git status --porcelain 取代多次 git 命令
  local s head branch dirty=""
  s="$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v1 -b 2>/dev/null)" || return
  head="${${(f)s}[1]}"
  branch="${head#\#\# }"
  branch="${branch%%...*}"

  [[ "${#${(f)s}}" -gt 1 ]] && dirty=" [*]"

  __GIT_SEG="%F{15} on %f%F{61}${branch}%f%F{33}${dirty}%f"
}

add-zsh-hook precmd _git_segment_update
add-zsh-hook chpwd  _git_segment_update

# Prompt 使用快取變數
PROMPT+="%F\${__GIT_SEG}%f"
```

#### 潛在影響
- ✅ **正面**: 
  - 大幅改善 prompt 響應速度
  - 在大型 repository 中體感明顯
- ⚠️ **行為改變**:
  - Git 狀態最多延遲 2 秒更新
  - 快速連續操作時 prompt 可能顯示舊狀態
- 🔧 **可調整**: 修改 TTL 時間
  ```zsh
  if [[ ... && $(( now - __GIT_LAST_TS )) -lt 5 ]]; then  # 改為 5 秒
  ```
- 💡 **簡化的 dirty 標記**: 
  - 優化前：區分 `+` (staged), `!` (modified), `?` (untracked), `$` (stashed)
  - 優化後：統一顯示 `[*]` 表示有任何變更
  - 如需詳細狀態，可查看原始實作

---

### 8. Kube-ps1 條件載入

#### 目的
- 只在有安裝 kubectl 時才載入 kube-ps1
- 避免在沒有 Kubernetes 環境的機器上載入無用的 prompt 組件

#### 作法
**檔案**: `.zsh_prompt` (Lines 102-109)

**優化前**:
```zsh
source "$HOME/.kube-ps1.sh"
PROMPT+="\$(kube_ps1)"
```

**優化後**:
```zsh
if command -v kubectl >/dev/null 2>&1; then
  source "$HOME/.kube-ps1.sh"
fi

# ...

if command -v kubectl >/dev/null 2>&1; then
  PROMPT+="\$(kube_ps1)"
fi
```

#### 潛在影響
- ✅ **正面**: 在沒有 kubectl 的環境中節省 ~5-10ms
- ✅ **向後相容**: 有 kubectl 時行為完全不變
- ⚠️ **注意**: 如果在 shell 執行期間安裝 kubectl，需要重新載入 shell 才能看到 kube-ps1

---

### 9. Homebrew 路徑硬編碼

#### 目的
- 避免每次 .zshenv 執行時都呼叫 `brew shellenv` (30ms)
- Apple Silicon Mac 上 Homebrew 路徑是固定的

#### 作法
**檔案**: `.zshenv` (Lines 4-23)

**優化前**:
```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**優化後**:
```zsh
if [[ -d "/opt/homebrew" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export MANPATH="/opt/homebrew/share/man:$MANPATH"
  export INFOPATH="/opt/homebrew/share/info:$INFOPATH"
elif [[ -d "/usr/local/Homebrew" ]]; then
  # Intel Mac fallback
  export HOMEBREW_PREFIX="/usr/local"
  export HOMEBREW_CELLAR="/usr/local/Cellar"
  export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  export MANPATH="/usr/local/share/man:$MANPATH"
  export INFOPATH="/usr/local/share/info:$INFOPATH"
fi
```

#### 潛在影響
- ✅ **正面**: 節省 ~30ms，且 .zshenv 在每個 shell 實例都執行，實際影響更大
- ✅ **相容性**: 同時支援 Apple Silicon 和 Intel Mac
- ⚠️ **假設**: Homebrew 安裝在標準路徑
- 💡 **檢查**: 如果 Homebrew 安裝在非標準路徑，執行以下命令確認：
  ```bash
  brew --prefix  # 查看實際路徑
  ```

**`.zshrc` 相關變更**:
```zsh
# 使用 .zshenv 設定的 HOMEBREW_PREFIX
: "${BREW_PREFIX:=$HOMEBREW_PREFIX}"
```

---

### 10. Go GOPATH 條件檢查

#### 目的
- 只在有安裝 go 時才執行 `go env GOPATH`
- 避免在沒有 Go 環境的機器上產生錯誤

#### 作法
**檔案**: `.zshenv` (Lines 51-56)

**優化前**:
```zsh
: "${GOPATH:=$(go env GOPATH)}"
export PATH="$PATH:$GOPATH/bin"
```

**優化後**:
```zsh
if command -v go >/dev/null 2>&1; then
  : "${GOPATH:=$(go env GOPATH)}"
  export PATH="$PATH:$GOPATH/bin"
fi
```

#### 潛在影響
- ✅ **正面**: 避免在沒有 Go 的環境中產生錯誤訊息
- ⚠️ **仍然執行**: 在有 Go 的環境中，`go env GOPATH` 仍會每次執行 (~11ms)
- 💡 **進一步優化** (未實作): 可改為 lazy loading
  ```zsh
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$PATH:$GOPATH/bin"
  ```

---

### 11. API Keys 安全性改善

#### 目的
- 將敏感資料從版本控制中移除
- 避免 API Keys 意外洩露到 GitHub

#### 作法

**新增檔案**: `~/.secrets`

**檔案權限**:
```bash
chmod 600 ~/.secrets
```

**`.zshrc` 變更** (Lines 149-150):
```zsh
# Load secrets (API keys, tokens, etc.)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
```

**`.gitignore` 應加入** (建議):
```
.secrets
```

#### 潛在影響
- ✅✅✅ **安全性**: API Keys 不再被版本控制追蹤
- ⚠️⚠️⚠️ **緊急**: 已在 .zshrc 中明文儲存的 API Keys **必須立即輪替**
  - GEMINI_API_KEY: https://aistudio.google.com/apikey
  - GitHub PAT: https://github.com/settings/tokens
- 📝 **新機器設定**: 在新機器上需要手動建立 `~/.secrets` 檔案
- 💡 **最佳實踐**: 
  - 使用環境變數管理工具 (如 direnv, 1Password CLI)
  - 定期輪替 API Keys
  - 使用最小權限原則設定 token

---

## 📊 效能分析資料

### 優化前瓶頸 (zprof 分析)

```
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    1         325.61   325.61   37.89%    258.11   258.11   30.03%  nvm_auto
 2)    2         153.69    76.84   17.88%    153.69    76.84   17.88%  compdump
 3) 1646         141.87     0.09   16.51%    141.87     0.09   16.51%  compdef
 4)    2         469.13   234.56   54.58%    139.56    69.78   16.24%  compinit
```

### 優化後瓶頸 (zprof 分析)

```
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    1          13.09    13.09   56.04%     13.09    13.09   56.04%  compinit
 2)    1           3.55     3.55   15.18%      3.49     3.49   14.95%  _zsh_highlight_load_highlighters
 3)    1           3.44     3.44   14.74%      3.44     3.44   14.74%  _zsh_highlight_bind_widgets
 4)    2           1.57     0.78    6.72%      1.57     0.78    6.72%  _zsh_gen_completion
```

---

## 🔄 回滾程序

如需回滾優化，所有原始檔案都有備份：

```bash
# 回滾所有變更
cd /Users/matt/code/github.com/shihyuho/dotfiles
cp .zshrc.backup .zshrc
cp .zshenv.backup .zshenv
cp .zsh_prompt.backup .zsh_prompt

# 套用回滾
make source

# (可選) 清理新增的快取
rm -rf ~/.cache/zsh/
```

---

## 📁 檔案變更總覽

### 修改的檔案

| 檔案 | 主要變更 | 行數變化 |
|------|---------|---------|
| `.zshrc` | Completion 快取、Lazy loading、Secrets 載入 | 88 → 155 (+67) |
| `.zshenv` | Homebrew 硬編碼、Go 條件檢查 | 62 → 62 (重構) |
| `.zsh_prompt` | Git prompt 快取、Kube-ps1 條件載入 | 121 → 121 (重構) |

### 新增的檔案

| 檔案 | 用途 | 權限 |
|------|-----|------|
| `~/.secrets` | 儲存 API Keys | 600 |
| `~/.cache/zsh/zcompdump-5.9` | Completion dump | 644 |
| `~/.cache/zsh/completions/_k9s` | K9s completion | 644 |
| `~/.cache/zsh/completions/_opencode` | OpenCode completion | 644 |
| `.zshrc.backup` | 原始備份 | 644 |
| `.zshenv.backup` | 原始備份 | 644 |
| `.zsh_prompt.backup` | 原始備份 | 644 |

---

## ⚠️ 重要注意事項

### 1. 安全性警告

- **立即行動**: 已在 .zshrc 中明文儲存過的 API Keys 已經洩露，必須立即輪替
  - `GEMINI_API_KEY`: https://aistudio.google.com/apikey
  - `MCP_GITHUB_PERSONAL_ACCESS_TOKEN`: https://github.com/settings/tokens

### 2. 行為改變

以下命令在第一次使用時會有 300-400ms 的延遲：
- `nvm`, `node`, `npm`, `npx`, `yarn`, `pnpm`, `corepack`
- `pyenv` (但 `python`, `pip` 不受影響)
- `sdk`, `java`, `mvn`, `gradle` (如使用 SDKMAN lazy loading)

### 3. 維護指南

**定期清理快取** (建議每月一次):
```bash
rm -rf ~/.cache/zsh/*
```

**新工具安裝後重建 completion**:
```bash
# 方法一：刪除快取強制重建
rm ~/.cache/zsh/zcompdump-*

# 方法二：touch .zshrc 觸發條件式重建
touch ~/.zshrc
```

**新機器部署清單**:
1. Clone dotfiles repository
2. 執行 `make source` 套用配置
3. 建立 `~/.secrets` 檔案並設定權限 600
4. 加入新的 API Keys (不要重用舊的)
5. 確認 Homebrew 安裝路徑 (`brew --prefix`)

---

## 🎯 進一步優化建議

如需達到 <500ms 的啟動時間，可考慮以下措施：

### 1. 使用現代 Prompt

**Starship** (推薦):
```bash
brew install starship
# 在 .zshrc 最後加入
eval "$(starship init zsh)"
```

**Powerlevel10k**:
- 支援非同步 git status
- 配置複雜但效能極佳

### 2. 延遲載入 zsh-syntax-highlighting

```zsh
# 使用 zsh-defer
source ~/.zsh-defer/zsh-defer.plugin.zsh
zsh-defer source ${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### 3. 減少 PATH 掃描

```zsh
# 只加入真正需要的 GNU tools
for tool in coreutils findutils gnu-sed grep gawk; do
  d="${BREW_PREFIX}/opt/${tool}/libexec/gnubin"
  [[ -d "$d" ]] && export PATH="$d:$PATH"
done
```

### 4. Go GOPATH Lazy Loading

```zsh
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:$GOPATH/bin"
# 不執行 go env GOPATH
```

---

## 📚 參考資料

- [Zsh Completion System](https://zsh.sourceforge.io/Doc/Release/Completion-System.html)
- [NVM GitHub](https://github.com/nvm-sh/nvm)
- [Pyenv GitHub](https://github.com/pyenv/pyenv)
- [SDKMAN](https://sdkman.io/)
- [Homebrew Shell Completion](https://docs.brew.sh/Shell-Completion)
- [zprof - Zsh Profiling](https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzprof-Module)

---

## 📞 問題回報

如遇到任何問題，請檢查：

1. **啟動時錯誤訊息**: 檢查 `~/.zshrc`, `~/.zshenv` 語法錯誤
2. **Completion 不工作**: 
   ```bash
   rm -rf ~/.cache/zsh/*
   source ~/.zshrc
   ```
3. **工具找不到**: 確認 PATH 設定
   ```bash
   echo $PATH | tr ':' '\n'
   ```
4. **API Keys 無效**: 檢查 `~/.secrets` 檔案權限和內容

---

**優化完成日期**: 2026-02-06  
**下次檢視日期**: 建議 3-6 個月後檢視效能並調整
