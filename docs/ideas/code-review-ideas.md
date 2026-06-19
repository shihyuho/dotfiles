# Code Review Dynamic Workflow — 設計理論與 Claude Code Prompt

> 放置建議：下載後放到 `~/tmp/code-review-dynamic-workflow.md`。
> 本檔分兩部分：Part 1 設計理論（為什麼這樣設計），Part 2 可直接貼進 Claude Code 的 prompt。

---

# Part 1 — 設計理論

## 1.1 核心問題：為什麼 code review 適合用 dynamic workflow

預設的 Claude Code harness 在單一 context window 裡同時「規劃 + 執行」，對一般 coding 任務很有效，但在長時間、大規模平行、高度結構化或對抗性的任務上會崩。code review 正好同時具備這幾個特性，因此會踩到三種失敗模式：

- **Agentic laziness（怠惰）**：複雜多步任務上，Claude 做完部分進度就宣告完成。典型例子是 security review 50 項只查了 35 項——不是模型在說謊，而是 working memory 填滿、失去對剩餘量的追蹤、合理化了一個停止點。
- **Self-preferential bias（自我偏好）**：要 Claude 對照 rubric 驗證或評判自己的產出時，它傾向偏好自己的發現。
- **Goal drift（目標漂移）**：跨多輪後逐漸失去對原始目標的忠實度，尤其在 context 壓縮（compaction）之後。每次摘要都是有損的，「不要做 X」這類約束容易遺失。

dynamic workflow 的解法是把規劃移進一支 JavaScript 編排腳本，由 runtime 在背景執行，並把工作分散到各自擁有乾淨 context window、目標單一的 subagent。每個 agent 只回傳結構化結果，Claude 的主 context 只保留最終答案。

## 1.2 六-phase 架構

| Phase | 角色 | 對應 pattern |
|---|---|---|
| 1 Scope + classify | 範圍界定、風險分桶、依複雜度決定 per-file model | classify-and-act / model routing |
| 2 Parallel specialized review | 依維度 fan-out，loop 跑到待審清單清空 | fan-out-and-synthesize + loop-until-done |
| 3 Per-finding adversarial verification | 每個 finding 配獨立 verifier + skeptic persona | adversarial verification |
| 4 Cross-cutting analysis | 去重、合併、找根因、抓組合型問題 | synthesize |
| 5 Convergence & ranking | 依 severity 排序、解衝突、未收斂則回流 | loop until done |
| 6 Report | 整理成可貼回 PR 的報告 | classify-and-act（輸出端） |

審查維度（Phase 2 fan-out 的切分軸）：正確性/邏輯、安全性、架構/設計、效能、測試覆蓋、風格/慣例。每個維度可再依檔案水平切成多個 agent。

## 1.3 三個貫穿全程的硬性原則（直接對應三種失敗模式）

- **防 laziness → loop-until-done**：凡逐項處理的階段，用 loop 跑到待處理清單清空，而非做完一輪就停。搭配 `/goal` 設硬性完成條件效果最好。
- **防 self-preferential bias → verifier ≠ producer**：負責驗證/反駁某 finding 的 agent，必須是與產出該 finding 不同的 subagent instance，禁止自評。
- **防誤判 → skeptic persona**：除了逐條 verifier，另設一個 skeptic 角色專門複查 blocker/major，挑戰它們是否為 false positive，目的是壓低誤判而非附和。

## 1.4 Model routing 策略

原則：判斷力/收斂用 Opus，量大/模式化的並行用 Sonnet，純機械篩選用 Haiku。

| 階段 / 維度 | 預設 model | 理由 |
|---|---|---|
| Phase 1 Scope | Opus | 決定全部 fan-out 派工，只跑一次，成本可忽略 |
| Phase 2 正確性/邏輯 | Sonnet | 量大、能力與速度平衡 |
| Phase 2 安全性 | Opus | 漏報代價最高 |
| Phase 2 架構/設計 | Opus | 需跨檔案全局判斷 |
| Phase 2 效能 | Sonnet | 多為可辨識 pattern |
| Phase 2 測試覆蓋 | Sonnet | 比對較機械 |
| Phase 2 風格/慣例 | Haiku | 最規則、量最大，壓成本 |
| Phase 3 驗證 | Opus | 品質關卡，省不得 |
| Phase 4 整合 | Opus | 全局推理 |
| Phase 5 收斂 | Opus | 影響交付結果 |
| Phase 6 報告 | Sonnet | 結果已定，整理文字 |

進階做法：在 Phase 1 加 classifier，依每個檔案 diff 的大小與複雜度動態 route，取代靜態維度指派。代價是 classifier 本身也花 token，熟悉成本後再開。

## 1.5 成本與資源限制

- 一次 run 可能比對話裡做同一件事用掉明顯更多 token，計入方案用量與 rate limit。
- 並行上限：同時最多 16 個 agent（CPU 核心少的機器更少）；單次 run 上限 1,000 個 agent。
- 逐 finding 配獨立 verifier 會放大 agent 數：80 個 finding = 80 個 verifier，大 PR 易撞並行上限而排隊。折衷：只對 blocker/major 逐條驗，minor/nit 批次驗。
- 可設 token budget（prompt 寫「use 30k tokens」即設上限）。先用一個 PR 或一個目錄試跑抓使用感再放大。

## 1.6 安全：quarantine pattern

若 review 會讀到不可信內容（PR 引用外部連結、第三方/client 貢獻），禁止讀取外部內容的 agent 執行高權限動作（寫檔、跑指令），高權限動作只交給不接觸外部內容的 agent。適用於有外部 co-development 夥伴的情境。

---

# Part 2 — Claude Code Prompt（v2）

> 使用方式：整段貼進 Claude Code，開頭保留 ultracode 觸發（舊版用 workflow 關鍵字，或「用 workflow」自然語言）。
> 第一次只填一個 PR 或一個目錄；滿意後 /workflows → 選 run → s 存成 /code-review。

## PROMPT 本體（從這裡開始複製）

ultracode: 用一個 dynamic workflow 對 [填：PR #123 / origin/main...feature-branch / src/routes/] 做一次完整 code review。請用 30k tokens 以內。

請依下列 phase 編排 subagent。三個硬性原則貫穿全程：
（a）負責「驗證 / 反駁」finding 的 agent，必須是與「產出該 finding」不同的 subagent instance，禁止自評；
（b）凡是「逐項處理」的階段，用 loop 跑到待處理清單清空為止，不要做完一輪就宣告完成——務必確認每個檔案、每個 finding 都被處理到；
（c）每個 agent 只輸出結構化 JSON finding，長敘述留到最後報告。

### Phase 1 — Scope + classify（範圍界定與分類，single agent，用 Opus）
1. 列出受影響檔案與改動行數。
2. 依風險分桶：高（核心邏輯 / 認證授權 / 資料層 / 對外 API、Gateway）、中（一般業務邏輯、設定）、低（文件、測試 fixture、純格式）。
3. 對每個檔案，依 diff 大小與複雜度標一個建議審查 model（classifier 的角色）：
   - 小且單純的改動 → Haiku
   - 一般邏輯改動 → Sonnet
   - 大型 / 高耦合 / 安全敏感 → Opus
4. 產出「派工計畫」：每個檔案要派哪些審查維度、各用什麼 model。低風險檔案少派或不派。

### Phase 2 — Parallel specialized review（fan-out + loop-until-done）
把 Phase 1 派工計畫中的所有 (檔案 × 維度) 組成一個待審佇列，loop 派 subagent 直到佇列清空。維度與預設 model（可被 Phase 1 的 per-file 標記覆蓋）：
- 正確性 / 邏輯（邊界、null、錯誤路徑、競態）：Sonnet
- 安全性（注入、認證授權、機密外洩、輸入驗證）：Opus
- 架構 / 設計（既有 pattern、耦合、分層）：Opus
- 效能（N+1、阻塞 I/O、資源洩漏）：Sonnet
- 測試覆蓋（新邏輯有無對應測試、測試是否真驗證行為）：Sonnet
- 風格 / 慣例（命名、文件、repo 慣例）：Haiku

每個 finding 格式：
{
  "id": "唯一編號",
  "file": "相對路徑",
  "line": 行號或範圍,
  "severity": "blocker | major | minor | nit",
  "category": "correctness | security | architecture | performance | testing | style",
  "produced_by": "產出此 finding 的 agent id",
  "description": "問題是什麼（一兩句）",
  "suggestion": "具體修法（一兩句）"
}

loop 結束條件：待審佇列為空，且每個檔案都至少被其風險桶所要求的維度各審過一次。

### Phase 3 — Per-finding adversarial verification（逐條驗證，用 Opus）
對 Phase 2 的「每一個」finding，spawn 一個獨立 verifier（必須與 produced_by 不同），逐條判斷：
- 這真的是問題嗎？是否誤判？這段在實際呼叫路徑上會被觸發嗎？
- 若我有提供測試套件 / coding guidelines / API 規格，以它們為 ground truth 判斷，不要憑空認定。
loop 跑到所有 finding 都被驗證過。每個 finding 標記 verified / dismissed（附理由）/ needs_human_review。
另外 spawn 一個 skeptic persona agent，專門複查那些被標為 blocker/major 的 finding，挑戰它們是否其實是 false positive——目的是壓低誤判，而非附和。

### Phase 4 — Cross-cutting analysis（跨切面整合，用 Opus）
把 verified 的 finding 拉到一起：去重、合併相關項、找出組合型問題（多個單獨無害的改動合起來破壞 invariant）、把重複出現的反 pattern 歸納成根因。

### Phase 5 — Convergence & ranking（收斂與排序，用 Opus）
依 severity（blocker > major > minor > nit）與信心度排序；解決或標記互相衝突的建議；若仍有爭議項，回 Phase 3 對該項再驗一次（loop，非無限——同一項最多再驗一輪）。

### Phase 6 — Report（報告，用 Sonnet）
輸出 Markdown，可直接貼進 GitHub PR comment：
1. 一句話結論：可 merge / 需修正後再議 / 有 blocker。
2. 依 severity 分組的 finding 清單，每項標 file:line、description、suggestion。
3. 整體架構與測試覆蓋觀察。
4. needs_human_review 清單獨立列出，說明為何需人工判斷。

（複製到這裡結束）

---

## 進階：安全 / 外部貢獻場景（quarantine pattern）
若這次 review 會讀到不可信內容（PR 引用外部連結、第三方 / client 的貢獻），在 prompt 末尾加一句：
「讀取外部 / 不可信內容的 agent 不得執行高權限動作（寫檔、跑指令）；高權限動作只交給不接觸外部內容的 agent 執行。」

## 搭配使用
- /goal：設硬性完成要求（例：「每個檔案的高風險維度都必須有 verified 或 dismissed 結論」），治 laziness。
- /loop：把存好的 /code-review 排程，每條 branch 自動跑。
- token budget：prompt 開頭的「用 30k tokens 以內」可依 PR 大小調整，小 PR 給 10k。

## 第一次跑的保守版
Phase 2 全部用 Sonnet、判斷型 phase（1/3/4/5）用 Opus，跑完看哪個維度品質不夠再單獨升級。Phase 1 的 per-file classifier 可先關掉（統一用維度預設 model），等熟悉成本後再開，因為 classifier 本身也花 token。

## 大 PR 變體：分級驗證
若 finding 數量大（易撞 16 並行上限），把 Phase 3 改成：blocker/major 逐條獨立驗證，minor/nit 同類批次驗證，可大幅減少 verifier agent 數。
