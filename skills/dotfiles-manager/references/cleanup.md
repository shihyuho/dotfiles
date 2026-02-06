# 清理未使用工具

## 安全流程

### 步驟 1: 識別候選工具

檢查可能未使用的工具：

```bash
# 列出所有已安裝的 Homebrew 套件
brew list

# 列出所有配置檔
ls "$DOTFILES_ROOT/zsh/tools/"
```

**常見候選**：
- 不再從事的工作相關工具（如字型工具）
- 重複功能的工具（如 OrbStack vs Colima）
- 試用後不再使用的工具

### 步驟 2: 確認不使用

**方法 1: 詢問使用者**
```
這個工具你還在用嗎？最後使用時間？
```

**方法 2: 檢查最後使用時間**
```bash
# 檢查命令最後執行時間（需要 shell 歷史）
grep -i "tool-name" ~/.zsh_history | tail -1
```

**方法 3: 檢查依賴關係**
```bash
# 檢查是否有其他工具依賴它
brew uses --installed <tool-name>
```

### 步驟 3: 檢查依賴關係

**必須執行**：

```bash
# 檢查 Homebrew 依賴
brew uses --installed <tool-name>

# 檢查配置檔中的引用
grep -r "<tool-name>" "$DOTFILES_ROOT/zsh/"

# 檢查是否在 PATH 中被其他工具使用
which <tool-name>
```

**警告標誌**：
- 如果有其他工具依賴 → **不要刪除**
- 如果在腳本中被引用 → **不要刪除**
- 如果是系統工具的依賴 → **不要刪除**

### 步驟 4: 從 Brewfile 移除

```bash
cd "$DOTFILES_ROOT"

# 編輯 Brewfile
vim brew/Brewfile

# 移除或註解該行
# brew "tool-name"  # Removed: no longer needed

# 如果是 cask
# cask "app-name"   # Removed: switched to alternative
```

### 步驟 5: 移除配置

```bash
# 刪除配置檔
rm "$DOTFILES_ROOT/zsh/tools/<tool-name>.zsh"

# 從 rc.zsh 移除載入邏輯
vim "$DOTFILES_ROOT/zsh/rc.zsh"
# 刪除或註解：
# _load_tool_if_exists <tool-name> ...
```

### 步驟 6: 更新文檔

```bash
# 更新 TOOLS.md
vim "$DOTFILES_ROOT/docs/TOOLS.md"

# 添加到「已移除工具」章節：
## 已移除工具

- **<tool-name>**: <原因>（移除日期: YYYY-MM-DD）
```

### 步驟 7: 卸載（可選）

```bash
# 如果確定不需要，可以卸載
brew uninstall <tool-name>

# 清理依賴
brew autoremove
```

### 步驟 8: 提交變更

```bash
git add brew/Brewfile zsh/rc.zsh docs/TOOLS.md
git commit -m "Remove unused tool: <tool-name>

Reason: <為什麼移除>
Impact: <影響範圍>
"
git push
```

## 安全檢查清單

在刪除前必須確認：

- [ ] 已確認使用者不需要此工具
- [ ] 已檢查無其他工具依賴：`brew uses --installed <tool>`
- [ ] 已檢查配置檔無引用：`grep -r <tool> zsh/`
- [ ] 已從 Brewfile 移除
- [ ] 已刪除配置檔
- [ ] 已從 rc.zsh 移除載入邏輯
- [ ] 已更新 TOOLS.md
- [ ] 已測試啟動無錯誤：`zsh -n ~/.zshrc`
- [ ] 已提交變更

## 範例：移除 OrbStack 和 Colima

```bash
# 1. 確認
brew uses --installed orbstack colima
# 輸出：（空）→ 無依賴

# 2. 檢查引用
grep -r "orbstack\|colima" "$DOTFILES_ROOT/zsh/"
# 輸出：（空）→ 無引用

# 3. 從 Brewfile 移除
sed -i.bak '/orbstack\|colima/d' brew/Brewfile

# 4. 更新文檔
echo "
- **OrbStack, Colima**: 容器工具（改用 Docker Desktop）
" >> docs/TOOLS.md

# 5. 測試
zsh -n ~/.zshrc

# 6. 提交
git add brew/Brewfile docs/TOOLS.md
git commit -m "Remove OrbStack and Colima

Reason: Switched to Docker Desktop
Impact: No breaking changes
"

# 7. 卸載（可選）
brew uninstall orbstack colima
```

## 常見錯誤

### ❌ 直接刪除沒檢查依賴

```bash
# 錯誤：直接刪除
brew uninstall python
# 結果：破壞其他依賴 python 的工具
```

### ❌ 忘記更新配置

```bash
# 錯誤：只從 Brewfile 移除
brew "tool-name" # 已刪除

# 問題：zsh/tools/tool.zsh 仍然存在
# 結果：啟動時報錯 "command not found"
```

### ✅ 正確流程

1. 檢查依賴
2. 移除 Brewfile
3. 移除配置檔
4. 移除載入邏輯
5. 更新文檔
6. 測試
7. 提交

## 回滾

如果誤刪：

```bash
# 1. 恢復 git 變更
git revert HEAD

# 2. 重新安裝
brew bundle --file=brew/Brewfile

# 3. 重新載入配置
exec zsh
```
