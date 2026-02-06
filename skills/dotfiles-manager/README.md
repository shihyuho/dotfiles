# Dotfiles Manager Skill

管理模組化 dotfiles 配置的 OpenCode skill。

## 結構

```
dotfiles-manager/
├── skill.md                    # 主入口（簡潔，通用）
└── references/
    ├── architecture.md         # 架構說明
    ├── add-tool.md            # 添加工具流程
    ├── update-aliases.md      # 更新別名流程（待建立）
    ├── optimize-startup.md    # 優化啟動速度（待建立）
    └── cleanup.md             # 清理流程（待建立）
```

## 使用方式

AI 代理會：
1. 讀取 `skill.md` 了解概述
2. 根據任務類型讀取對應的 reference
3. 執行操作
4. 驗證結果

## 設計原則

- **中性化**: 無硬編碼路徑，可適用任何遵循此架構的 dotfiles repo
- **模組化**: 主文件簡潔，詳細流程分離
- **按需載入**: AI 只讀取需要的 reference

## 相關文檔

專案特定的架構說明請參考 dotfiles repo 中的 `AGENTS.md`。
