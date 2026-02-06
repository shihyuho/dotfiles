# Dotfiles 安裝指南

## 快速開始

### 1. Clone Repository

```bash
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. 執行安裝腳本

```bash
./install.sh
```

這將建立 symlinks：
- `~/.zshrc` → `dotfiles/zsh/rc.zsh`
- `~/.zshenv` → `dotfiles/zsh/env.zsh`
- `~/.gitconfig` → `dotfiles/git/config`
- 以及其他配置檔

### 3. 安裝 Homebrew 套件

```bash
brew bundle --file=~/dotfiles/brew/Brewfile
```

### 4. 重啟 Shell

```bash
exec zsh
```

## 可選安裝

### nvm (Node.js)

```bash
# nvm 已透過 Homebrew 安裝
# 使用時會自動初始化（lazy loading）
nvm install --lts
nvm use --lts
```

### pyenv (Python)

```bash
# pyenv 已透過 Homebrew 安裝
pyenv install 3.12
pyenv global 3.12
```

### SDKMAN (Java/JVM tools)

```bash
curl -s "https://get.sdkman.io" | bash
# 重啟 shell 後使用
sdk list java
sdk install java
```

## 在新機器上同步

由於使用 symlink 模式，只需：

1. Clone repository
2. 執行 `./install.sh`
3. 安裝 Homebrew 套件

修改會立即反映，無需手動同步。

## 測試安裝

```bash
# 測試啟動速度
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done

# 測試工具是否可用
kubectl version --client
gh --version
```

## 疑難排解

### Symlink 未生效

```bash
ls -la ~/.zshrc
# 應該顯示: .zshrc -> /path/to/dotfiles/zsh/rc.zsh
```

如果不是 symlink，重新執行 `./install.sh`。

### 工具未找到

檢查 PATH：
```bash
echo $PATH
```

確認 Homebrew 已正確設定：
```bash
which brew
brew doctor
```

### 啟動速度慢

使用 `zprof` 分析：

```zsh
# 在 ~/.zshrc 頂部添加
zmodload zsh/zprof

# 在底部添加
zprof
```

執行 `zsh` 查看分析結果。

## 更多資訊

- **架構說明**: `AGENTS.md`
- **工具清單**: `docs/TOOLS.md`
- **GitHub**: https://github.com/shihyuho/dotfiles
