# Dotfiles 架構原則（通用版）

## 設計目標
1. **效能**: Shell 啟動時間 < 0.5s（最多 1s）
2. **模組化**: 配置按功能分類，易於維護
3. **可移植**: 易於在不同機器間同步
4. **可擴展**: 添加新工具不影響現有配置

## 目錄結構約定

```
dotfiles/
├── AGENTS.md            # AI 代理指南（專案特定）
├── zsh/                 # Zsh 配置
│   ├── rc.zsh           # 主入口 (→ ~/.zshrc)
│   ├── env.zsh          # 環境變數 (→ ~/.zshenv)
│   ├── core/            # 核心配置（必載，按數字順序）
│   ├── tools/           # 工具配置（條件載入）
│   └── aliases/         # 別名分類
├── git/                 # Git 配置
├── brew/Brewfile        # Homebrew 配置
└── docs/                # 文檔
```

## 載入策略

### 核心配置（zsh/core/）
- 按檔名數字順序載入（00, 10, 20...）
- 總耗時 < 100ms
- 包含: PATH、completion、history、prompt

### 工具配置（zsh/tools/）
- 條件載入（檢查工具是否存在）
- 使用 `command -v <tool>` 檢查

### 開發工具（zsh/tools/dev/）
- Lazy loading（函數包裝延遲載入）
- 減少啟動時間 50-200ms

## 效能優化

### ❌ 禁止
- 啟動時執行子程序：`$(brew --prefix)`
- 大型檔案無條件載入
- 重複設定環境變數

### ✅ 推薦
- 硬編碼常見路徑
- 使用快取機制
- 條件載入 + lazy loading

## 測試標準

```bash
# 啟動速度
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done

# 語法檢查
zsh -n ~/.zshrc
```

目標: < 0.5s
