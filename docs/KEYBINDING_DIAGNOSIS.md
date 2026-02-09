# Keybinding Diagnosis Guide

這個文檔幫助診斷 Ghostty → Zellij → OpenCode 環境中的快捷鍵問題。

## 問題狀態

### ✅ 已修復
1. ~~`zj` 啟動失敗~~ - Zellij 配置語法錯誤已修復
2. ~~Zellij theme 和 compact layout 不見~~ - 已將頂層配置移出 `ui` 區塊

### ⚠️ 待解決
1. `Alt + F` 在 OpenCode 中無法開啟 floating pane
2. `Command + Left/Right` 在 OpenCode 中無法跳到行首/行尾

---

## 診斷步驟

### Step 1: 測試 Ghostty 是否正確發送序列

在**普通終端**中(不在 Zellij 或 OpenCode 中):

```bash
# 方法 1: 使用 cat
cat
# 按 Command + Left,應該看到: ^[[H 或 ^[OH
# 按 Command + Right,應該看到: ^[[F 或 ^[OF
# 按 Alt + F,應該看到: ^[f 或 ƒ
# Ctrl + C 退出

# 方法 2: 使用 xxd 查看十六進制
cat | xxd
# 按快捷鍵,查看實際的字節序列
```

**預期結果**:
- `Command + Left` → `\x1b[H` (顯示為 `^[[H`)
- `Command + Right` → `\x1b[F` (顯示為 `^[[F`)
- `Alt + F` → `\x1bf` (顯示為 `^[f`)

### Step 2: 測試 Zellij 是否接收序列

在 Zellij 的 **normal mode** 中:

```bash
zellij
# 不要進入任何應用,直接測試:
cat
# 測試相同的快捷鍵
```

**預期結果**:
- 如果能看到序列 → Zellij 沒有攔截,問題在應用層
- 如果看不到序列 → Zellij 攔截了,需要修改 keybinds

### Step 3: 測試 OpenCode 內部

在 OpenCode 中:
- 開啟終端窗格
- 運行 `cat`
- 測試快捷鍵

---

## 可能的問題和解決方案

### 問題 1: Alt + F 無法觸發 Floating Panes

**可能原因**:

1. **Ghostty 的 `unbind` 不生效**
   - macOS 可能仍攔截 Alt + F
   - 檢查: 系統偏好設定 → 鍵盤 → 快捷鍵

2. **OpenCode 攔截了 Alt + F**
   - OpenCode 可能有自己的快捷鍵系統
   - 需要在 OpenCode 設定中排除

3. **Zellij 模式問題**
   - `Alt + F` 只在 `shared_except "locked"` 模式下有效
   - 確認沒有在 locked mode

**解決方案**:

```bash
# 測試 1: 直接在 Zellij 中(不在 OpenCode)
zellij
# 按 Alt + F,應該會切換 floating panes

# 測試 2: 檢查 Ghostty 是否真的發送了 Alt + F
# 在普通 shell 中:
cat
# 按 Alt + F,應該看到 ^[f

# 測試 3: 如果 Ghostty 發送正確但 Zellij 沒反應
# 可能需要添加額外的綁定
```

### 問題 2: Command + Left/Right 不跳轉

**可能原因**:

1. **Escape 序列格式問題**
   - CSI 格式 (`\x1b[H`) vs SS3 格式 (`\x1bOH`)
   - 不同應用可能識別不同格式

2. **應用內建快捷鍵衝突**
   - OpenCode 可能有內建的 Command + Left/Right 綁定

3. **Zellij scroll mode 攔截**
   - 在 scroll mode 下,Left/Right 被綁定為 PageScroll

**解決方案**:

嘗試替代序列格式:

```bash
# 在 Ghostty config 中測試不同格式:

# 選項 1: CSI 格式 (當前)
keybind = cmd+left=text:\x1b[H
keybind = cmd+right=text:\x1b[F

# 選項 2: SS3 格式
keybind = cmd+left=text:\x1bOH
keybind = cmd+right=text:\x1bOF

# 選項 3: 完整 CSI 序列
keybind = cmd+left=text:\x1b[1~
keybind = cmd+right=text:\x1b[4~

# 選項 4: 直接映射到 Ctrl + A/E (Emacs 風格)
keybind = cmd+left=text:\x01
keybind = cmd+right=text:\x05
```

---

## 快速測試腳本

創建測試腳本:

```bash
#!/bin/bash
# /tmp/test_keys.sh

echo "=== Keybinding Test ==="
echo ""
echo "請按以下鍵,然後按 Enter:"
echo ""

echo -n "1. Command + Left: "
read -r key1
echo "   收到: $(printf '%q' "$key1")"
echo ""

echo -n "2. Command + Right: "
read -r key2
echo "   收到: $(printf '%q' "$key2")"
echo ""

echo -n "3. Alt + F: "
read -r key3
echo "   收到: $(printf '%q' "$key3")"
echo ""

echo "=== 預期結果 ==="
echo "Command + Left:  \$'\\E[H' 或 \$'\\EOH'"
echo "Command + Right: \$'\\E[F' 或 \$'\\EOF'"
echo "Alt + F:         \$'\\Ef' 或 'ƒ'"
```

使用方法:
```bash
chmod +x /tmp/test_keys.sh
/tmp/test_keys.sh
```

---

## 調試 Checklist

### Ghostty 層級
- [ ] `macos-option-as-alt = left` 已設置
- [ ] `keybind = alt+f=unbind` 存在
- [ ] `keybind = cmd+left=text:\x1b[H` 存在
- [ ] `keybind = cmd+right=text:\x1b[F` 存在
- [ ] 重啟 Ghostty 後測試

### Zellij 層級
- [ ] `bind "Alt f" { ToggleFloatingPanes; }` 在 `shared_except "locked"` 中
- [ ] `unbind "Alt left"` 和 `unbind "Alt right"` 存在
- [ ] 不在 scroll mode 或 locked mode
- [ ] 配置語法正確 (`zellij setup --check`)

### OpenCode 層級
- [ ] OpenCode 沒有攔截這些快捷鍵
- [ ] 測試在 OpenCode 內的終端窗格中

---

## 參考資料

- [Ghostty Keybinding Docs](https://ghostty.org/docs/config/keybind)
- [Zellij Keybinding Docs](https://zellij.dev/documentation/keybindings.html)
- [ANSI Escape Sequences](https://en.wikipedia.org/wiki/ANSI_escape_code)
- [CSI vs SS3 Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html)

---

## 下一步

如果以上都無法解決:

1. **更換序列格式** - 嘗試上述不同的 escape sequence 格式
2. **使用不同快捷鍵** - 例如 `Ctrl + A/E` 代替 Command + Left/Right
3. **檢查 OpenCode 文檔** - 查看是否有快捷鍵配置選項
4. **使用 Zellij 的 `Write` action** - 直接讓 Zellij 發送序列
