# 更新外部別名檔

## 適用場景

當需要更新從外部來源（如 GitHub）下載的別名檔時使用此流程。

## 常見外部別名檔

### kubectl-aliases
- 來源: https://github.com/ahmetb/kubectl-aliases
- 位置: `~/.kubectl_aliases`
- 行數: 800+
- 用途: kubectl 快捷別名

### gitalias
- 來源: https://github.com/GitAlias/gitalias
- 位置: `git/aliases/gitalias`
- 行數: 1780+
- 用途: git 別名集合

## 更新流程

### 步驟 1: 下載最新版本

```bash
cd "$DOTFILES_ROOT"

# kubectl-aliases
curl -o /tmp/kubectl_aliases \
  https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

# gitalias
curl -o /tmp/gitalias \
  https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt
```

### 步驟 2: 添加元數據

```bash
# 為 kubectl_aliases 添加元數據
cat << EOF > ~/.kubectl_aliases
# ---
# Tool: kubectl-aliases
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: 800+ kubectl shortcuts
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/kubectl_aliases >> ~/.kubectl_aliases

# 為 gitalias 添加元數據
cat << EOF > git/aliases/gitalias
# ---
# Tool: gitalias
# Source: https://github.com/GitAlias/gitalias
# Purpose: 1780+ git aliases
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/gitalias >> git/aliases/gitalias
```

### 步驟 3: 測試載入

```bash
# 測試語法
zsh -n ~/.zshrc

# 測試實際載入
zsh -i -c "alias | grep kubectl | head -5"
```

### 步驟 4: 提交變更

```bash
git add ~/.kubectl_aliases git/aliases/gitalias
git commit -m "Update external aliases to $(date +%Y-%m-%d)

- kubectl-aliases: 800+ shortcuts
- gitalias: 1780+ git aliases
"
git push
```

## 優化建議

### 大型別名檔優化

如果別名檔太大影響啟動速度，可以：

1. **分層載入**：
   ```bash
   # 只載入常用的 100 個
   head -100 kubectl_aliases > kubectl_aliases_core.zsh
   
   # 提供函數載入完整版
   kalias-full() {
     source ~/.kubectl_aliases
   }
   ```

2. **條件載入**：
   ```bash
   # 只在需要時載入
   if [[ -f ~/.kube/config ]]; then
     source ~/.kubectl_aliases
   fi
   ```

## 自動化腳本

可以創建更新腳本 `scripts/update-aliases.sh`：

```bash
#!/usr/bin/env bash
set -e

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating kubectl-aliases..."
curl -o /tmp/kubectl_aliases \
  https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

cat << EOF > ~/.kubectl_aliases
# Updated: $(date +%Y-%m-%d)
EOF
cat /tmp/kubectl_aliases >> ~/.kubectl_aliases

echo "✓ Updated kubectl-aliases"
```
